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
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

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

const TYPE_ICONS: Record<string, string> = {
    TASK_COMPLETED: '✅',
    TASK_OVERDUE: '⚠️',
    TASK_MISSED: '❌',
    LOW_STOCK: '💊',
    DAILY_SUMMARY: '📋',
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

    const renderItem = ({ item }: { item: NotificationItem }) => {
        const icon = TYPE_ICONS[item.type] || '🔔';
        const severityColor = SEVERITY_COLORS[item.severity] || COLORS.textLight;
        const timeStr = format(new Date(item.created_at), 'hh:mm a');
        const dateStr = format(new Date(item.created_at), 'dd/MM');

        return (
            <TouchableOpacity
                style={[styles.notifCard, !item.is_read && styles.unreadCard]}
                onPress={() => !item.is_read && markAsRead(item.id)}
                activeOpacity={0.7}
            >
                <View style={styles.notifRow}>
                    <Text style={styles.notifIcon}>{icon}</Text>
                    <View style={styles.notifContent}>
                        <Text style={[styles.notifTitle, !item.is_read && styles.unreadTitle]}>
                            {item.title}
                        </Text>
                        <Text style={styles.notifBody} numberOfLines={2}>
                            {item.body}
                        </Text>
                        <Text style={styles.notifTime}>{timeStr} · {dateStr}</Text>
                    </View>
                    {!item.is_read && (
                        <View style={[styles.unreadDot, { backgroundColor: severityColor }]} />
                    )}
                </View>
            </TouchableOpacity>
        );
    };

    if (loading) {
        return (
            <View style={styles.centered}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <View style={styles.container}>
            {/* Header actions */}
            {unreadCount > 0 && (
                <TouchableOpacity style={styles.markAllButton} onPress={markAllRead}>
                    <Text style={styles.markAllText}>Mark all as read ({unreadCount})</Text>
                </TouchableOpacity>
            )}

            <FlatList
                data={notifications}
                renderItem={renderItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.list}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.centered}>
                        <Text style={styles.emptyIcon}>🔔</Text>
                        <Text style={styles.emptyText}>No notifications yet</Text>
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
    centered: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        paddingTop: 60,
    },
    list: {
        padding: SPACING.md,
    },
    markAllButton: {
        alignSelf: 'flex-end',
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm,
    },
    markAllText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.primary,
        fontWeight: '600',
    },
    notifCard: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: SPACING.md,
        marginBottom: SPACING.sm,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 1,
    },
    unreadCard: {
        backgroundColor: '#F0F7FF',
        borderLeftWidth: 3,
        borderLeftColor: COLORS.primary,
    },
    notifRow: {
        flexDirection: 'row',
        alignItems: 'flex-start',
    },
    notifIcon: {
        fontSize: 24,
        marginRight: SPACING.sm,
        marginTop: 2,
    },
    notifContent: {
        flex: 1,
    },
    notifTitle: {
        fontSize: FONT_SIZES.md,
        color: COLORS.text,
        marginBottom: 4,
    },
    unreadTitle: {
        fontWeight: '600',
    },
    notifBody: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        lineHeight: 18,
    },
    notifTime: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        marginTop: 6,
    },
    unreadDot: {
        width: 10,
        height: 10,
        borderRadius: 5,
        marginLeft: SPACING.sm,
        marginTop: 6,
    },
    emptyIcon: {
        fontSize: 48,
        marginBottom: SPACING.md,
    },
    emptyText: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
    },
});
