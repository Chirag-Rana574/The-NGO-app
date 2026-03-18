import React from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    ScrollView,
} from 'react-native';
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

const menuItems = [
    {
        icon: '👥',
        title: 'Patients',
        subtitle: 'Manage patient records',
        screen: 'PatientsScreen',
        color: '#4A90D9',
    },
    {
        icon: '👷',
        title: 'Workers',
        subtitle: 'Manage healthcare workers',
        screen: 'WorkersScreen',
        color: '#2ECC71',
    },
    {
        icon: '📋',
        title: 'Activity Log',
        subtitle: 'View audit trail & history',
        screen: 'AuditLogScreen',
        color: '#9B59B6',
    },
    {
        icon: '⚙️',
        title: 'Settings',
        subtitle: 'Timezone, account & security',
        screen: 'SettingsScreen',
        color: '#95A5A6',
    },
    {
        icon: '📤',
        title: 'Export Data',
        subtitle: 'Download CSV reports via email',
        screen: 'ExportScreen',
        color: '#E67E22',
    },
];

export default function MoreScreen({ navigation }: any) {
    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            <Text style={styles.sectionTitle}>Manage</Text>

            {menuItems.map((item, index) => (
                <TouchableOpacity
                    key={index}
                    style={styles.menuCard}
                    onPress={() => navigation.navigate(item.screen)}
                    activeOpacity={0.7}
                >
                    <View style={[styles.iconContainer, { backgroundColor: item.color + '18' }]}>
                        <Text style={styles.icon}>{item.icon}</Text>
                    </View>
                    <View style={styles.textContainer}>
                        <Text style={styles.menuTitle}>{item.title}</Text>
                        <Text style={styles.menuSubtitle}>{item.subtitle}</Text>
                    </View>
                    <Text style={styles.chevron}>›</Text>
                </TouchableOpacity>
            ))}

            <View style={styles.footer}>
                <Text style={styles.footerText}>NGO Medicine System</Text>
                <Text style={styles.footerVersion}>v1.0.0</Text>
            </View>
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
        paddingTop: SPACING.xl,
    },
    sectionTitle: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.textLight,
        textTransform: 'uppercase',
        letterSpacing: 1,
        marginBottom: SPACING.md,
    },
    menuCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: 14,
        padding: SPACING.lg,
        marginBottom: SPACING.md,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.06,
        shadowRadius: 8,
        elevation: 2,
    },
    iconContainer: {
        width: 48,
        height: 48,
        borderRadius: 12,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    icon: {
        fontSize: 24,
    },
    textContainer: {
        flex: 1,
    },
    menuTitle: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '600',
        color: COLORS.text,
        marginBottom: 2,
    },
    menuSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
    },
    chevron: {
        fontSize: 28,
        color: COLORS.textLight,
        fontWeight: '300',
    },
    footer: {
        marginTop: SPACING.xl * 2,
        alignItems: 'center',
        paddingBottom: SPACING.xl,
    },
    footerText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        fontWeight: '500',
    },
    footerVersion: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        marginTop: 4,
    },
});
