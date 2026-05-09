import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    ActivityIndicator,
    RefreshControl,
} from 'react-native';
import { format } from 'date-fns';
import ApiService from '../services/api.service';
import { AuditLog } from '../types';
import {
    COLORS, SPACING, FONT_SIZES,
    BORDER_RADIUS, CARD_SHADOW, LETTER_SPACING,
} from '../constants/theme';

export default function AuditLogScreen() {
    const [logs, setLogs] = useState<AuditLog[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        loadLogs();
    }, []);

    const loadLogs = async () => {
        try {
            setError(null);
            const data = await ApiService.getAuditLogs({ limit: 100 });
            setLogs(data || []);
        } catch (err: any) {
            console.error('Failed to load audit logs:', err);
            const errorMsg = err.response?.data?.detail || err.message || 'Failed to load logs';
            setError(errorMsg);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    };

    const onRefresh = () => {
        setRefreshing(true);
        loadLogs();
    };

    const safeFormatDate = (dateStr: string) => {
        try {
            return format(new Date(dateStr), 'MMM dd, h:mm a');
        } catch {
            return dateStr;
        }
    };

    const getActionColor = (action: string) => {
        switch (action) {
            case 'CREATE':
                return COLORS.green;
            case 'UPDATE':
                return COLORS.blue;
            case 'DELETE':
                return COLORS.red;
            case 'STATE_TRANSITION':
                return COLORS.yellow;
            case 'STOCK_CHANGE':
                return COLORS.orange;
            case 'OVERRIDE':
                return COLORS.red;
            default:
                return COLORS.gray;
        }
    };

    const renderLogItem = ({ item }: { item: AuditLog }) => {
        const actionColor = getActionColor(item.action);
        return (
            <View style={[styles.logCard, { borderLeftColor: actionColor }]}>
                <View style={styles.logHeader}>
                    <View style={[styles.actionBadge, { backgroundColor: actionColor }]}>
                        <Text style={styles.actionText}>{item.action}</Text>
                    </View>
                    <Text style={styles.timestamp}>
                        {safeFormatDate(item.created_at)}
                    </Text>
                </View>

                <Text style={styles.entityType}>
                    {item.entity_type} #{item.entity_id}
                </Text>

                {item.reason && (
                    <Text style={styles.reason}>{item.reason}</Text>
                )}

                {item.performed_by && (
                    <Text style={styles.performedBy}>By: {item.performed_by}</Text>
                )}
            </View>
        );
    };

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    if (error) {
        return (
            <View style={styles.centerContainer}>
                <Text style={{ color: COLORS.error, fontSize: FONT_SIZES.md, textAlign: 'center', padding: SPACING.lg }}>
                    {error}
                </Text>
            </View>
        );
    }

    return (
        <View style={styles.container}>
            <FlatList
                data={logs}
                renderItem={renderLogItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListHeaderComponent={
                    <View style={styles.headerSection}>
                        <Text style={styles.heroTitle}>Activity History</Text>
                        <Text style={styles.heroSubtitle}>
                            Track all changes and actions performed in the system.
                        </Text>
                    </View>
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>📋</Text>
                        <Text style={styles.emptyText}>No audit logs available</Text>
                    </View>
                }
                showsVerticalScrollIndicator={false}
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
    listContainer: {
        padding: SPACING.md,
        paddingBottom: 40,
    },
    headerSection: {
        paddingHorizontal: SPACING.sm,
        paddingBottom: SPACING.md,
    },
    heroTitle: {
        fontSize: 28,
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
    logCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginBottom: SPACING.md,
        borderLeftWidth: 4,
        ...CARD_SHADOW,
    },
    logHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: SPACING.sm,
    },
    actionBadge: {
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
        borderRadius: BORDER_RADIUS.full,
        minHeight: 26,
        justifyContent: 'center',
    },
    actionText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        letterSpacing: 0.5,
    },
    timestamp: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        fontWeight: '600',
        letterSpacing: 0.3,
    },
    entityType: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    reason: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        marginTop: SPACING.xs,
        lineHeight: 20,
    },
    performedBy: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        marginTop: SPACING.xs,
        fontWeight: '600',
    },
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
    },
});
