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
import { COLORS, SPACING, FONT_SIZES, STATUS_COLORS, STATUS_LABELS } from '../constants/theme';

const AUTO_REFRESH_INTERVAL = 30000; // 30 seconds

export default function HomeScreen({ navigation }: any) {
    const [todaySchedules, setTodaySchedules] = useState<Schedule[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

    // Add notifications bell to header
    useEffect(() => {
        navigation.setOptions({
            headerRight: () => (
                <TouchableOpacity
                    onPress={() => navigation.navigate('NotificationsScreen')}
                    style={{ marginRight: 16 }}
                >
                    <Text style={{ fontSize: 22 }}>🔔</Text>
                </TouchableOpacity>
            ),
        });
    }, [navigation]);

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

        // Auto-refresh every 30 seconds
        intervalRef.current = setInterval(loadTodaySchedules, AUTO_REFRESH_INTERVAL);

        // Refresh when app returns from background
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

    const QuickButton = ({
        title,
        icon,
        color,
        onPress
    }: {
        title: string;
        icon: string;
        color: string;
        onPress: () => void;
    }) => (
        <TouchableOpacity
            style={[styles.quickBtn, { backgroundColor: color }]}
            onPress={onPress}
            activeOpacity={0.7}
        >
            <Text style={styles.quickBtnIcon}>{icon}</Text>
            <Text style={styles.quickBtnTitle}>{title}</Text>
        </TouchableOpacity>
    );

    const renderScheduleItem = ({ item }: { item: Schedule }) => (
        <View style={[styles.taskCard, { borderLeftColor: STATUS_COLORS[item.status] }]}>
            <View style={styles.taskRow}>
                <View style={styles.taskInfo}>
                    <Text style={styles.taskWorker}>{item.worker.name}</Text>
                    <Text style={styles.taskMedicine}>
                        {item.medicine.name} · {item.dose_amount} {item.medicine.dosage_unit}
                    </Text>
                </View>
                <View style={styles.taskRight}>
                    <Text style={styles.taskTime}>
                        {format(new Date(item.scheduled_time), 'h:mm a')}
                    </Text>
                    <View style={[styles.statusDot, { backgroundColor: STATUS_COLORS[item.status] }]}>
                        <Text style={styles.statusDotText}>
                            {STATUS_LABELS[item.status]}
                        </Text>
                    </View>
                </View>
            </View>
        </View>
    );

    const EmptyState = () => (
        <View style={styles.emptyState}>
            <Text style={styles.emptyIcon}>✅</Text>
            <Text style={styles.emptyText}>No tasks for today</Text>
            <Text style={styles.emptySubtext}>All clear!</Text>
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
            {/* Tasks Section — fills available space */}
            <View style={styles.tasksSection}>
                <Text style={styles.sectionLabel}>
                    Today's Tasks
                    {todaySchedules.length > 0 && (
                        <Text style={styles.taskCount}> ({todaySchedules.length})</Text>
                    )}
                </Text>

                <FlatList
                    data={todaySchedules}
                    renderItem={renderScheduleItem}
                    keyExtractor={(item) => item.id.toString()}
                    contentContainerStyle={styles.taskList}
                    refreshControl={
                        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                    }
                    ListEmptyComponent={<EmptyState />}
                    showsVerticalScrollIndicator={false}
                />
            </View>

            {/* Quick Access — fixed at bottom */}
            <View style={styles.quickSection}>
                <QuickButton
                    title="Patients"
                    icon="👥"
                    color="#3B82F6"
                    onPress={() => navigation.getParent()?.navigate('More', { screen: 'PatientsScreen' })}
                />
                <QuickButton
                    title="Workers"
                    icon="👷"
                    color="#10B981"
                    onPress={() => navigation.getParent()?.navigate('More', { screen: 'WorkersScreen' })}
                />
                <QuickButton
                    title="Stock"
                    icon="💊"
                    color="#8B5CF6"
                    onPress={() => navigation.getParent()?.navigate('Medicines')}
                />
                <QuickButton
                    title="Calendar"
                    icon="📅"
                    color="#F59E0B"
                    onPress={() => navigation.getParent()?.navigate('Schedules')}
                />
            </View>
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

    // Tasks Section
    tasksSection: {
        flex: 1,
        paddingHorizontal: SPACING.md,
        paddingTop: SPACING.md,
    },
    sectionLabel: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: SPACING.sm,
        paddingHorizontal: SPACING.xs,
    },
    taskCount: {
        color: COLORS.textLight,
        fontWeight: '500',
    },
    taskList: {
        paddingBottom: SPACING.sm,
        flexGrow: 1,
    },

    // Task Card — compact
    taskCard: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        marginBottom: SPACING.sm,
        borderLeftWidth: 4,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
        elevation: 1,
    },
    taskRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    taskInfo: {
        flex: 1,
        marginRight: SPACING.sm,
    },
    taskWorker: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    taskMedicine: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
    },
    taskRight: {
        alignItems: 'flex-end',
    },
    taskTime: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.primary,
        marginBottom: 4,
    },
    statusDot: {
        paddingHorizontal: SPACING.sm,
        paddingVertical: 3,
        borderRadius: 6,
    },
    statusDotText: {
        color: COLORS.white,
        fontSize: 11,
        fontWeight: '600',
    },

    // Empty State
    emptyState: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        paddingVertical: SPACING.xxl,
    },
    emptyIcon: {
        fontSize: 40,
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

    // Quick Access — horizontal strip at bottom
    quickSection: {
        flexDirection: 'row',
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm,
        paddingBottom: SPACING.md,
        gap: SPACING.sm,
        backgroundColor: COLORS.white,
        borderTopWidth: 1,
        borderTopColor: '#F0F0F0',
    },
    quickBtn: {
        flex: 1,
        borderRadius: 12,
        paddingVertical: SPACING.sm + 2,
        alignItems: 'center',
        justifyContent: 'center',
    },
    quickBtnIcon: {
        fontSize: 20,
        marginBottom: 2,
    },
    quickBtnTitle: {
        fontSize: 11,
        fontWeight: '700',
        color: COLORS.white,
    },
});
