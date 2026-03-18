import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    TouchableOpacity,
    RefreshControl,
    ActivityIndicator,
    Alert,
    AppState,
} from 'react-native';
import { Calendar, DateData } from 'react-native-calendars';
import { format, parseISO, addDays, isBefore, isAfter, startOfDay, differenceInHours } from 'date-fns';
import ApiService from '../services/api.service';
import PasskeyModal from '../components/PasskeyModal';
import { Schedule } from '../types';
import { COLORS, SPACING, FONT_SIZES, STATUS_COLORS, STATUS_LABELS } from '../constants/theme';

export default function SchedulesScreen({ navigation }: any) {
    const [schedules, setSchedules] = useState<Schedule[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [selectedDate, setSelectedDate] = useState(format(new Date(), 'yyyy-MM-dd'));
    const [markedDates, setMarkedDates] = useState<any>({});
    const [showPasskeyModal, setShowPasskeyModal] = useState(false);
    const [pendingDeleteId, setPendingDeleteId] = useState<number | null>(null);
    const verifiedDeletePinRef = React.useRef<string | null>(null);

    const loadSchedules = useCallback(async () => {
        try {
            const data = await ApiService.getSchedules();
            setSchedules(data);

            // Create marked dates object for calendar
            const marked: any = {};
            data.forEach((schedule: Schedule) => {
                const date = format(parseISO(schedule.scheduled_time), 'yyyy-MM-dd');
                if (!marked[date]) {
                    marked[date] = { marked: true, dots: [] };
                }
            });

            // Add selected date
            marked[selectedDate] = {
                ...marked[selectedDate],
                selected: true,
                selectedColor: COLORS.primary,
            };

            setMarkedDates(marked);
        } catch (error) {
            console.error('Failed to load schedules:', error);
            Alert.alert('Error', 'Failed to load schedules');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, [selectedDate]);

    useEffect(() => {
        loadSchedules();

        // Auto-refresh every 30 seconds
        const interval = setInterval(loadSchedules, 30000);

        // Refresh when app returns from background
        const appStateSub = AppState.addEventListener('change', (state) => {
            if (state === 'active') loadSchedules();
        });

        return () => {
            clearInterval(interval);
            appStateSub.remove();
        };
    }, [loadSchedules]);

    const onRefresh = () => {
        setRefreshing(true);
        loadSchedules();
    };

    const performDelete = async (scheduleId: number, masterKey?: string) => {
        try {
            await ApiService.deleteSchedule(scheduleId, masterKey);
            loadSchedules();
        } catch (error: any) {
            const msg = error.response?.data?.detail || 'Failed to delete schedule';
            Alert.alert('Error', msg);
        }
    };

    const handleDeleteSchedule = (schedule: Schedule) => {
        const isWithin24Hours = differenceInHours(new Date(schedule.scheduled_time), new Date()) < 24;

        Alert.alert(
            'Delete Schedule',
            isWithin24Hours
                ? 'This schedule is within 24 hours. Master key is required to delete it.'
                : 'Are you sure you want to delete this schedule?',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                        if (isWithin24Hours) {
                            setPendingDeleteId(schedule.id);
                            setShowPasskeyModal(true);
                        } else {
                            performDelete(schedule.id);
                        }
                    },
                },
            ]
        );
    };

    const handleDeletePasskeySuccess = () => {
        setShowPasskeyModal(false);
        const pin = verifiedDeletePinRef.current;
        if (pendingDeleteId && pin) {
            performDelete(pendingDeleteId, pin);
            verifiedDeletePinRef.current = null;
            setPendingDeleteId(null);
        }
    };

    const onDayPress = (day: DateData) => {
        setSelectedDate(day.dateString);

        // Update marked dates
        const newMarked = { ...markedDates };
        Object.keys(newMarked).forEach(key => {
            if (newMarked[key].selected) {
                delete newMarked[key].selected;
                delete newMarked[key].selectedColor;
            }
        });
        newMarked[day.dateString] = {
            ...newMarked[day.dateString],
            selected: true,
            selectedColor: COLORS.primary,
        };
        setMarkedDates(newMarked);
    };

    const getSchedulesForSelectedDate = () => {
        return schedules.filter(schedule => {
            const scheduleDate = format(parseISO(schedule.scheduled_time), 'yyyy-MM-dd');
            return scheduleDate === selectedDate;
        });
    };

    const isEditable = (status: string) => {
        return ['CREATED', 'REMINDER_SENT', 'AWAITING_RESPONSE'].includes(status);
    };

    const renderScheduleItem = ({ item }: { item: Schedule }) => (
        <TouchableOpacity
            style={[styles.scheduleCard, { borderLeftColor: STATUS_COLORS[item.status] }]}
            onPress={() => isEditable(item.status) && navigation.navigate('EditSchedule', { schedule: item })}
        >
            <View style={styles.scheduleHeader}>
                <Text style={styles.workerName}>{item.worker.name}</Text>
                <View style={[styles.statusBadge, { backgroundColor: STATUS_COLORS[item.status] }]}>
                    <Text style={styles.statusText}>{STATUS_LABELS[item.status]}</Text>
                </View>
            </View>

            <Text style={styles.patientName}>Patient: {item.patient.name}</Text>
            <Text style={styles.medicineName}>{item.medicine.name}</Text>
            <Text style={styles.doseInfo}>
                {item.dose_amount} {item.medicine.dosage_unit}
            </Text>

            <View style={styles.timeContainer}>
                <Text style={styles.timeValue}>{format(parseISO(item.scheduled_time), 'h:mm a')}</Text>
            </View>

            {isEditable(item.status) && (
                <View style={styles.scheduleActions}>
                    <TouchableOpacity
                        style={styles.editBtn}
                        onPress={() => navigation.navigate('EditSchedule', { schedule: item })}
                    >
                        <Text style={styles.editBtnText}>Edit</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.deleteBtn}
                        onPress={() => handleDeleteSchedule(item)}
                    >
                        <Text style={styles.deleteBtnText}>Delete</Text>
                    </TouchableOpacity>
                </View>
            )}
        </TouchableOpacity>
    );

    const selectedDateSchedules = getSchedulesForSelectedDate();

    // Determine if the selected date is within the 2-week creation window
    const today = startOfDay(new Date());
    const maxCreateDate = addDays(today, 14);
    const selectedDateObj = parseISO(selectedDate);
    const canCreateSchedule = !isBefore(selectedDateObj, today) && !isAfter(selectedDateObj, maxCreateDate);

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <View style={styles.container}>
            <PasskeyModal
                visible={showPasskeyModal}
                onClose={() => { setShowPasskeyModal(false); setPendingDeleteId(null); }}
                onSuccess={handleDeletePasskeySuccess}
                onVerify={async (pin) => {
                    const isValid = await ApiService.verifyKey(pin);
                    if (isValid) {
                        verifiedDeletePinRef.current = pin;
                    }
                    return isValid;
                }}
                title="Master Key Required"
            />
            <Calendar
                current={selectedDate}
                onDayPress={onDayPress}
                markedDates={markedDates}
                maxDate={format(addDays(new Date(), 14), 'yyyy-MM-dd')}
                theme={{
                    calendarBackground: COLORS.white,
                    textSectionTitleColor: COLORS.text,
                    selectedDayBackgroundColor: COLORS.primary,
                    selectedDayTextColor: COLORS.white,
                    todayTextColor: COLORS.primary,
                    dayTextColor: COLORS.text,
                    textDisabledColor: COLORS.textLight,
                    dotColor: COLORS.primary,
                    selectedDotColor: COLORS.white,
                    arrowColor: COLORS.primary,
                    monthTextColor: COLORS.text,
                    textDayFontSize: FONT_SIZES.lg,
                    textMonthFontSize: FONT_SIZES.xl,
                    textDayHeaderFontSize: FONT_SIZES.md,
                }}
                style={styles.calendar}
            />

            <View style={styles.selectedDateHeader}>
                <Text style={styles.selectedDateText}>
                    {format(parseISO(selectedDate), 'EEEE, MMMM d, yyyy')}
                </Text>
                {canCreateSchedule && (
                    <TouchableOpacity
                        style={styles.addButton}
                        onPress={() => navigation.navigate('CreateSchedule', { date: selectedDate })}
                    >
                        <Text style={styles.addButtonText}>+ Add</Text>
                    </TouchableOpacity>
                )}
            </View>

            <FlatList
                data={selectedDateSchedules}
                renderItem={renderScheduleItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>📅</Text>
                        <Text style={styles.emptyText}>No schedules for this date</Text>
                        <Text style={styles.emptySubtext}>Tap "+ Add" to create one</Text>
                    </View>
                }
            />
        </View>
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
    calendar: {
        borderBottomWidth: 1,
        borderBottomColor: COLORS.border,
        paddingBottom: SPACING.md,
        maxHeight: 380,
    },
    selectedDateHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: SPACING.lg,
        backgroundColor: COLORS.white,
        borderBottomWidth: 1,
        borderBottomColor: COLORS.border,
    },
    selectedDateText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
        color: COLORS.text,
        flex: 1,
    },
    addButton: {
        backgroundColor: COLORS.primary,
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.md,
        borderRadius: 12,
        minHeight: 56,
        justifyContent: 'center',
    },
    addButtonText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.lg,
        fontWeight: '600',
    },
    listContainer: {
        padding: SPACING.md,
    },
    scheduleCard: {
        backgroundColor: COLORS.white,
        borderRadius: 16,
        padding: SPACING.xl,
        marginBottom: SPACING.md,
        borderLeftWidth: 6,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
        minHeight: 120,
    },
    scheduleHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: SPACING.md,
    },
    workerName: {
        fontSize: FONT_SIZES.xl,
        fontWeight: 'bold',
        color: COLORS.text,
        flex: 1,
    },
    statusBadge: {
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm,
        borderRadius: 8,
        minHeight: 40,
        justifyContent: 'center',
    },
    statusText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
    },
    medicineName: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.text,
        fontWeight: '600',
        marginBottom: SPACING.xs,
    },
    doseInfo: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
        marginBottom: SPACING.md,
    },
    timeContainer: {
        marginTop: SPACING.sm,
    },
    timeValue: {
        fontSize: FONT_SIZES.xxl,
        fontWeight: 'bold',
        color: COLORS.primary,
    },
    patientName: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
        marginBottom: SPACING.xs,
        fontWeight: '500',
    },
    scheduleActions: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        gap: SPACING.md,
        marginTop: SPACING.md,
        paddingTop: SPACING.md,
        borderTopWidth: 1,
        borderTopColor: COLORS.border,
    },
    editBtn: {
        backgroundColor: COLORS.primary,
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.sm,
        borderRadius: 8,
    },
    editBtnText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
    },
    deleteBtn: {
        backgroundColor: COLORS.error,
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.sm,
        borderRadius: 8,
    },
    deleteBtnText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
    },
    emptyContainer: {
        padding: SPACING.xl,
        alignItems: 'center',
        marginTop: SPACING.xxl,
    },
    emptyIcon: {
        fontSize: 64,
        marginBottom: SPACING.lg,
    },
    emptyText: {
        fontSize: FONT_SIZES.xl,
        color: COLORS.textLight,
        fontWeight: '600',
        marginBottom: SPACING.sm,
    },
    emptySubtext: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
    },
});
