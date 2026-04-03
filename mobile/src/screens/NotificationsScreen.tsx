import React, { useState, useEffect, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    TouchableOpacity,
    RefreshControl,
    ActivityIndicator,
} from 'react-native';
import { format } from 'date-fns';
import ApiService from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

interface NotificationItem {
    id: number;
    type: string;
    title: string;
    body: string;
    severity: string;
    is_read: boolean;
    created_at: string;
}

const SEVERITY_COLORS: Record<string, string> = {
    NORMAL: COLORS.primary,
    MODERATE: '#F59E0B',
    SERIOUS: '#EF4444',
};

const SEVERITY_BG: Record<string, string> = {
    NORMAL: '#EBF5FF',
    MODERATE: '#FEF3CD',
    SERIOUS: '#FEE2E2',
};

const TYPE_ICONS: Record<string, string> = {
    TASK_COMPLETED: '✅',
    TASK_OVERDUE: '⚠️',
    TASK_MISSED: '❌',
    LOW_STOCK: '📦',
    DAILY_SUMMARY: '📋',
};

const TYPE_LABELS: Record<string, string> = {
    TASK_COMPLETED: 'Task Done',
    TASK_OVERDUE: 'Overdue Alert',
    TASK_MISSED: 'Missed Task',
    LOW_STOCK: 'Low Stock',
    DAILY_SUMMARY: 'Summary',
};

export default function NotificationsScreen() {
    const [notifications, setNotifications] = useState<NotificationItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [unreadCount, setUnreadCount] = useState(0);

    const loadNotifications = useCallback(async () => {
        try {
            const [data, countData] = await Promise.all([
                ApiService.getNotifications(50),
                ApiService.getUnreadNotificationCount(),
            ]);
            setNotifications(data);
            setUnreadCount(countData.unread_count);
        } catch (error) {
            console.error('Error loading notifications:', error);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        loadNotifications();
    }, [loadNotifications]);

    const onRefresh = useCallback(() => {
        setRefreshing(true);
        loadNotifications();
    }, [loadNotifications]);

    const markAsRead = async (id: number) => {
        try {
            await ApiService.markNotificationRead(id);
            setNotifications((prev) =>
                prev.map((n) => (n.id === id ? { ...n, is_read: true } : n))
            );
            setUnreadCount((prev) => Math.max(0, prev - 1));
        } catch (error) {
            console.error('Error marking notification read:', error);
        }
    };

    const markAllRead = async () => {
        try {
            await ApiService.markAllNotificationsRead();
            setNotifications((prev) => prev.map((n) => ({ ...n, is_read: true })));
            setUnreadCount(0);
        } catch (error) {
            console.error('Error marking all read:', error);
        }
    };

    const getRelativeTime = (dateStr: string) => {
        const now = new Date();
        const date = new Date(dateStr);
        const diff = (now.getTime() - date.getTime()) / 1000;
        if (diff < 60) return 'Just now';
        if (diff < 3600) return `${Math.floor(diff / 60)} MIN AGO`;
        if (diff < 86400) return `${Math.floor(diff / 3600)} HOURS AGO`;
        return format(date, 'MMM d');
    };

    // ─── Card Renderer ────────────────────────────────────────────
    const renderItem = ({ item }: { item: NotificationItem }) => {
        const icon = TYPE_ICONS[item.type] || '🔔';
        const severityColor = SEVERITY_COLORS[item.severity] || COLORS.primary;
        const severityBg = SEVERITY_BG[item.severity] || '#EBF5FF';
        const typeLabel = TYPE_LABELS[item.type] || item.type;
        const timeAgo = getRelativeTime(item.created_at);
        const isUnread = !item.is_read;

        return (
            <TouchableOpacity
                style={[
                    styles.notifCard,
                    isUnread && { borderLeftColor: severityColor, backgroundColor: severityBg },
                ]}
                onPress={() => isUnread && markAsRead(item.id)}
                activeOpacity={0.7}
            >
                {/* Icon circle */}
                <View style={[styles.iconCircle, { backgroundColor: isUnread ? severityColor + '20' : COLORS.grayLight }]}>
                    <Text style={styles.iconEmoji}>{icon}</Text>
                </View>

                {/* Content */}
                <View style={styles.notifContent}>
                    <View style={styles.titleRow}>
                        <Text style={[styles.notifTitle, isUnread && { fontWeight: '800' }]}>
                            {item.title}
                        </Text>
                        {isUnread && (
                            <View style={styles.newBadge}>
                                <Text style={styles.newBadgeText}>NEW</Text>
                            </View>
                        )}
                    </View>
                    <Text style={styles.notifBody} numberOfLines={3}>
                        {item.body}
                    </Text>
                    <Text style={styles.notifTime}>{timeAgo}</Text>
                </View>
            </TouchableOpacity>
        );
    };

    // ─── List Header ──────────────────────────────────────────────
    const ListHeader = () => (
        <View style={styles.headerSection}>
            <View style={styles.headerRow}>
                <Text style={styles.heroTitle}>Notifications</Text>
                {unreadCount > 0 && (
                    <TouchableOpacity style={styles.markAllButton} onPress={markAllRead}>
                        <Text style={styles.markAllIcon}>✓✓</Text>
                        <Text style={styles.markAllText}>Mark all as read</Text>
                    </TouchableOpacity>
                )}
            </View>
            <Text style={styles.heroSubtitle}>
                Stay updated with clinical alerts and stock updates.
            </Text>
        </View>
    );

    if (loading) {
        return (
            <View style={styles.centered}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <View style={styles.container}>
            <FlatList
                data={notifications}
                renderItem={renderItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.list}
                ListHeaderComponent={<ListHeader />}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>🔔</Text>
                        <Text style={styles.emptyText}>No notifications yet</Text>
                        <Text style={styles.emptySubtext}>You're all caught up!</Text>
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
    centered: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    list: {
        paddingBottom: 40,
    },

    // ─── Header ─────────────────────────────────────────────
    headerSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.md,
    },
    headerRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: SPACING.xs,
    },
    heroTitle: {
        fontSize: 32,
        fontWeight: '800',
        color: COLORS.text,
    },
    heroSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
    },
    markAllButton: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.primary,
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm,
        borderRadius: BORDER_RADIUS.xl,
    },
    markAllIcon: {
        color: COLORS.white,
        fontSize: 12,
        fontWeight: '700',
        marginRight: 6,
    },
    markAllText: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.white,
        fontWeight: '600',
    },

    // ─── Notification Card ──────────────────────────────────
    notifCard: {
        flexDirection: 'row',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.sm,
        borderLeftWidth: 4,
        borderLeftColor: 'transparent',
        ...CARD_SHADOW,
    },
    iconCircle: {
        width: 44,
        height: 44,
        borderRadius: 22,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    iconEmoji: {
        fontSize: 22,
    },
    notifContent: {
        flex: 1,
    },
    titleRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 4,
    },
    notifTitle: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        flex: 1,
    },
    newBadge: {
        backgroundColor: COLORS.primary,
        paddingHorizontal: 8,
        paddingVertical: 2,
        borderRadius: BORDER_RADIUS.full,
        marginLeft: SPACING.sm,
    },
    newBadgeText: {
        color: COLORS.white,
        fontSize: 9,
        fontWeight: '800',
        letterSpacing: 0.5,
    },
    notifBody: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
        marginBottom: SPACING.xs,
    },
    notifTime: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        fontWeight: '600',
        letterSpacing: 0.5,
    },

    // ─── Empty ──────────────────────────────────────────────
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
});
