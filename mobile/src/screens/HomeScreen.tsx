import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    TouchableOpacity,
    RefreshControl,
    ActivityIndicator,
    AppState,
} from 'react-native';
import { format } from 'date-fns';
import ApiService from '../services/api.service';
import { Schedule } from '../types';
import {
    COLORS, SPACING, FONT_SIZES, FONT_WEIGHTS,
    STATUS_COLORS, STATUS_BG_COLORS, STATUS_LABELS,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

const AUTO_REFRESH_INTERVAL = 30000;

// ─── Status CTA config ────────────────────────────────────────
const STATUS_CTA: Record<string, { label: string; icon: string; color: string }> = {
    CREATED:            { label: 'Begin',  icon: '▶',  color: COLORS.primary },
    REMINDER_SENT:      { label: 'Begin',  icon: '▶',  color: COLORS.primary },
    AWAITING_RESPONSE:  { label: 'Begin',  icon: '▶',  color: COLORS.yellow },
    NOT_DONE:           { label: 'Check',  icon: '❗', color: COLORS.red },
    EXPIRED:            { label: 'Check',  icon: '❗', color: COLORS.red },
    COMPLETED:          { label: '',       icon: '✓',  color: COLORS.green },
    LATE_COMPLETED:     { label: '',       icon: '✓',  color: COLORS.orange },
};

// ─── Medicine icons (rotating set) ─────────────────────────────
const MED_ICONS = ['💊', '🩺', '🏥', '🩹'];

export default function HomeScreen({ navigation }: any) {
    const [todaySchedules, setTodaySchedules] = useState<Schedule[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

    const loadTodaySchedules = useCallback(async () => {
        try {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const tomorrow = new Date(today);
            tomorrow.setDate(tomorrow.getDate() + 1);

            const data = await ApiService.getSchedules({
                date_from: today.toISOString(),
                date_to: tomorrow.toISOString(),
            });
            setTodaySchedules(data);
        } catch (error) {
            console.error('Failed to load schedules:', error);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        loadTodaySchedules();
        intervalRef.current = setInterval(loadTodaySchedules, AUTO_REFRESH_INTERVAL);
        const appStateSub = AppState.addEventListener('change', (state) => {
            if (state === 'active') loadTodaySchedules();
        });
        return () => {
            if (intervalRef.current) clearInterval(intervalRef.current);
            appStateSub.remove();
        };
    }, [loadTodaySchedules]);

    const onRefresh = () => {
        setRefreshing(true);
        loadTodaySchedules();
    };

    // ─── Derived data ─────────────────────────────────────────────
    const now = new Date();
    const hour = now.getHours();
    const timeOfDay = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    const remaining = todaySchedules.filter(s =>
        !['COMPLETED', 'LATE_COMPLETED'].includes(s.status)
    ).length;

    const isCompleted = (status: string) =>
        ['COMPLETED', 'LATE_COMPLETED'].includes(status);

    const isFutureLocked = (item: Schedule) => {
        const scheduledTime = new Date(item.scheduled_time);
        const hoursFromNow = (scheduledTime.getTime() - now.getTime()) / (1000 * 60 * 60);
        return hoursFromNow > 2 && !isCompleted(item.status);
    };

    // ─── Card renderer ────────────────────────────────────────────
    const renderScheduleItem = ({ item, index }: { item: Schedule; index: number }) => {
        const completed = isCompleted(item.status);
        const locked = isFutureLocked(item);
        const statusColor = STATUS_COLORS[item.status] || COLORS.gray;
        const cta = STATUS_CTA[item.status] || { label: 'View', icon: '→', color: COLORS.primary };
        const medIcon = MED_ICONS[index % MED_ICONS.length];

        return (
            <View style={[
                styles.taskCard,
                { borderLeftColor: statusColor },
                completed && styles.taskCardCompleted,
                locked && styles.taskCardLocked,
            ]}>
                {/* Time + Status badge */}
                <View style={styles.taskHeaderRow}>
                    <Text style={[
                        styles.taskTime,
                        { color: locked ? COLORS.textLight : statusColor },
                        completed && { color: COLORS.textLight },
                    ]}>
                        {format(new Date(item.scheduled_time), 'hh:mm a')}
                    </Text>
                    {!locked && (
                        <View style={[styles.statusBadge, { backgroundColor: STATUS_BG_COLORS[item.status] }]}>
                            <Text style={[styles.statusBadgeText, { color: statusColor }]}>
                                {STATUS_LABELS[item.status]}
                            </Text>
                        </View>
                    )}
                </View>

                {/* Patient name */}
                <Text style={[
                    styles.taskPatient,
                    completed && { color: COLORS.textLight },
                    locked && { color: COLORS.textLight },
                ]}>
                    {item.patient?.name || 'Unknown Patient'}
                </Text>

                {/* Medicine info */}
                <View style={styles.taskMedRow}>
                    <Text style={styles.taskMedIcon}>{medIcon}</Text>
                    <Text style={[
                        styles.taskMedicine,
                        completed && { color: COLORS.textLight },
                        locked && { color: COLORS.textHint },
                    ]}>
                        {item.medicine?.name || 'Medicine'} - {item.dose_amount}{item.medicine?.dosage_unit || 'mg'}
                    </Text>
                </View>

                {/* CTA button or status icon */}
                {completed ? (
                    <View style={styles.completedIcon}>
                        <View style={styles.completedCircle}>
                            <Text style={styles.completedCheck}>✓</Text>
                        </View>
                    </View>
                ) : locked ? (
                    <View style={styles.lockedIcon}>
                        <View style={styles.lockedCircle}>
                            <Text style={{ fontSize: 16, color: COLORS.textLight }}>🔒</Text>
                        </View>
                    </View>
                ) : (
                    <TouchableOpacity
                        style={[styles.ctaButton, { backgroundColor: cta.color }]}
                        activeOpacity={0.8}
                    >
                        <Text style={styles.ctaButtonText}>
                            {cta.label}  {cta.icon}
                        </Text>
                    </TouchableOpacity>
                )}
            </View>
        );
    };

    // ─── Empty state ──────────────────────────────────────────────
    const EmptyState = () => (
        <View style={styles.emptyState}>
            <Text style={styles.emptyIcon}>✅</Text>
            <Text style={styles.emptyText}>No tasks for today</Text>
            <Text style={styles.emptySubtext}>All clear! Enjoy your day.</Text>
        </View>
    );

    // ─── Header section ───────────────────────────────────────────
    const ListHeader = () => (
        <View style={styles.headerSection}>
            <Text style={styles.dateLabel}>
                {format(now, 'EEEE, MMM d').toUpperCase()}
            </Text>
            <Text style={styles.heroTitle}>Today's Tasks</Text>
            <View style={styles.remainingRow}>
                <View style={styles.remainingDot} />
                <Text style={styles.remainingText}>
                    {remaining} task{remaining !== 1 ? 's' : ''} remaining for this {timeOfDay}
                </Text>
            </View>
        </View>
    );

    // ─── Footer help tip ──────────────────────────────────────────
    const ListFooter = () => (
        <View style={styles.helpTip}>
            <Text style={styles.helpIcon}>❓</Text>
            <View style={{ flex: 1 }}>
                <Text style={styles.helpTitle}>Need help?</Text>
                <Text style={styles.helpText}>
                    Tap on any card to see more details about the patient and their medication schedule.
                </Text>
            </View>
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
            <FlatList
                data={todaySchedules}
                renderItem={renderScheduleItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.taskList}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListHeaderComponent={<ListHeader />}
                ListEmptyComponent={<EmptyState />}
                ListFooterComponent={todaySchedules.length > 0 ? <ListFooter /> : null}
                showsVerticalScrollIndicator={false}
            />

            {/* FAB */}
            <TouchableOpacity
                style={styles.fab}
                onPress={() => navigation.navigate('CreateSchedule')}
                activeOpacity={0.85}
            >
                <Text style={styles.fabText}>+</Text>
            </TouchableOpacity>
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
        backgroundColor: COLORS.background,
    },
    taskList: {
        paddingBottom: 100,
        flexGrow: 1,
    },

    // ─── Header Section ─────────────────────────────────────────
    headerSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.lg,
        paddingBottom: SPACING.md,
    },
    dateLabel: {
        ...SECTION_HEADER_STYLE,
        color: COLORS.textSecondary,
        marginBottom: SPACING.xs,
    },
    heroTitle: {
        fontSize: 32,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    remainingRow: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    remainingDot: {
        width: 8,
        height: 8,
        borderRadius: 4,
        backgroundColor: COLORS.primary,
        marginRight: SPACING.sm,
    },
    remainingText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
    },

    // ─── Task Card ──────────────────────────────────────────────
    taskCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.md,
        borderLeftWidth: 4,
        ...CARD_SHADOW,
    },
    taskCardCompleted: {
        opacity: 0.75,
    },
    taskCardLocked: {
        opacity: 0.55,
    },
    taskHeaderRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: SPACING.sm,
    },
    taskTime: {
        fontSize: FONT_SIZES.xl,
        fontWeight: '800',
        marginRight: SPACING.sm,
    },
    statusBadge: {
        paddingHorizontal: SPACING.sm,
        paddingVertical: 3,
        borderRadius: 6,
    },
    statusBadgeText: {
        fontSize: 10,
        fontWeight: '700',
        letterSpacing: 0.5,
        textTransform: 'uppercase',
    },
    taskPatient: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 4,
    },
    taskMedRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: SPACING.md,
    },
    taskMedIcon: {
        fontSize: 16,
        marginRight: SPACING.sm,
    },
    taskMedicine: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
    },

    // ─── CTA Button ─────────────────────────────────────────────
    ctaButton: {
        borderRadius: BORDER_RADIUS.full,
        paddingVertical: 14,
        alignItems: 'center',
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.2,
        shadowRadius: 8,
        elevation: 3,
    },
    ctaButtonText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
    },

    // ─── Completed / Locked icons ───────────────────────────────
    completedIcon: {
        position: 'absolute',
        bottom: SPACING.md,
        right: SPACING.md,
    },
    completedCircle: {
        width: 32,
        height: 32,
        borderRadius: 16,
        backgroundColor: COLORS.greenLight,
        justifyContent: 'center',
        alignItems: 'center',
    },
    completedCheck: {
        fontSize: 16,
        fontWeight: '800',
        color: COLORS.green,
    },
    lockedIcon: {
        marginTop: SPACING.xs,
    },
    lockedCircle: {
        width: 32,
        height: 32,
        borderRadius: 16,
        backgroundColor: COLORS.surfaceContainerHighest,
        justifyContent: 'center',
        alignItems: 'center',
    },

    // ─── Empty State ────────────────────────────────────────────
    emptyState: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        paddingVertical: SPACING.xxl * 2,
    },
    emptyIcon: {
        fontSize: 48,
        marginBottom: SPACING.sm,
    },
    emptyText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '600',
        color: COLORS.text,
        marginBottom: 4,
    },
    emptySubtext: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
    },

    // ─── Help Tip ───────────────────────────────────────────────
    helpTip: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginHorizontal: SPACING.md,
        marginTop: SPACING.lg,
        paddingVertical: SPACING.md,
    },
    helpIcon: {
        fontSize: 22,
        marginRight: SPACING.sm,
        marginTop: 2,
    },
    helpTitle: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    helpText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
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
