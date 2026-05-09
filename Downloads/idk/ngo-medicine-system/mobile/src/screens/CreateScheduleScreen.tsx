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
import { format, parseISO } from 'date-fns';
import ApiService from '../services/api.service';
import SuccessToast from '../components/SuccessToast';
import { Worker, Medicine, Patient } from '../types';
import {
    COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET,
    BORDER_RADIUS, CARD_SHADOW, SECTION_HEADER_STYLE, LETTER_SPACING,
} from '../constants/theme';

export default function CreateScheduleScreen({ route, navigation }: any) {
    const date = route?.params?.date || format(new Date(), 'yyyy-MM-dd');
    const [time, setTime] = useState(new Date());
    const [showTimePicker, setShowTimePicker] = useState(false);
    const [selectedPatient, setSelectedPatient] = useState<number | null>(null);
    const [selectedWorker, setSelectedWorker] = useState<number | null>(null);
    const [selectedMedicine, setSelectedMedicine] = useState<number | null>(null);
    const [dosage, setDosage] = useState('');
    const [showSuccessToast, setShowSuccessToast] = useState(false);
    const [loading, setLoading] = useState(true);

    const [patients, setPatients] = useState<Patient[]>([]);
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [medicines, setMedicines] = useState<Medicine[]>([]);

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

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer} showsVerticalScrollIndicator={false}>
            <SuccessToast
                visible={showSuccessToast}
                message="Schedule created successfully!"
                onHide={() => setShowSuccessToast(false)}
            />

            {/* Hero Header */}
            <View style={styles.headerSection}>
                <Text style={styles.sectionLabel}>NEW ENTRY</Text>
                <Text style={styles.heroTitle}>Create Schedule</Text>
                <Text style={styles.heroSubtitle}>
                    Assign a medicine delivery to a worker for a specific patient and time.
                </Text>
            </View>

            {/* Date Display Card */}
            <View style={styles.dateCard}>
                <View style={styles.dateCardAccent} />
                <View style={styles.dateCardContent}>
                    <Text style={styles.dateCardLabel}>SCHEDULED DATE</Text>
                    <Text style={styles.dateCardValue}>{format(parseISO(date), 'EEEE, MMMM d, yyyy')}</Text>
                </View>
            </View>

            {/* Time Picker */}
            <View style={styles.formSection}>
                <Text style={styles.formLabel}>SCHEDULED TIME</Text>
                <TouchableOpacity
                    style={styles.timeButton}
                    onPress={() => setShowTimePicker(true)}
                    activeOpacity={0.7}
                >
                    <Text style={styles.timeIcon}>🕐</Text>
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
            <View style={styles.formSection}>
                <Text style={styles.formLabel}>👤  PATIENT</Text>
                <View style={styles.pickerCard}>
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
            <View style={styles.formSection}>
                <Text style={styles.formLabel}>👨‍⚕️  ASSIGNED WORKER</Text>
                <View style={styles.pickerCard}>
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
            <View style={styles.formSection}>
                <Text style={styles.formLabel}>💊  MEDICINE</Text>
                <View style={styles.pickerCard}>
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
            <View style={styles.formSection}>
                <Text style={styles.formLabel}>
                    💉  DOSAGE {selectedMedicineObj ? `(${selectedMedicineObj.dosage_unit})` : ''}
                </Text>
                <View style={styles.inputCard}>
                    <TextInput
                        style={styles.input}
                        value={dosage}
                        onChangeText={setDosage}
                        placeholder="Enter dosage amount"
                        placeholderTextColor={COLORS.textHint}
                        keyboardType="decimal-pad"
                    />
                </View>
            </View>

            {/* Save Button */}
            <TouchableOpacity style={styles.saveButton} onPress={handleSave} activeOpacity={0.85}>
                <Text style={styles.saveButtonText}>✓  Create Schedule</Text>
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
        paddingBottom: 100,
    },
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },

    // ─── Header Section ─────────────────────────────────────────
    headerSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.sm,
    },
    sectionLabel: {
        ...SECTION_HEADER_STYLE,
        color: COLORS.textSecondary,
    },
    heroTitle: {
        fontSize: 32,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xs,
        letterSpacing: LETTER_SPACING.tight,
    },
    heroSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
    },

    // ─── Date Card ──────────────────────────────────────────────
    dateCard: {
        flexDirection: 'row',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        marginHorizontal: SPACING.md,
        marginTop: SPACING.lg,
        overflow: 'hidden',
        ...CARD_SHADOW,
    },
    dateCardAccent: {
        width: 4,
        backgroundColor: COLORS.primary,
    },
    dateCardContent: {
        flex: 1,
        padding: SPACING.lg,
    },
    dateCardLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.xs,
    },
    dateCardValue: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
    },

    // ─── Form Section ───────────────────────────────────────────
    formSection: {
        marginHorizontal: SPACING.md,
        marginTop: SPACING.lg,
    },
    formLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.sm,
        marginLeft: SPACING.xs,
    },

    // ─── Time Button ────────────────────────────────────────────
    timeButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        minHeight: MIN_TOUCH_TARGET,
        ...CARD_SHADOW,
    },
    timeIcon: {
        fontSize: 22,
        marginRight: SPACING.sm,
    },
    timeText: {
        fontSize: 28,
        fontWeight: '800',
        color: COLORS.primary,
    },

    // ─── Picker Card ────────────────────────────────────────────
    pickerCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        minHeight: MIN_TOUCH_TARGET,
        ...CARD_SHADOW,
    },

    // ─── Input Card ─────────────────────────────────────────────
    inputCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        ...CARD_SHADOW,
    },
    input: {
        padding: SPACING.lg,
        fontSize: FONT_SIZES.lg,
        color: COLORS.text,
        minHeight: MIN_TOUCH_TARGET,
        textAlign: 'center',
        fontWeight: '600',
    },

    // ─── Save Button ────────────────────────────────────────────
    saveButton: {
        backgroundColor: COLORS.primary,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: 16,
        alignItems: 'center',
        marginHorizontal: SPACING.md,
        marginTop: SPACING.xl,
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
        elevation: 6,
    },
    saveButtonText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.white,
    },
});

const pickerSelectStyles = StyleSheet.create({
    inputIOS: {
        fontSize: FONT_SIZES.md,
        paddingVertical: SPACING.md,
        paddingHorizontal: SPACING.lg,
        color: COLORS.text,
        minHeight: MIN_TOUCH_TARGET,
    },
    inputAndroid: {
        fontSize: FONT_SIZES.md,
        paddingVertical: SPACING.md,
        paddingHorizontal: SPACING.lg,
        color: COLORS.text,
        minHeight: MIN_TOUCH_TARGET,
    },
    placeholder: {
        color: COLORS.textHint,
        fontSize: FONT_SIZES.md,
    },
});
