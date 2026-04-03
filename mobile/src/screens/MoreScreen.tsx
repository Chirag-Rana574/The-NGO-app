import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    ScrollView,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
    COLORS, SPACING, FONT_SIZES, FONT_WEIGHTS,
    BORDER_RADIUS, CARD_SHADOW, LETTER_SPACING,
    SECTION_HEADER_STYLE,
} from '../constants/theme';

const toolCards = [
    {
        icon: '📊',
        title: 'Reports',
        subtitle: 'View dashboard stats',
        screen: 'ReportsScreen',
        color: '#3B82F6',
    },
    {
        icon: '📋',
        title: 'Activity Log',
        subtitle: 'Audit trail & history',
        screen: 'AuditLogScreen',
        color: '#8B5CF6',
    },
    {
        icon: '📤',
        title: 'Export Data',
        subtitle: 'Download CSV reports',
        screen: 'ExportScreen',
        color: '#F59E0B',
    },
    {
        icon: '⚙️',
        title: 'Settings',
        subtitle: 'Account & security',
        screen: 'SettingsScreen',
        color: '#6B7280',
    },
];

export default function MoreScreen({ navigation }: any) {
    const [user, setUser] = useState<any>(null);

    useEffect(() => {
        AsyncStorage.getItem('user').then(u => {
            if (u) setUser(JSON.parse(u));
        });
    }, []);

    const handleLogout = async () => {
        await AsyncStorage.multiRemove(['jwt_token', 'user']);
        // Navigate to login - this will be handled by the app state
    };

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
            {/* Profile Header */}
            <View style={styles.profileCard}>
                <View style={styles.profileAvatar}>
                    <Text style={styles.profileAvatarText}>
                        {user?.name?.charAt(0)?.toUpperCase() || '?'}
                    </Text>
                </View>
                <View style={styles.profileInfo}>
                    <Text style={styles.profileName}>{user?.name || 'Administrator'}</Text>
                    <Text style={styles.profileRole}>NGO Admin • Regional District A</Text>
                </View>
                <View style={styles.versionBadge}>
                    <Text style={styles.versionBadgeText}>V2.4.0</Text>
                </View>
            </View>

            {/* Section Title */}
            <Text style={styles.sectionLabel}>MENU & TOOLS</Text>
            <Text style={styles.heroTitle}>Quick Access</Text>

            {/* 2×2 Tool Grid */}
            <View style={styles.toolGrid}>
                {toolCards.map((tool, index) => (
                    <TouchableOpacity
                        key={index}
                        style={styles.toolCard}
                        onPress={() => navigation.navigate(tool.screen)}
                        activeOpacity={0.7}
                    >
                        <View style={[styles.toolIconContainer, { backgroundColor: tool.color + '15' }]}>
                            <Text style={styles.toolIcon}>{tool.icon}</Text>
                        </View>
                        <Text style={styles.toolTitle}>{tool.title}</Text>
                        <Text style={styles.toolSubtitle}>{tool.subtitle}</Text>
                    </TouchableOpacity>
                ))}
            </View>

            {/* Notifications card */}
            <TouchableOpacity
                style={styles.notifCard}
                onPress={() => navigation.navigate('NotificationsScreen')}
                activeOpacity={0.7}
            >
                <View style={styles.notifLeft}>
                    <View style={styles.notifIconContainer}>
                        <Text style={styles.notifIcon}>🔔</Text>
                    </View>
                    <View>
                        <Text style={styles.notifTitle}>Notifications</Text>
                        <Text style={styles.notifSubtitle}>Clinical alerts & stock updates</Text>
                    </View>
                </View>
                <Text style={styles.notifChevron}>›</Text>
            </TouchableOpacity>

            {/* Bottom links */}
            <View style={styles.bottomLinks}>
                <TouchableOpacity style={styles.linkRow}>
                    <Text style={styles.linkIcon}>❓</Text>
                    <Text style={styles.linkText}>Help & Support</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.linkRow}>
                    <Text style={styles.linkIcon}>🛡</Text>
                    <Text style={styles.linkText}>Privacy Policy</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.linkRow} onPress={handleLogout}>
                    <Text style={styles.linkIcon}>🚪</Text>
                    <Text style={[styles.linkText, { color: COLORS.error }]}>Logout</Text>
                </TouchableOpacity>
            </View>

            {/* Footer */}
            <Text style={styles.footerText}>Clinical Curator v2.4.0 • Vitalis NGO</Text>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    content: {
        padding: SPACING.lg,
        paddingBottom: SPACING.xxl,
    },

    // ─── Profile Card ───────────────────────────────────────
    profileCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginBottom: SPACING.xl,
        ...CARD_SHADOW,
    },
    profileAvatar: {
        width: 52,
        height: 52,
        borderRadius: 26,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    profileAvatarText: {
        fontSize: 22,
        fontWeight: '700',
        color: COLORS.white,
    },
    profileInfo: {
        flex: 1,
    },
    profileName: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
    },
    profileRole: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
        marginTop: 2,
    },
    versionBadge: {
        backgroundColor: COLORS.surfaceContainerLow,
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
        borderRadius: BORDER_RADIUS.full,
    },
    versionBadgeText: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 0.5,
    },

    // ─── Section Header ─────────────────────────────────────
    sectionLabel: {
        ...SECTION_HEADER_STYLE,
        color: COLORS.textSecondary,
    },
    heroTitle: {
        fontSize: 28,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.lg,
        letterSpacing: LETTER_SPACING.tight,
    },

    // ─── Tool Grid ──────────────────────────────────────────
    toolGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: SPACING.sm,
        marginBottom: SPACING.lg,
    },
    toolCard: {
        width: '48%',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        ...CARD_SHADOW,
    },
    toolIconContainer: {
        width: 48,
        height: 48,
        borderRadius: BORDER_RADIUS.md,
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: SPACING.md,
    },
    toolIcon: {
        fontSize: 24,
    },
    toolTitle: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    toolSubtitle: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
    },

    // ─── Notification Card ──────────────────────────────────
    notifCard: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginBottom: SPACING.xl,
        ...CARD_SHADOW,
    },
    notifLeft: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    notifIconContainer: {
        width: 44,
        height: 44,
        borderRadius: 22,
        backgroundColor: '#FEF3CD',
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    notifIcon: {
        fontSize: 22,
    },
    notifTitle: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
    },
    notifSubtitle: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
        marginTop: 2,
    },
    notifChevron: {
        fontSize: 24,
        color: COLORS.textLight,
        fontWeight: '300',
    },

    // ─── Bottom Links ───────────────────────────────────────
    bottomLinks: {
        marginBottom: SPACING.xl,
    },
    linkRow: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: SPACING.md,
    },
    linkIcon: {
        fontSize: 18,
        marginRight: SPACING.md,
        width: 28,
    },
    linkText: {
        fontSize: FONT_SIZES.md,
        color: COLORS.text,
        fontWeight: '500',
    },

    // ─── Footer ─────────────────────────────────────────────
    footerText: {
        textAlign: 'center',
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        fontWeight: '500',
    },
});
