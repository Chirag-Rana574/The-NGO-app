import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    Alert,
    ActivityIndicator,
    Share,
    Platform,
} from 'react-native';
import { Linking } from 'react-native';
import ApiService from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES,
    BORDER_RADIUS, CARD_SHADOW, LETTER_SPACING,
} from '../constants/theme';

const API_BASE = 'http://10.248.163.249:8000/api';

const EXPORT_TYPES = [
    { key: 'schedules', label: 'Schedules', icon: '📅', desc: 'All schedule data' },
    { key: 'stock', label: 'Stock Transactions', icon: '💊', desc: 'Stock in/out history' },
    { key: 'audit', label: 'Audit Log', icon: '📋', desc: 'All system activity' },
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
            // Open the CSV download URL in the browser → user can share from there
            const url = `${API_BASE}/exports/${selectedType}?month=${selectedMonth}`;
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

    return (
        <View style={styles.container}>
            {/* Export Type */}
            <Text style={styles.sectionTitle}>Export Type</Text>
            {EXPORT_TYPES.map((type) => (
                <TouchableOpacity
                    key={type.key}
                    style={[styles.typeCard, selectedType === type.key && styles.typeCardSelected]}
                    onPress={() => setSelectedType(type.key)}
                >
                    <Text style={styles.typeIcon}>{type.icon}</Text>
                    <View style={styles.typeInfo}>
                        <Text style={[styles.typeLabel, selectedType === type.key && styles.typeLabelSelected]}>
                            {type.label}
                        </Text>
                        <Text style={styles.typeDesc}>{type.desc}</Text>
                    </View>
                    {selectedType === type.key && <Text style={styles.checkmark}>✓</Text>}
                </TouchableOpacity>
            ))}

            {/* Month Selector */}
            <Text style={styles.sectionTitle}>Month</Text>
            <View style={styles.monthGrid}>
                {MONTHS.map((m) => (
                    <TouchableOpacity
                        key={m.value}
                        style={[styles.monthChip, selectedMonth === m.value && styles.monthChipSelected]}
                        onPress={() => setSelectedMonth(m.value)}
                    >
                        <Text style={[styles.monthText, selectedMonth === m.value && styles.monthTextSelected]}>
                            {m.label}
                        </Text>
                    </TouchableOpacity>
                ))}
            </View>

            {/* Export Button */}
            <TouchableOpacity
                style={[styles.exportButton, loading && styles.exportButtonDisabled]}
                onPress={handleExport}
                disabled={loading}
            >
                {loading ? (
                    <ActivityIndicator color={COLORS.white} />
                ) : (
                    <Text style={styles.exportButtonText}>📤 Export & Share via Email</Text>
                )}
            </TouchableOpacity>

            <Text style={styles.footerText}>
                CSV files can be shared via email, WhatsApp, or saved to Files.
            </Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
        padding: SPACING.md,
    },
    sectionTitle: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
        marginTop: SPACING.lg,
        marginBottom: SPACING.sm,
    },
    typeCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginBottom: SPACING.sm,
        ...CARD_SHADOW,
    },
    typeCardSelected: {
        backgroundColor: COLORS.blueLight,
    },
    typeIcon: {
        fontSize: 28,
        marginRight: SPACING.md,
    },
    typeInfo: {
        flex: 1,
    },
    typeLabel: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.text,
    },
    typeLabelSelected: {
        color: COLORS.primary,
    },
    typeDesc: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        marginTop: 2,
    },
    checkmark: {
        fontSize: 20,
        fontWeight: 'bold',
        color: COLORS.primary,
    },
    monthGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: SPACING.sm,
    },
    monthChip: {
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm + 2,
        borderRadius: BORDER_RADIUS.full,
        backgroundColor: COLORS.surfaceContainerLow,
    },
    monthChipSelected: {
        backgroundColor: COLORS.primary,
    },
    monthText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.text,
        fontWeight: '500',
    },
    monthTextSelected: {
        color: COLORS.white,
        fontWeight: '600',
    },
    exportButton: {
        backgroundColor: COLORS.primary,
        paddingVertical: 16,
        borderRadius: BORDER_RADIUS.xl,
        alignItems: 'center',
        marginTop: SPACING.xl * 2,
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
    },
});
