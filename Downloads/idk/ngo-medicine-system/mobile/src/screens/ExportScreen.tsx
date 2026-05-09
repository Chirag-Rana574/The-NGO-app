import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    Alert,
    ActivityIndicator,
    ScrollView,
} from 'react-native';
import { Linking } from 'react-native';
import { API_BASE_URL } from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES,
    BORDER_RADIUS, CARD_SHADOW, SECTION_HEADER_STYLE, LETTER_SPACING,
} from '../constants/theme';

const EXPORT_TYPES = [
    { key: 'schedules', label: 'Schedules', icon: '📅', desc: 'All schedule data including status and timestamps' },
    { key: 'stock', label: 'Stock Transactions', icon: '💊', desc: 'Complete stock in/out history with audit trail' },
    { key: 'audit', label: 'Audit Log', icon: '📋', desc: 'All system activity and permission changes' },
];

const MONTHS = (() => {
    const months = [];
    const now = new Date();
    for (let i = 0; i < 6; i++) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        months.push({
            value: `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`,
            label: d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
        });
    }
    return months;
})();

export default function ExportScreen() {
    const [selectedType, setSelectedType] = useState('schedules');
    const [selectedMonth, setSelectedMonth] = useState(MONTHS[0].value);
    const [loading, setLoading] = useState(false);

    const handleExport = async () => {
        setLoading(true);
        try {
            const url = `${API_BASE_URL}/exports/${selectedType}?month=${selectedMonth}`;
            await Linking.openURL(url);
            Alert.alert(
                'Export Started',
                'The CSV file will open in your browser. From there you can share or save it.'
            );
        } catch (error) {
            console.error('Export error:', error);
            Alert.alert('Error', 'Failed to export data. Please check your connection.');
        } finally {
            setLoading(false);
        }
    };

    const selectedTypeObj = EXPORT_TYPES.find(t => t.key === selectedType);

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer} showsVerticalScrollIndicator={false}>
            {/* Hero Header */}
            <View style={styles.headerSection}>
                <Text style={styles.sectionLabel}>DATA MANAGEMENT</Text>
                <Text style={styles.heroTitle}>Export & Share</Text>
                <Text style={styles.heroSubtitle}>
                    Download clinical records as CSV files for reporting, compliance, and offline analysis.
                </Text>
            </View>

            {/* Export Type Selection */}
            <Text style={styles.formSectionLabel}>EXPORT TYPE</Text>
            {EXPORT_TYPES.map((type) => (
                <TouchableOpacity
                    key={type.key}
                    style={[styles.typeCard, selectedType === type.key && styles.typeCardSelected]}
                    onPress={() => setSelectedType(type.key)}
                    activeOpacity={0.7}
                >
                    <View style={[
                        styles.typeIconContainer,
                        { backgroundColor: selectedType === type.key ? COLORS.primary + '15' : COLORS.grayLight }
                    ]}>
                        <Text style={styles.typeIcon}>{type.icon}</Text>
                    </View>
                    <View style={styles.typeInfo}>
                        <Text style={[styles.typeLabel, selectedType === type.key && styles.typeLabelSelected]}>
                            {type.label}
                        </Text>
                        <Text style={styles.typeDesc}>{type.desc}</Text>
                    </View>
                    {selectedType === type.key && (
                        <View style={styles.checkCircle}>
                            <Text style={styles.checkmark}>✓</Text>
                        </View>
                    )}
                </TouchableOpacity>
            ))}

            {/* Month Selector */}
            <Text style={styles.formSectionLabel}>SELECT PERIOD</Text>
            <View style={styles.monthGrid}>
                {MONTHS.map((m) => (
                    <TouchableOpacity
                        key={m.value}
                        style={[styles.monthChip, selectedMonth === m.value && styles.monthChipSelected]}
                        onPress={() => setSelectedMonth(m.value)}
                        activeOpacity={0.7}
                    >
                        <Text style={[styles.monthText, selectedMonth === m.value && styles.monthTextSelected]}>
                            {m.label}
                        </Text>
                    </TouchableOpacity>
                ))}
            </View>

            {/* Preview card */}
            <View style={styles.previewCard}>
                <Text style={styles.previewLabel}>EXPORT PREVIEW</Text>
                <Text style={styles.previewValue}>
                    {selectedTypeObj?.label} — {MONTHS.find(m => m.value === selectedMonth)?.label}
                </Text>
                <Text style={styles.previewFormat}>Format: CSV (comma-separated values)</Text>
            </View>

            {/* Export Button */}
            <TouchableOpacity
                style={[styles.exportButton, loading && styles.exportButtonDisabled]}
                onPress={handleExport}
                disabled={loading}
                activeOpacity={0.85}
            >
                {loading ? (
                    <ActivityIndicator color={COLORS.white} />
                ) : (
                    <Text style={styles.exportButtonText}>📤  Export & Share via Email</Text>
                )}
            </TouchableOpacity>

            <Text style={styles.footerText}>
                CSV files can be shared via email, WhatsApp, or saved to Files.
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

    // ─── Header Section ─────────────────────────────────────────
    headerSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.md,
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

    // ─── Form Section Labels ─────────────────────────────────────
    formSectionLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        paddingHorizontal: SPACING.lg,
        marginTop: SPACING.lg,
        marginBottom: SPACING.sm,
    },

    // ─── Type Cards ──────────────────────────────────────────────
    typeCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.sm,
        ...CARD_SHADOW,
    },
    typeCardSelected: {
        borderLeftWidth: 4,
        borderLeftColor: COLORS.primary,
    },
    typeIconContainer: {
        width: 48,
        height: 48,
        borderRadius: BORDER_RADIUS.md,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    typeIcon: {
        fontSize: 24,
    },
    typeInfo: {
        flex: 1,
    },
    typeLabel: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    typeLabelSelected: {
        color: COLORS.primary,
    },
    typeDesc: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
        lineHeight: 16,
    },
    checkCircle: {
        width: 28,
        height: 28,
        borderRadius: 14,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
        marginLeft: SPACING.sm,
    },
    checkmark: {
        fontSize: 14,
        fontWeight: '800',
        color: COLORS.white,
    },

    // ─── Month Grid ──────────────────────────────────────────────
    monthGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: SPACING.sm,
        paddingHorizontal: SPACING.md,
    },
    monthChip: {
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm + 2,
        borderRadius: BORDER_RADIUS.full,
        backgroundColor: COLORS.white,
        ...CARD_SHADOW,
    },
    monthChipSelected: {
        backgroundColor: COLORS.primary,
        shadowOpacity: 0.3,
    },
    monthText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.text,
        fontWeight: '500',
    },
    monthTextSelected: {
        color: COLORS.white,
        fontWeight: '700',
    },

    // ─── Preview Card ────────────────────────────────────────────
    previewCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginHorizontal: SPACING.md,
        marginTop: SPACING.xl,
        borderLeftWidth: 4,
        borderLeftColor: COLORS.primary,
        ...CARD_SHADOW,
    },
    previewLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.xs,
    },
    previewValue: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 4,
    },
    previewFormat: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
    },

    // ─── Export Button ───────────────────────────────────────────
    exportButton: {
        backgroundColor: COLORS.primary,
        paddingVertical: 16,
        borderRadius: BORDER_RADIUS.xl,
        alignItems: 'center',
        marginHorizontal: SPACING.md,
        marginTop: SPACING.xl,
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
        elevation: 6,
    },
    exportButtonDisabled: {
        opacity: 0.6,
    },
    exportButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.white,
    },
    footerText: {
        textAlign: 'center',
        color: COLORS.textLight,
        fontSize: FONT_SIZES.xs,
        marginTop: SPACING.md,
        marginBottom: SPACING.xl,
        paddingHorizontal: SPACING.lg,
    },
});
