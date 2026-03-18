import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    TouchableOpacity,
    TextInput,
    Alert,
    Platform,
    ActivityIndicator,
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import RNPickerSelect from 'react-native-picker-select';
import { format, parseISO, differenceInHours } from 'date-fns';
import ApiService from '../services/api.service';
import PasskeyModal from '../components/PasskeyModal';
import SuccessToast from '../components/SuccessToast';
import { Worker, Medicine, Patient, Schedule } from '../types';
import { COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET } from '../constants/theme';

export default function EditScheduleScreen({ route, navigation }: any) {
    const { schedule } = route.params as { schedule: Schedule };

    const [time, setTime] = useState(new Date(schedule.scheduled_time));
    const [showTimePicker, setShowTimePicker] = useState(false);
    const [selectedPatient, setSelectedPatient] = useState<number>(schedule.patient_id);
    const [selectedWorker, setSelectedWorker] = useState<number>(schedule.worker_id);
    const [selectedMedicine, setSelectedMedicine] = useState<number>(schedule.medicine_id);
    const [dosage, setDosage] = useState(schedule.dose_amount.toString());
    const [showSuccessToast, setShowSuccessToast] = useState(false);
    const [showPasskeyModal, setShowPasskeyModal] = useState(false);
    const verifiedPinRef = React.useRef<string | null>(null);

    const [patients, setPatients] = useState<Patient[]>([]);
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [medicines, setMedicines] = useState<Medicine[]>([]);
    const [loading, setLoading] = useState(true);

    // Check if this schedule is within 24 hours
    const isWithin24Hours = differenceInHours(new Date(schedule.scheduled_time), new Date()) < 24;

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const [patientsData, workersData, medicinesData] = await Promise.all([
                ApiService.getPatients(true),
                ApiService.getWorkers(true),
                ApiService.getMedicines(true),
            ]);
            setPatients(patientsData);
            setWorkers(workersData);
            setMedicines(medicinesData);
        } catch (error) {
            Alert.alert('Error', 'Failed to load data');
        } finally {
            setLoading(false);
        }
    };

    const onTimeChange = (event: any, selectedTime?: Date) => {
        setShowTimePicker(Platform.OS === 'ios');
        if (selectedTime) {
            setTime(selectedTime);
        }
    };

    const handleSave = async (masterKey?: string) => {
        if (!dosage || parseFloat(dosage) <= 0) {
            Alert.alert('Validation Error', 'Please enter a valid dosage');
            return;
        }

        // If within 24 hours and no master key yet, show the passkey modal
        if (isWithin24Hours && !masterKey) {
            setShowPasskeyModal(true);
            return;
        }

        try {
            const scheduledDateTime = new Date(schedule.scheduled_time);
            scheduledDateTime.setHours(time.getHours());
            scheduledDateTime.setMinutes(time.getMinutes());
            scheduledDateTime.setSeconds(0);

            await ApiService.updateSchedule(schedule.id, {
                patient_id: selectedPatient,
                worker_id: selectedWorker,
                medicine_id: selectedMedicine,
                scheduled_time: scheduledDateTime.toISOString(),
                dose_amount: parseFloat(dosage),
                master_key: masterKey || undefined,
            });

            setShowSuccessToast(true);
            setTimeout(() => {
                navigation.goBack();
            }, 2000);
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to update schedule';
            Alert.alert('Error', errorMsg);
        }
    };

    const handlePasskeySuccess = () => {
        // Use the ref which holds the verified PIN (avoids stale closure)
        setShowPasskeyModal(false);
        const pin = verifiedPinRef.current;
        if (pin) {
            handleSave(pin);
            verifiedPinRef.current = null;
        }
    };

    const selectedMedicineObj = medicines.find(m => m.id === selectedMedicine);

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
            <SuccessToast
                visible={showSuccessToast}
                message="Schedule updated successfully!"
                onHide={() => setShowSuccessToast(false)}
            />

            <PasskeyModal
                visible={showPasskeyModal}
                onClose={() => setShowPasskeyModal(false)}
                onSuccess={handlePasskeySuccess}
                onVerify={async (pin) => {
                    const isValid = await ApiService.verifyKey(pin);
                    if (isValid) {
                        verifiedPinRef.current = pin;
                    }
                    return isValid;
                }}
                title="Master Key Required"
            />

            {/* 24-hour warning */}
            {isWithin24Hours && (
                <View style={styles.warningBanner}>
                    <Text style={styles.warningText}>
                        ⚠️ This schedule is within 24 hours. Master key required to save changes.
                    </Text>
                </View>
            )}

            {/* Date Display */}
            <View style={styles.dateSection}>
                <Text style={styles.dateLabel}>Date</Text>
                <Text style={styles.dateValue}>
                    {format(new Date(schedule.scheduled_time), 'EEEE, MMMM d, yyyy')}
                </Text>
            </View>

            {/* Time Picker */}
            <View style={styles.section}>
                <Text style={styles.label}>Time</Text>
                <TouchableOpacity
                    style={styles.timeButton}
                    onPress={() => setShowTimePicker(true)}
                >
                    <Text style={styles.timeText}>{format(time, 'h:mm a')}</Text>
                </TouchableOpacity>
                {showTimePicker && (
                    <DateTimePicker
                        value={time}
                        mode="time"
                        is24Hour={false}
                        display="spinner"
                        onChange={onTimeChange}
                    />
                )}
            </View>

            {/* Patient Selection */}
            <View style={styles.section}>
                <Text style={styles.label}>👤 Patient</Text>
                <View style={styles.pickerContainer}>
                    <RNPickerSelect
                        onValueChange={(value) => setSelectedPatient(value)}
                        value={selectedPatient}
                        items={patients.map(p => ({ label: p.name, value: p.id }))}
                        placeholder={{ label: 'Select a patient...', value: null }}
                        style={pickerSelectStyles}
                        useNativeAndroidPickerStyle={false}
                    />
                </View>
            </View>

            {/* Worker Selection */}
            <View style={styles.section}>
                <Text style={styles.label}>👨‍⚕️ Assigned Worker</Text>
                <View style={styles.pickerContainer}>
                    <RNPickerSelect
                        onValueChange={(value) => setSelectedWorker(value)}
                        value={selectedWorker}
                        items={workers.map(w => ({ label: w.name, value: w.id }))}
                        placeholder={{ label: 'Select a worker...', value: null }}
                        style={pickerSelectStyles}
                        useNativeAndroidPickerStyle={false}
                    />
                </View>
            </View>

            {/* Medicine Selection */}
            <View style={styles.section}>
                <Text style={styles.label}>💊 Medicine</Text>
                <View style={styles.pickerContainer}>
                    <RNPickerSelect
                        onValueChange={(value) => setSelectedMedicine(value)}
                        value={selectedMedicine}
                        items={medicines.map(m => ({
                            label: `${m.name} (${m.current_stock} ${m.dosage_unit} available)`,
                            value: m.id
                        }))}
                        placeholder={{ label: 'Select a medicine...', value: null }}
                        style={pickerSelectStyles}
                        useNativeAndroidPickerStyle={false}
                    />
                </View>
            </View>

            {/* Dosage Input */}
            <View style={styles.section}>
                <Text style={styles.label}>
                    💉 Dosage {selectedMedicineObj ? `(${selectedMedicineObj.dosage_unit})` : ''}
                </Text>
                <TextInput
                    style={styles.input}
                    value={dosage}
                    onChangeText={setDosage}
                    placeholder="Enter dosage amount"
                    placeholderTextColor={COLORS.textLight}
                    keyboardType="decimal-pad"
                />
            </View>

            {/* Save Button */}
            <TouchableOpacity style={styles.saveButton} onPress={() => handleSave()}>
                <Text style={styles.saveButtonText}>
                    {isWithin24Hours ? '🔐 Save with Master Key' : 'Save Changes'}
                </Text>
            </TouchableOpacity>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    contentContainer: {
        padding: SPACING.md,
    },
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    warningBanner: {
        backgroundColor: '#FEF3C7',
        borderRadius: 10,
        padding: SPACING.md,
        marginBottom: SPACING.md,
        borderWidth: 1,
        borderColor: '#F59E0B',
    },
    warningText: {
        fontSize: FONT_SIZES.sm,
        color: '#92400E',
        textAlign: 'center',
        fontWeight: '600',
    },
    dateSection: {
        backgroundColor: COLORS.primary,
        borderRadius: 12,
        padding: SPACING.md,
        marginBottom: SPACING.md,
        alignItems: 'center',
    },
    dateLabel: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.white,
        opacity: 0.9,
        marginBottom: 2,
    },
    dateValue: {
        fontSize: FONT_SIZES.md,
        fontWeight: 'bold',
        color: COLORS.white,
        textAlign: 'center',
    },
    section: {
        marginBottom: SPACING.md,
    },
    label: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    timeButton: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        alignItems: 'center',
        borderWidth: 1.5,
        borderColor: COLORS.primary,
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
    },
    timeText: {
        fontSize: 28,
        fontWeight: 'bold',
        color: COLORS.primary,
    },
    pickerContainer: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        borderWidth: 1.5,
        borderColor: COLORS.border,
        minHeight: MIN_TOUCH_TARGET,
    },
    input: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        fontSize: FONT_SIZES.lg,
        color: COLORS.text,
        borderWidth: 1.5,
        borderColor: COLORS.border,
        minHeight: MIN_TOUCH_TARGET,
        textAlign: 'center',
    },
    saveButton: {
        backgroundColor: COLORS.primary,
        borderRadius: 12,
        padding: SPACING.md,
        alignItems: 'center',
        marginTop: SPACING.sm,
        marginBottom: SPACING.lg,
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.15,
        shadowRadius: 6,
        elevation: 3,
    },
    saveButtonText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
        color: COLORS.white,
    },
});

const pickerSelectStyles = StyleSheet.create({
    inputIOS: {
        fontSize: FONT_SIZES.md,
        paddingVertical: SPACING.md,
        paddingHorizontal: SPACING.md,
        color: COLORS.text,
        minHeight: MIN_TOUCH_TARGET,
    },
    inputAndroid: {
        fontSize: FONT_SIZES.md,
        paddingVertical: SPACING.md,
        paddingHorizontal: SPACING.md,
        color: COLORS.text,
        minHeight: MIN_TOUCH_TARGET,
    },
    placeholder: {
        color: COLORS.textLight,
        fontSize: FONT_SIZES.md,
    },
});
