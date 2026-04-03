import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
    View,
    Text,
    StyleSheet,
    SectionList,
    TouchableOpacity,
    RefreshControl,
    ActivityIndicator,
    Alert,
    AppState,
    Dimensions,
} from 'react-native';
import { format, parseISO, addDays, startOfWeek, isBefore, isAfter, startOfDay, differenceInHours, isSameDay } from 'date-fns';
import ApiService from '../services/api.service';
import PasskeyModal from '../components/PasskeyModal';
import { Schedule } from '../types';
import {
    COLORS, SPACING, FONT_SIZES,
    STATUS_COLORS, STATUS_LABELS,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

const SCREEN_WIDTH = Dimensions.get('window').width;
const DAY_WIDTH = (SCREEN_WIDTH - 48) / 7;

export default function SchedulesScreen({ navigation }: any) {
    const [schedules, setSchedules] = useState<Schedule[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [selectedDate, setSelectedDate] = useState(new Date());
    const [weekOffset, setWeekOffset] = useState(0);
    const [showPasskeyModal, setShowPasskeyModal] = useState(false);
    const [pendingDeleteId, setPendingDeleteId] = useState<number | null>(null);
    const verifiedDeletePinRef = React.useRef<string | null>(null);

    const loadSchedules = useCallback(async () => {
        try {
            const data = await ApiService.getSchedules();
            setSchedules(data);
        } catch (error) {
            console.error('Failed to load schedules:', error);
            Alert.alert('Error', 'Failed to load schedules');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        loadSchedules();
        const interval = setInterval(loadSchedules, 30000);
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

    // ─── Week Strip Logic ─────────────────────────────────────────────────────
    const getWeekDays = () => {
        const today = new Date();
        const weekStart = startOfWeek(addDays(today, weekOffset * 7), { weekStartsOn: 1 });
        return Array.from({ length: 7 }, (_, i) => addDays(weekStart, i));
    };

    const weekDays = getWeekDays();

    const goToToday = () => {
        setWeekOffset(0);
        setSelectedDate(new Date());
    };

    const getScheduleCountForDate = (date: Date) => {
        const dateStr = format(date, 'yyyy-MM-dd');
        return schedules.filter(s => format(parseISO(s.scheduled_time), 'yyyy-MM-dd') === dateStr).length;
    };

    const selectedDateStr = format(selectedDate, 'yyyy-MM-dd');

    // ─── Delete Logic ─────────────────────────────────────────────────────────
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

    // ─── Filtered + Grouped Schedules ─────────────────────────────────────────
    const selectedDateSchedules = schedules.filter(schedule => {
        const scheduleDate = format(parseISO(schedule.scheduled_time), 'yyyy-MM-dd');
        return scheduleDate === selectedDateStr;
    });

    // Group into Morning (before 12) / Afternoon shifts
    const morningSchedules = selectedDateSchedules.filter(s => {
        const hour = new Date(s.scheduled_time).getHours();
        return hour < 12;
    });
    const afternoonSchedules = selectedDateSchedules.filter(s => {
        const hour = new Date(s.scheduled_time).getHours();
        return hour >= 12;
    });

    const sections = [
        ...(morningSchedules.length > 0 ? [{ title: 'MORNING SHIFT', icon: '🌅', data: morningSchedules }] : []),
        ...(afternoonSchedules.length > 0 ? [{ title: 'AFTERNOON SHIFT', icon: '☀️', data: afternoonSchedules }] : []),
    ];

    const isEditable = (status: string) => {
        return ['CREATED', 'REMINDER_SENT', 'AWAITING_RESPONSE'].includes(status);
    };

    const today = startOfDay(new Date());
    const maxCreateDate = addDays(today, 14);
    const canCreateSchedule = !isBefore(startOfDay(selectedDate), today) && !isAfter(startOfDay(selectedDate), maxCreateDate);

    // ─── Avatar initials ──────────────────────────────────────────────────────
    const getInitials = (name: string) => {
        const parts = name.split(' ');
        return parts.length > 1
            ? `${parts[0][0]}${parts[1][0]}`.toUpperCase()
            : name.substring(0, 2).toUpperCase();
    };

    // ─── Render ───────────────────────────────────────────────────────────────
    const renderScheduleItem = ({ item }: { item: Schedule }) => {
        const statusColor = STATUS_COLORS[item.status] || COLORS.gray;
        const isAdministered = ['COMPLETED', 'LATE_COMPLETED'].includes(item.status);

        return (
            <TouchableOpacity
                style={[styles.scheduleCard, { borderLeftColor: statusColor }]}
                onPress={() => isEditable(item.status) && navigation.navigate('EditSchedule', { schedule: item })}
                activeOpacity={0.7}
            >
                <View style={styles.cardContent}>
                    {/* Avatar */}
                    <View style={[styles.avatar, { borderColor: statusColor }]}>
                        <Text style={styles.avatarText}>{getInitials(item.worker?.name || 'W')}</Text>
                    </View>

                    {/* Info */}
                    <View style={styles.cardInfo}>
                        <Text style={styles.workerName}>{item.worker?.name || 'Worker'}</Text>
                        <Text style={styles.medicineName}>
                            {item.medicine?.name || 'Medicine'} {item.dose_amount}{item.medicine?.dosage_unit || 'mg'}
                        </Text>
                        <View style={styles.patientRow}>
                            <Text style={styles.patientIcon}>🏥</Text>
                            <Text style={styles.patientName}>{item.patient?.name || 'Patient'}</Text>
                        </View>
                    </View>

                    {/* Time + Status */}
                    <View style={styles.cardRight}>
                        <Text style={[styles.timeValue, { color: statusColor }]}>
                            {format(parseISO(item.scheduled_time), 'hh:mm a')}
                        </Text>
                        <View style={[
                            styles.statusPill,
                            isAdministered
                                ? { backgroundColor: statusColor }
                                : { borderColor: statusColor, borderWidth: 1.5 }
                        ]}>
                            {isAdministered && <Text style={styles.statusCheck}>✓ </Text>}
                            <Text style={[
                                styles.statusPillText,
                                isAdministered ? { color: COLORS.white } : { color: statusColor }
                            ]}>
                                {STATUS_LABELS[item.status]}
                            </Text>
                        </View>
                    </View>
                </View>

                {/* Action buttons */}
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
    };

    const renderSectionHeader = ({ section }: { section: { title: string; icon: string } }) => (
        <View style={styles.shiftHeader}>
            <View style={styles.shiftHeaderLine} />
            <Text style={styles.shiftIcon}>{section.icon}</Text>
            <Text style={styles.shiftLabel}>{section.title}</Text>
        </View>
    );

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

            {/* ─── Title section ────────────────────────────────────── */}
            <View style={styles.titleSection}>
                <Text style={styles.heroTitle}>Daily Schedules</Text>
                <Text style={styles.heroSubtitle}>
                    Regional District A • {format(weekDays[3], 'MMMM yyyy')}
                </Text>
            </View>

            {/* ─── Week Strip ──────────────────────────────────────── */}
            <View style={styles.weekStrip}>
                {weekDays.map((day, i) => {
                    const isSelected = isSameDay(day, selectedDate);
                    const isToday = isSameDay(day, new Date());
                    const count = getScheduleCountForDate(day);
                    return (
                        <TouchableOpacity
                            key={i}
                            style={[
                                styles.dayPill,
                                isSelected && styles.dayPillSelected,
                                isToday && !isSelected && styles.dayPillToday,
                            ]}
                            onPress={() => setSelectedDate(day)}
                            activeOpacity={0.7}
                        >
                            <Text style={[
                                styles.dayLabel,
                                isSelected && styles.dayLabelSelected,
                            ]}>
                                {format(day, 'EEE').toUpperCase()}
                            </Text>
                            <Text style={[
                                styles.dayNumber,
                                isSelected && styles.dayNumberSelected,
                                isToday && !isSelected && styles.dayNumberToday,
                            ]}>
                                {format(day, 'd')}
                            </Text>
                            {count > 0 && !isSelected && (
                                <View style={styles.dotIndicator} />
                            )}
                        </TouchableOpacity>
                    );
                })}
            </View>

            {/* ─── Schedule List ────────────────────────────────────── */}
            <SectionList
                sections={sections}
                renderItem={renderScheduleItem}
                renderSectionHeader={renderSectionHeader}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>📅</Text>
                        <Text style={styles.emptyText}>No schedules</Text>
                        <Text style={styles.emptySubtext}>
                            {canCreateSchedule ? 'Tap + to create one' : 'Select a date to view schedules'}
                        </Text>
                    </View>
                }
                stickySectionHeadersEnabled={false}
            />

            {/* ─── FAB ─────────────────────────────────────────────── */}
            {canCreateSchedule && (
                <TouchableOpacity
                    style={styles.fab}
                    onPress={() => navigation.navigate('CreateSchedule', { date: selectedDateStr })}
                    activeOpacity={0.85}
                >
                    <Text style={styles.fabText}>+</Text>
                </TouchableOpacity>
            )}
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

    // ─── Title Section ─────────────────────────────────────────
    titleSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.sm,
        backgroundColor: COLORS.white,
    },
    heroTitle: {
        fontSize: 28,
        fontWeight: '800',
        color: COLORS.text,
    },
    heroSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        marginTop: 4,
    },

    // ─── Week Strip ────────────────────────────────────────────
    weekStrip: {
        flexDirection: 'row',
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.md,
        backgroundColor: COLORS.white,
        justifyContent: 'space-between',
    },
    dayPill: {
        width: DAY_WIDTH,
        alignItems: 'center',
        paddingVertical: SPACING.sm,
        borderRadius: BORDER_RADIUS.md,
        backgroundColor: COLORS.grayLight,
    },
    dayPillSelected: {
        backgroundColor: COLORS.primary,
    },
    dayPillToday: {
        borderColor: COLORS.primary,
        borderWidth: 1.5,
        backgroundColor: COLORS.white,
    },
    dayLabel: {
        fontSize: 10,
        fontWeight: '700',
        color: COLORS.textLight,
        letterSpacing: 0.5,
        marginBottom: 4,
    },
    dayLabelSelected: {
        color: 'rgba(255,255,255,0.8)',
    },
    dayNumber: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '800',
        color: COLORS.text,
    },
    dayNumberSelected: {
        color: COLORS.white,
    },
    dayNumberToday: {
        color: COLORS.primary,
    },
    dotIndicator: {
        width: 5,
        height: 5,
        borderRadius: 2.5,
        backgroundColor: COLORS.primary,
        marginTop: 4,
    },

    // ─── Shift Headers ──────────────────────────────────────────
    shiftHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.lg,
        paddingBottom: SPACING.sm,
    },
    shiftHeaderLine: {
        width: 3,
        height: 20,
        backgroundColor: COLORS.primary,
        borderRadius: 2,
        marginRight: SPACING.sm,
    },
    shiftIcon: {
        fontSize: 16,
        marginRight: SPACING.xs,
    },
    shiftLabel: {
        ...SECTION_HEADER_STYLE,
        marginBottom: 0,
        color: COLORS.textSecondary,
    },

    // ─── Schedule Cards ─────────────────────────────────────────
    listContainer: {
        paddingBottom: 100,
    },
    scheduleCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.md,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.sm,
        borderLeftWidth: 4,
        ...CARD_SHADOW,
    },
    cardContent: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    avatar: {
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: COLORS.grayLight,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
        borderWidth: 2,
    },
    avatarText: {
        fontSize: 14,
        fontWeight: '700',
        color: COLORS.textSecondary,
    },
    cardInfo: {
        flex: 1,
    },
    workerName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    medicineName: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        marginBottom: 4,
    },
    patientRow: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    patientIcon: {
        fontSize: 12,
        marginRight: 4,
    },
    patientName: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        fontWeight: '500',
    },
    cardRight: {
        alignItems: 'flex-end',
        marginLeft: SPACING.sm,
    },
    timeValue: {
        fontSize: FONT_SIZES.sm,
        fontWeight: '700',
        marginBottom: 6,
    },
    statusPill: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
        borderRadius: BORDER_RADIUS.full,
    },
    statusCheck: {
        color: COLORS.white,
        fontSize: 10,
        fontWeight: '700',
    },
    statusPillText: {
        fontSize: 9,
        fontWeight: '700',
        letterSpacing: 0.5,
        textTransform: 'uppercase',
    },

    // ─── Actions ────────────────────────────────────────────────
    scheduleActions: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        gap: SPACING.sm,
        marginTop: SPACING.md,
        paddingTop: SPACING.sm,
    },
    editBtn: {
        backgroundColor: COLORS.primary,
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.sm,
        borderRadius: BORDER_RADIUS.xl,
    },
    editBtnText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.sm,
        fontWeight: '600',
    },
    deleteBtn: {
        backgroundColor: COLORS.error,
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.sm,
        borderRadius: BORDER_RADIUS.xl,
    },
    deleteBtnText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.sm,
        fontWeight: '600',
    },

    // ─── Empty State ────────────────────────────────────────────
    emptyContainer: {
        padding: SPACING.xl,
        alignItems: 'center',
        marginTop: SPACING.xxl,
    },
    emptyIcon: {
        fontSize: 48,
        marginBottom: SPACING.md,
    },
    emptyText: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.textLight,
        fontWeight: '600',
        marginBottom: SPACING.xs,
    },
    emptySubtext: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
    },

    // ─── FAB ────────────────────────────────────────────────────
    fab: {
        position: 'absolute',
        bottom: 90,
        right: 24,
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.35,
        shadowRadius: 8,
        elevation: 8,
    },
    fabText: {
        fontSize: 28,
        color: COLORS.white,
        fontWeight: '300',
        marginTop: -2,
    },
});
