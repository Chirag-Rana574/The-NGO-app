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
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import RNPickerSelect from 'react-native-picker-select';
import { format, parseISO } from 'date-fns';
import ApiService from '../services/api.service';
import SuccessToast from '../components/SuccessToast';
import { Worker, Medicine, Patient } from '../types';
import { COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET } from '../constants/theme';

export default function CreateScheduleScreen({ route, navigation }: any) {
    const { date } = route.params;
    const [time, setTime] = useState(new Date());
    const [showTimePicker, setShowTimePicker] = useState(false);
    const [selectedPatient, setSelectedPatient] = useState<number | null>(null);
    const [selectedWorker, setSelectedWorker] = useState<number | null>(null);
    const [selectedMedicine, setSelectedMedicine] = useState<number | null>(null);
    const [dosage, setDosage] = useState('');
    const [showSuccessToast, setShowSuccessToast] = useState(false);

    const [patients, setPatients] = useState<Patient[]>([]);
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [medicines, setMedicines] = useState<Medicine[]>([]);
    const [loading, setLoading] = useState(true);

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

    const handleSave = async () => {
        // Validation
        if (!selectedPatient) {
            Alert.alert('Validation Error', 'Please select a patient');
            return;
        }
        if (!selectedWorker) {
            Alert.alert('Validation Error', 'Please select a worker');
            return;
        }
        if (!selectedMedicine) {
            Alert.alert('Validation Error', 'Please select a medicine');
            return;
        }
        if (!dosage || parseFloat(dosage) <= 0) {
            Alert.alert('Validation Error', 'Please enter a valid dosage');
            return;
        }

        try {
            // Combine date and time
            const scheduledDateTime = new Date(date);
            scheduledDateTime.setHours(time.getHours());
            scheduledDateTime.setMinutes(time.getMinutes());
            scheduledDateTime.setSeconds(0);

            await ApiService.createSchedule({
                patient_id: selectedPatient,
                worker_id: selectedWorker,
                medicine_id: selectedMedicine,
                scheduled_time: scheduledDateTime.toISOString(),
                dose_amount: parseFloat(dosage),
            });

            setShowSuccessToast(true);
            setTimeout(() => {
                navigation.goBack();
            }, 2000);
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to create schedule';
            Alert.alert('Error', errorMsg);
        }
    };

    const selectedMedicineObj = medicines.find(m => m.id === selectedMedicine);

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
            <SuccessToast
                visible={showSuccessToast}
                message="Schedule created successfully!"
                onHide={() => setShowSuccessToast(false)}
            />

            {/* Date Display */}
            <View style={styles.dateSection}>
                <Text style={styles.dateLabel}>Date</Text>
                <Text style={styles.dateValue}>{format(parseISO(date), 'EEEE, MMMM d, yyyy')}</Text>
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
            <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
                <Text style={styles.saveButtonText}>Save Schedule</Text>
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
