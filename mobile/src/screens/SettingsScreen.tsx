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
    BORDER_RADIUS, CARD_SHADOW, SECTION_HEADER_STYLE,
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
        <ScrollView style={styles.container}>
            {/* User Profile */}
            {user && (
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Account</Text>
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
                    </View>
                </View>
            )}

            {/* Timezone */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>App Settings</Text>
                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Timezone</Text>
                    <Text style={styles.settingValue}>{timezone}</Text>
                </View>
            </View>

            {/* Security */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Security</Text>
                <TouchableOpacity style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Change Master PIN</Text>
                    <Text style={styles.settingArrow}>›</Text>
                </TouchableOpacity>
            </View>

            {/* Logout */}
            <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
                <Text style={styles.logoutText}>Sign Out</Text>
            </TouchableOpacity>

            <Text style={styles.versionText}>NGO Medicine System v1.0.0</Text>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    loadingContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: COLORS.background,
    },
    section: {
        marginTop: SPACING.lg,
        marginHorizontal: SPACING.md,
    },
    sectionTitle: {
        ...SECTION_HEADER_STYLE,
        color: COLORS.textSecondary,
        marginBottom: SPACING.sm,
        marginLeft: SPACING.sm,
    },
    profileCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        ...CARD_SHADOW,
    },
    avatar: {
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarText: {
        fontSize: 20,
        fontWeight: 'bold',
        color: COLORS.white,
    },
    profileInfo: {
        marginLeft: SPACING.md,
        flex: 1,
    },
    profileName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.text,
    },
    profileEmail: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        marginTop: 2,
    },
    settingRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginBottom: 2,
        ...CARD_SHADOW,
    },
    settingLabel: {
        fontSize: FONT_SIZES.md,
        color: COLORS.text,
    },
    settingValue: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
    },
    settingArrow: {
        fontSize: 22,
        color: COLORS.textLight,
    },
    logoutButton: {
        marginHorizontal: SPACING.md,
        marginTop: SPACING.xl * 2,
        backgroundColor: COLORS.redLight,
        paddingVertical: 16,
        borderRadius: BORDER_RADIUS.xl,
        alignItems: 'center',
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
        marginBottom: SPACING.xl * 2,
        letterSpacing: 0.5,
    },
});
