import React, { useState, useEffect, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    RefreshControl,
    ActivityIndicator,
    TouchableOpacity,
} from 'react-native';
import ApiService from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

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

const STAT_CONFIGS = [
    { key: 'total', label: 'TOTAL', icon: '📋', color: '#3B82F6' },
    { key: 'completed', label: 'COMPLETED', icon: '✅', color: '#10B981' },
    { key: 'not_done', label: 'NOT GIVEN', icon: '⚠️', color: '#F59E0B' },
    { key: 'missed', label: 'MISSED', icon: '❌', color: '#EF4444' },
    { key: 'pending', label: 'PENDING', icon: '⏳', color: '#8B5CF6' },
    { key: 'completion_rate', label: 'RATE %', icon: '📈', color: '#06B6D4', suffix: '%' },
];

const STOCK_ICONS = ['💊', '🧬', '💉'];

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

    const getStockStatus = (item: StockItem) => {
        if (item.is_low && item.current_stock <= 15) return { label: 'CRITICAL', color: '#EF4444' };
        if (item.is_low) return { label: 'LOW STOCK', color: '#F59E0B' };
        return { label: 'STABLE', color: '#10B981' };
    };

    return (
        <ScrollView
            style={styles.container}
            contentContainerStyle={styles.contentContainer}
            refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
            showsVerticalScrollIndicator={false}
        >
            {/* ─── Header ──────────────────────────────── */}
            <View style={styles.headerRow}>
                <Text style={styles.heroTitle}>Daily Progress</Text>
                <View style={styles.liveBadge}>
                    <Text style={styles.liveBadgeText}>Live Updates</Text>
                </View>
            </View>

            {/* ─── 2×3 Stat Grid ──────────────────────── */}
            {dashboard && (
                <View style={styles.statGrid}>
                    {STAT_CONFIGS.map((cfg, i) => {
                        const value = (dashboard as any)[cfg.key];
                        const displayValue = cfg.suffix ? `${value}${cfg.suffix}` : value;
                        return (
                            <View key={cfg.key} style={[
                                styles.statCard,
                                { borderLeftColor: cfg.color },
                            ]}>
                                <Text style={styles.statIcon}>{cfg.icon}</Text>
                                <Text style={styles.statLabel}>{cfg.label}</Text>
                                <Text style={[styles.statValue, { color: cfg.color }]}>
                                    {typeof displayValue === 'number' ? displayValue.toLocaleString() : displayValue}
                                </Text>
                            </View>
                        );
                    })}
                </View>
            )}

            {/* ─── Worker Performance ─────────────────── */}
            <Text style={styles.sectionTitle}>Worker Performance</Text>
            {workerPerf.length === 0 ? (
                <Text style={styles.emptyText}>No worker data yet</Text>
            ) : (
                <View style={styles.workerSection}>
                    {workerPerf.map((w) => {
                        const rateColor = w.completion_rate >= 80 ? '#10B981'
                            : w.completion_rate >= 50 ? '#F59E0B' : '#EF4444';
                        const total = Math.max(w.total, 1);
                        return (
                            <View key={w.worker_id} style={styles.workerCard}>
                                <View style={styles.workerHeader}>
                                    <Text style={styles.workerName}>{w.worker_name}</Text>
                                    <Text style={[styles.workerRate, { color: rateColor }]}>
                                        {w.completion_rate}% Target
                                    </Text>
                                </View>
                                <View style={styles.progressBar}>
                                    <View style={[styles.barSegment, {
                                        flex: w.completed / total,
                                        backgroundColor: '#10B981',
                                        borderTopLeftRadius: 4,
                                        borderBottomLeftRadius: 4,
                                    }]} />
                                    <View style={[styles.barSegment, {
                                        flex: w.late / total,
                                        backgroundColor: '#F59E0B',
                                    }]} />
                                    <View style={[styles.barSegment, {
                                        flex: (w.not_done + w.missed) / total,
                                        backgroundColor: '#EF4444',
                                        borderTopRightRadius: 4,
                                        borderBottomRightRadius: 4,
                                    }]} />
                                </View>
                            </View>
                        );
                    })}
                </View>
            )}

            {/* ─── Stock Summary ──────────────────────── */}
            <Text style={styles.sectionTitle}>Stock Summary</Text>
            {stockSummary.length === 0 ? (
                <Text style={styles.emptyText}>No medicines added yet</Text>
            ) : (
                stockSummary.map((s, index) => {
                    const status = getStockStatus(s);
                    return (
                        <View key={s.id} style={styles.stockCard}>
                            <View style={styles.stockIconContainer}>
                                <Text style={styles.stockIcon}>{STOCK_ICONS[index % STOCK_ICONS.length]}</Text>
                            </View>
                            <View style={styles.stockInfo}>
                                <Text style={styles.stockName}>{s.name}</Text>
                                <Text style={styles.stockCategory}>
                                    {s.dosage_unit}
                                </Text>
                            </View>
                            <View style={styles.stockRight}>
                                <Text style={[styles.stockCount, { color: status.color }]}>
                                    {s.current_stock}
                                </Text>
                                <Text style={[styles.stockStatus, { color: status.color }]}>
                                    {status.label}
                                </Text>
                            </View>
                        </View>
                    );
                })
            )}

            <View style={{ height: 40 }} />
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    contentContainer: {
        paddingHorizontal: SPACING.lg,
        paddingBottom: 40,
    },
    centered: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },

    // ─── Header ─────────────────────────────────────────────
    headerRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingTop: SPACING.lg,
        marginBottom: SPACING.lg,
    },
    heroTitle: {
        fontSize: 28,
        fontWeight: '800',
        color: COLORS.text,
    },
    liveBadge: {
        backgroundColor: COLORS.primary,
        paddingHorizontal: SPACING.md,
        paddingVertical: 6,
        borderRadius: BORDER_RADIUS.xl,
    },
    liveBadgeText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.xs,
        fontWeight: '700',
    },

    // ─── 2×3 Stat Grid ─────────────────────────────────────
    statGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: SPACING.sm,
        marginBottom: SPACING.lg,
    },
    statCard: {
        width: '47.5%',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        borderLeftWidth: 4,
        ...CARD_SHADOW,
    },
    statIcon: {
        fontSize: 28,
        marginBottom: SPACING.sm,
    },
    statLabel: {
        fontSize: 10,
        fontWeight: '700',
        color: COLORS.textLight,
        letterSpacing: 0.5,
        marginBottom: 4,
        textTransform: 'uppercase',
    },
    statValue: {
        fontSize: 32,
        fontWeight: '800',
    },

    // ─── Section ────────────────────────────────────────────
    sectionTitle: {
        fontSize: 22,
        fontWeight: '800',
        color: COLORS.text,
        marginTop: SPACING.lg,
        marginBottom: SPACING.md,
    },
    emptyText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        fontStyle: 'italic',
        paddingVertical: SPACING.md,
    },

    // ─── Worker Cards ───────────────────────────────────────
    workerSection: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        ...CARD_SHADOW,
    },
    workerCard: {
        marginBottom: SPACING.lg,
    },
    workerHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: SPACING.sm,
    },
    workerName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
    },
    workerRate: {
        fontSize: FONT_SIZES.sm,
        fontWeight: '700',
    },
    progressBar: {
        flexDirection: 'row',
        height: 10,
        borderRadius: 5,
        overflow: 'hidden',
        backgroundColor: '#E5E7EB',
    },
    barSegment: {
        height: '100%',
    },

    // ─── Stock Cards ────────────────────────────────────────
    stockCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.md,
        marginBottom: SPACING.sm,
        ...CARD_SHADOW,
    },
    stockIconContainer: {
        width: 44,
        height: 44,
        borderRadius: 12,
        backgroundColor: COLORS.grayLight,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    stockIcon: {
        fontSize: 22,
    },
    stockInfo: {
        flex: 1,
    },
    stockName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    stockCategory: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
    },
    stockRight: {
        alignItems: 'flex-end',
    },
    stockCount: {
        fontSize: FONT_SIZES.xl,
        fontWeight: '800',
    },
    stockStatus: {
        fontSize: 9,
        fontWeight: '700',
        letterSpacing: 0.5,
    },
});
