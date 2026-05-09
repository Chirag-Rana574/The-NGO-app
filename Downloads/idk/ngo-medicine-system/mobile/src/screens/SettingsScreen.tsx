import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    Alert,
    ScrollView,
    ActivityIndicator,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import ApiService from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES,
    BORDER_RADIUS, CARD_SHADOW, SECTION_HEADER_STYLE, LETTER_SPACING,
} from '../constants/theme';

export default function SettingsScreen({ navigation, onLogout }: any) {
    const [timezone, setTimezone] = useState('');
    const [user, setUser] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadSettings();
    }, []);

    const loadSettings = async () => {
        try {
            const [settingsData, userData] = await Promise.all([
                ApiService.getAppSettings(),
                AsyncStorage.getItem('user'),
            ]);
            setTimezone(settingsData.timezone || 'Asia/Kolkata');
            if (userData) setUser(JSON.parse(userData));
        } catch (error) {
            console.error('Error loading settings:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        Alert.alert('Logout', 'Are you sure you want to sign out?', [
            { text: 'Cancel', style: 'cancel' },
            {
                text: 'Sign Out',
                style: 'destructive',
                onPress: async () => {
                    await AsyncStorage.multiRemove(['jwt_token', 'user']);
                    if (onLogout) onLogout();
                },
            },
        ]);
    };

    if (loading) {
        return (
            <View style={styles.loadingContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <ScrollView
            style={styles.container}
            contentContainerStyle={styles.contentContainer}
            showsVerticalScrollIndicator={false}
        >
            {/* Hero Header */}
            <View style={styles.headerSection}>
                <Text style={styles.sectionLabel}>CONFIGURATION</Text>
                <Text style={styles.heroTitle}>Settings</Text>
                <Text style={styles.heroSubtitle}>
                    Manage your account, security preferences, and application configuration.
                </Text>
            </View>

            {/* User Profile Card */}
            {user && (
                <View style={styles.section}>
                    <Text style={styles.settingSectionLabel}>ACCOUNT</Text>
                    <View style={styles.profileCard}>
                        <View style={styles.avatar}>
                            <Text style={styles.avatarText}>
                                {user.name?.charAt(0)?.toUpperCase() || '?'}
                            </Text>
                        </View>
                        <View style={styles.profileInfo}>
                            <Text style={styles.profileName}>{user.name}</Text>
                            <Text style={styles.profileEmail}>{user.email}</Text>
                        </View>
                        <View style={styles.roleBadge}>
                            <Text style={styles.roleBadgeText}>ADMIN</Text>
                        </View>
                    </View>
                </View>
            )}

            {/* App Settings */}
            <View style={styles.section}>
                <Text style={styles.settingSectionLabel}>APP SETTINGS</Text>
                <View style={styles.settingsGroup}>
                    <View style={styles.settingRow}>
                        <View style={styles.settingLeft}>
                            <Text style={styles.settingIcon}>🌍</Text>
                            <View>
                                <Text style={styles.settingLabel}>Timezone</Text>
                                <Text style={styles.settingDesc}>Regional time display</Text>
                            </View>
                        </View>
                        <View style={styles.settingValueContainer}>
                            <Text style={styles.settingValue}>{timezone}</Text>
                        </View>
                    </View>
                </View>
            </View>

            {/* Security */}
            <View style={styles.section}>
                <Text style={styles.settingSectionLabel}>SECURITY</Text>
                <View style={styles.settingsGroup}>
                    <TouchableOpacity style={styles.settingRow} activeOpacity={0.7}>
                        <View style={styles.settingLeft}>
                            <Text style={styles.settingIcon}>🔐</Text>
                            <View>
                                <Text style={styles.settingLabel}>Change Master PIN</Text>
                                <Text style={styles.settingDesc}>Update your 4-digit security key</Text>
                            </View>
                        </View>
                        <Text style={styles.settingArrow}>›</Text>
                    </TouchableOpacity>
                </View>
            </View>

            {/* About */}
            <View style={styles.section}>
                <Text style={styles.settingSectionLabel}>ABOUT</Text>
                <View style={styles.settingsGroup}>
                    <View style={styles.settingRow}>
                        <View style={styles.settingLeft}>
                            <Text style={styles.settingIcon}>📱</Text>
                            <View>
                                <Text style={styles.settingLabel}>App Version</Text>
                                <Text style={styles.settingDesc}>Clinical Curator</Text>
                            </View>
                        </View>
                        <View style={styles.settingValueContainer}>
                            <Text style={styles.settingValue}>v2.4.0</Text>
                        </View>
                    </View>
                </View>
            </View>

            {/* Logout */}
            <TouchableOpacity style={styles.logoutButton} onPress={handleLogout} activeOpacity={0.7}>
                <Text style={styles.logoutIcon}>🚪</Text>
                <Text style={styles.logoutText}>Sign Out</Text>
            </TouchableOpacity>

            <Text style={styles.versionText}>
                Clinical Curator v2.4.0 • Vitalis NGO
            </Text>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    contentContainer: {
        paddingBottom: 100,
    },
    loadingContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: COLORS.background,
    },

    // ─── Header Section ─────────────────────────────────────────
    headerSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.sm,
    },
    sectionLabel: {
        ...SECTION_HEADER_STYLE,
        color: COLORS.textSecondary,
    },
    heroTitle: {
        fontSize: 32,
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

    // ─── Section ────────────────────────────────────────────────
    section: {
        marginTop: SPACING.lg,
        marginHorizontal: SPACING.md,
    },
    settingSectionLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.sm,
        marginLeft: SPACING.xs,
    },

    // ─── Profile Card ───────────────────────────────────────────
    profileCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        ...CARD_SHADOW,
    },
    avatar: {
        width: 52,
        height: 52,
        borderRadius: 26,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarText: {
        fontSize: 22,
        fontWeight: '700',
        color: COLORS.white,
    },
    profileInfo: {
        marginLeft: SPACING.md,
        flex: 1,
    },
    profileName: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
    },
    profileEmail: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        marginTop: 2,
    },
    roleBadge: {
        backgroundColor: COLORS.primary + '15',
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
        borderRadius: BORDER_RADIUS.full,
    },
    roleBadgeText: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.primary,
        letterSpacing: 0.5,
    },

    // ─── Settings Group ─────────────────────────────────────────
    settingsGroup: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        overflow: 'hidden',
        ...CARD_SHADOW,
    },
    settingRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: SPACING.lg,
    },
    settingLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1,
    },
    settingIcon: {
        fontSize: 22,
        marginRight: SPACING.md,
        width: 28,
    },
    settingLabel: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.text,
    },
    settingDesc: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        marginTop: 1,
    },
    settingValueContainer: {
        backgroundColor: COLORS.surfaceContainerLow,
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
        borderRadius: BORDER_RADIUS.full,
    },
    settingValue: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
        fontWeight: '600',
    },
    settingArrow: {
        fontSize: 24,
        color: COLORS.textLight,
        fontWeight: '300',
    },

    // ─── Logout Button ──────────────────────────────────────────
    logoutButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        marginHorizontal: SPACING.md,
        marginTop: SPACING.xl * 2,
        backgroundColor: COLORS.redLight,
        paddingVertical: 16,
        borderRadius: BORDER_RADIUS.xl,
    },
    logoutIcon: {
        fontSize: 18,
        marginRight: SPACING.sm,
    },
    logoutText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.error,
    },
    versionText: {
        textAlign: 'center',
        color: COLORS.textLight,
        fontSize: FONT_SIZES.xs,
        marginTop: SPACING.lg,
        fontWeight: '500',
        letterSpacing: 0.5,
    },
});
