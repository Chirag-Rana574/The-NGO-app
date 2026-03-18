import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    TextInput,
    TouchableOpacity,
    Alert,
    ActivityIndicator,
} from 'react-native';
import RNPickerSelect from 'react-native-picker-select';
import ApiService from '../services/api.service';
import { Worker, Medicine } from '../types';
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

export default function AddScheduleScreen({ navigation }: any) {
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [medicines, setMedicines] = useState<Medicine[]>([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);

    const [selectedWorker, setSelectedWorker] = useState<number | null>(null);
    const [selectedMedicine, setSelectedMedicine] = useState<number | null>(null);
    const [date, setDate] = useState('');
    const [time, setTime] = useState('');
    const [doseAmount, setDoseAmount] = useState('1');

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const [workersData, medicinesData] = await Promise.all([
                ApiService.getWorkers(),
                ApiService.getMedicines(),
            ]);
            setWorkers(workersData);
            setMedicines(medicinesData);
        } catch (error) {
            Alert.alert('Error', 'Failed to load data');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async () => {
        // Validation
        if (!selectedWorker || !selectedMedicine || !date || !time) {
            Alert.alert('Validation Error', 'Please fill all required fields');
            return;
        }

        const doseNum = parseInt(doseAmount);
        if (isNaN(doseNum) || doseNum < 1) {
            Alert.alert('Validation Error', 'Dose amount must be at least 1');
            return;
        }

        setSubmitting(true);

        try {
            // Combine date and time
            const scheduledTime = new Date(`${date}T${time}:00`).toISOString();

            await ApiService.createSchedule({
                worker_id: selectedWorker,
                medicine_id: selectedMedicine,
                scheduled_time: scheduledTime,
                dose_amount: doseNum,
            });

            Alert.alert('Success', 'Schedule created successfully', [
                { text: 'OK', onPress: () => navigation.goBack() },
            ]);
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to create schedule';
            Alert.alert('Error', errorMsg);
        } finally {
            setSubmitting(false);
        }
    };

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <ScrollView style={styles.container}>
            <View style={styles.form}>
                <Text style={styles.label}>Worker *</Text>
                <View style={styles.pickerContainer}>
                    <RNPickerSelect
                        onValueChange={(value) => setSelectedWorker(value)}
                        items={workers.map((w) => ({ label: w.name, value: w.id }))}
                        placeholder={{ label: 'Select a worker...', value: null }}
                        style={pickerSelectStyles}
                    />
                </View>

                <Text style={styles.label}>Medicine *</Text>
                <View style={styles.pickerContainer}>
                    <RNPickerSelect
                        onValueChange={(value) => setSelectedMedicine(value)}
                        items={medicines.map((m) => ({
                            label: `${m.name} (Stock: ${m.current_stock})`,
                            value: m.id,
                        }))}
                        placeholder={{ label: 'Select a medicine...', value: null }}
                        style={pickerSelectStyles}
                    />
                </View>

                <Text style={styles.label}>Date * (YYYY-MM-DD)</Text>
                <TextInput
                    style={styles.input}
                    value={date}
                    onChangeText={setDate}
                    placeholder="2024-03-15"
                    placeholderTextColor={COLORS.textLight}
                />

                <Text style={styles.label}>Time * (HH:MM 24-hour format)</Text>
                <TextInput
                    style={styles.input}
                    value={time}
                    onChangeText={setTime}
                    placeholder="14:30"
                    placeholderTextColor={COLORS.textLight}
                />

                <Text style={styles.label}>Dose Amount *</Text>
                <TextInput
                    style={styles.input}
                    value={doseAmount}
                    onChangeText={setDoseAmount}
                    keyboardType="numeric"
                    placeholder="1"
                    placeholderTextColor={COLORS.textLight}
                />

                <TouchableOpacity
                    style={[styles.submitButton, submitting && styles.submitButtonDisabled]}
                    onPress={handleSubmit}
                    disabled={submitting}
                >
                    {submitting ? (
                        <ActivityIndicator color={COLORS.white} />
                    ) : (
                        <Text style={styles.submitButtonText}>Create Schedule</Text>
                    )}
                </TouchableOpacity>
            </View>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    form: {
        padding: SPACING.lg,
    },
    label: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.text,
        marginBottom: SPACING.sm,
        marginTop: SPACING.md,
    },
    input: {
        backgroundColor: COLORS.white,
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 8,
        padding: SPACING.md,
        fontSize: FONT_SIZES.md,
        color: COLORS.text,
        minHeight: 56,
    },
    pickerContainer: {
        backgroundColor: COLORS.white,
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 8,
        minHeight: 56,
        justifyContent: 'center',
    },
    submitButton: {
        backgroundColor: COLORS.primary,
        padding: SPACING.lg,
        borderRadius: 8,
        alignItems: 'center',
        marginTop: SPACING.xl,
        minHeight: 56,
        justifyContent: 'center',
    },
    submitButtonDisabled: {
        opacity: 0.6,
    },
    submitButtonText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
    },
});

const pickerSelectStyles = StyleSheet.create({
    inputIOS: {
        fontSize: FONT_SIZES.md,
        paddingVertical: SPACING.md,
        paddingHorizontal: SPACING.md,
        color: COLORS.text,
        minHeight: 56,
    },
    inputAndroid: {
        fontSize: FONT_SIZES.md,
        paddingVertical: SPACING.md,
        paddingHorizontal: SPACING.md,
        color: COLORS.text,
        minHeight: 56,
    },
});
