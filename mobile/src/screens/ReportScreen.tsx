import React, { useState, useEffect, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    RefreshControl,
    ActivityIndicator,
} from 'react-native';
import ApiService from '../services/api.service';
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

interface DashboardStats {
    date: string;
    total: number;
    completed: number;
    not_done: number;
    missed: number;
    pending: number;
    completion_rate: number;
    low_stock_count: number;
}

interface WorkerPerf {
    worker_id: number;
    worker_name: string;
    total: number;
    completed: number;
    not_done: number;
    missed: number;
    late: number;
    completion_rate: number;
}

interface StockItem {
    id: number;
    name: string;
    current_stock: number;
    min_stock_level: number;
    dosage_unit: string;
    is_low: boolean;
}

export default function ReportScreen() {
    const [dashboard, setDashboard] = useState<DashboardStats | null>(null);
    const [workerPerf, setWorkerPerf] = useState<WorkerPerf[]>([]);
    const [stockSummary, setStockSummary] = useState<StockItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);

    const loadData = useCallback(async () => {
        try {
            const [dash, workers, stock] = await Promise.all([
                ApiService.getDashboard(),
                ApiService.getWorkerPerformance(),
                ApiService.getStockSummary(),
            ]);
            setDashboard(dash);
            setWorkerPerf(workers);
            setStockSummary(stock);
        } catch (error) {
            console.error('Error loading report data:', error);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => { loadData(); }, [loadData]);

    const onRefresh = () => {
        setRefreshing(true);
        loadData();
    };

    if (loading) {
        return (
            <View style={styles.centered}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    const StatCard = ({ label, value, color, icon }: { label: string; value: number | string; color: string; icon: string }) => (
        <View style={[styles.statCard, { borderLeftColor: color }]}>
            <Text style={styles.statIcon}>{icon}</Text>
            <Text style={[styles.statValue, { color }]}>{value}</Text>
            <Text style={styles.statLabel}>{label}</Text>
        </View>
    );

    return (
        <ScrollView
            style={styles.container}
            refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        >
            {/* Today's Summary */}
            <Text style={styles.sectionTitle}>Today's Summary</Text>
            {dashboard && (
                <>
                    <View style={styles.statRow}>
                        <StatCard label="Total" value={dashboard.total} color="#3B82F6" icon="📊" />
                        <StatCard label="Completed" value={dashboard.completed} color="#10B981" icon="✅" />
                    </View>
                    <View style={styles.statRow}>
                        <StatCard label="Not Given" value={dashboard.not_done} color="#F59E0B" icon="⚠️" />
                        <StatCard label="Missed" value={dashboard.missed} color="#EF4444" icon="❌" />
                    </View>
                    <View style={styles.statRow}>
                        <StatCard label="Pending" value={dashboard.pending} color="#8B5CF6" icon="⏳" />
                        <StatCard label="Rate" value={`${dashboard.completion_rate}%`} color="#06B6D4" icon="📈" />
                    </View>
                </>
            )}

            {/* Worker Performance */}
            <Text style={styles.sectionTitle}>Worker Performance (30d)</Text>
            {workerPerf.length === 0 ? (
                <Text style={styles.emptyText}>No worker data yet</Text>
            ) : (
                workerPerf.map((w) => (
                    <View key={w.worker_id} style={styles.workerCard}>
                        <View style={styles.workerHeader}>
                            <Text style={styles.workerName}>{w.worker_name}</Text>
                            <Text style={[
                                styles.workerRate,
                                { color: w.completion_rate >= 80 ? '#10B981' : w.completion_rate >= 50 ? '#F59E0B' : '#EF4444' }
                            ]}>
                                {w.completion_rate}%
                            </Text>
                        </View>
                        <View style={styles.workerBar}>
                            <View style={[styles.barSegment, { flex: w.completed, backgroundColor: '#10B981' }]} />
                            <View style={[styles.barSegment, { flex: w.late, backgroundColor: '#F59E0B' }]} />
                            <View style={[styles.barSegment, { flex: w.not_done + w.missed, backgroundColor: '#EF4444' }]} />
                            {w.total === 0 && <View style={[styles.barSegment, { flex: 1, backgroundColor: '#E5E7EB' }]} />}
                        </View>
                        <Text style={styles.workerStats}>
                            {w.completed} done · {w.late} late · {w.not_done} skipped · {w.missed} missed
                        </Text>
                    </View>
                ))
            )}

            {/* Stock Status */}
            <Text style={styles.sectionTitle}>Stock Status</Text>
            {stockSummary.length === 0 ? (
                <Text style={styles.emptyText}>No medicines added yet</Text>
            ) : (
                stockSummary.map((s) => (
                    <View key={s.id} style={[styles.stockCard, s.is_low && styles.stockLow]}>
                        <View style={styles.stockRow}>
                            <Text style={styles.stockName}>
                                {s.is_low ? '⚠️ ' : '💊 '}{s.name}
                            </Text>
                            <Text style={[
                                styles.stockCount,
                                { color: s.is_low ? '#EF4444' : '#10B981' }
                            ]}>
                                {s.current_stock} {s.dosage_unit}
                            </Text>
                        </View>
                        {s.is_low && (
                            <Text style={styles.stockWarning}>
                                Below minimum ({s.min_stock_level} {s.dosage_unit})
                            </Text>
                        )}
                    </View>
                ))
            )}

            <View style={{ height: 40 }} />
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
        padding: SPACING.md,
    },
    centered: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    sectionTitle: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
        marginTop: SPACING.lg,
        marginBottom: SPACING.sm,
    },
    emptyText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        fontStyle: 'italic',
        paddingVertical: SPACING.md,
    },

    // Stat cards
    statRow: {
        flexDirection: 'row',
        gap: SPACING.sm,
        marginBottom: SPACING.sm,
    },
    statCard: {
        flex: 1,
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        borderLeftWidth: 4,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
        elevation: 1,
    },
    statIcon: {
        fontSize: 20,
        marginBottom: 4,
    },
    statValue: {
        fontSize: 24,
        fontWeight: '800',
    },
    statLabel: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        marginTop: 2,
    },

    // Worker cards
    workerCard: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        marginBottom: SPACING.sm,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
        elevation: 1,
    },
    workerHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 8,
    },
    workerName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.text,
    },
    workerRate: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '800',
    },
    workerBar: {
        flexDirection: 'row',
        height: 6,
        borderRadius: 3,
        overflow: 'hidden',
        backgroundColor: '#E5E7EB',
        marginBottom: 6,
    },
    barSegment: {
        height: '100%',
    },
    workerStats: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
    },

    // Stock cards
    stockCard: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        marginBottom: SPACING.sm,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
        elevation: 1,
    },
    stockLow: {
        borderLeftWidth: 3,
        borderLeftColor: '#EF4444',
        backgroundColor: '#FFF5F5',
    },
    stockRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    stockName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.text,
        flex: 1,
    },
    stockCount: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '800',
    },
    stockWarning: {
        fontSize: FONT_SIZES.xs,
        color: '#EF4444',
        marginTop: 4,
    },
});
