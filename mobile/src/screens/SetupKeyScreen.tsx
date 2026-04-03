import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    Vibration,
    Alert,
    ScrollView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import ApiService from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES, FONT_WEIGHTS,
    BORDER_RADIUS, CARD_SHADOW, LETTER_SPACING,
} from '../constants/theme';

export default function SetupKeyScreen({ onComplete }: { onComplete: () => void }) {
    const [pin, setPin] = useState('');
    const [confirmPin, setConfirmPin] = useState('');
    const [phase, setPhase] = useState<'create' | 'confirm'>('create');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleNumberPress = (num: string) => {
        const currentPin = phase === 'create' ? pin : confirmPin;
        if (currentPin.length < 4) {
            const newPin = currentPin + num;
            setError('');

            if (phase === 'create') {
                setPin(newPin);
                if (newPin.length === 4) {
                    setTimeout(() => setPhase('confirm'), 300);
                }
            } else {
                setConfirmPin(newPin);
                if (newPin.length === 4) {
                    submitKey(pin, newPin);
                }
            }
        }
    };

    const handleBackspace = () => {
        if (phase === 'create') {
            setPin(pin.slice(0, -1));
        } else {
            setConfirmPin(confirmPin.slice(0, -1));
        }
        setError('');
    };

    const handleClear = () => {
        if (phase === 'create') {
            setPin('');
        } else {
            setConfirmPin('');
        }
        setError('');
    };

    const submitKey = async (original: string, confirmation: string) => {
        if (original !== confirmation) {
            Vibration.vibrate([0, 100, 50, 100]);
            setError('PINs do not match. Try again.');
            setConfirmPin('');
            setPhase('create');
            setPin('');
            return;
        }

        setLoading(true);
        try {
            await ApiService.setupKey(original);
            Vibration.vibrate(50);
            onComplete();
        } catch (err: any) {
            const msg = err.response?.data?.detail || 'Failed to set up key';
            Alert.alert('Error', msg);
            setPin('');
            setConfirmPin('');
            setPhase('create');
        } finally {
            setLoading(false);
        }
    };

    const currentPin = phase === 'create' ? pin : confirmPin;

    return (
        <SafeAreaView style={styles.container}>
            <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
                {/* Header Bar */}
                <View style={styles.headerBar}>
                    <View style={styles.headerAvatar}>
                        <Text style={styles.headerAvatarText}>CC</Text>
                    </View>
                    <Text style={styles.headerBrand}>Clinical Curator</Text>
                </View>

                {/* Main Content */}
                <View style={styles.content}>
                    <Text style={styles.title}>Security Key</Text>
                    <Text style={styles.subtitle}>
                        {phase === 'create'
                            ? 'Create a 4-digit master key to secure patient records and sensitive data.'
                            : 'Confirm your 4-digit security key.'}
                    </Text>

                    {/* PIN Dots */}
                    <View style={styles.dotsContainer}>
                        {[0, 1, 2, 3].map((index) => (
                            <View
                                key={index}
                                style={[
                                    styles.dot,
                                    currentPin.length > index ? styles.dotFilled : null,
                                    error ? styles.dotError : null,
                                ]}
                            />
                        ))}
                    </View>

                    {error ? (
                        <Text style={styles.errorText}>{error}</Text>
                    ) : (
                        <View style={styles.errorPlaceholder} />
                    )}

                    {/* Phase indicator */}
                    <View style={styles.phaseContainer}>
                        <View style={[styles.phaseStep, phase === 'create' && styles.phaseStepActive]}>
                            <Text style={[styles.phaseText, phase === 'create' && styles.phaseTextActive]}>1. Create</Text>
                        </View>
                        <View style={[styles.phaseStep, phase === 'confirm' && styles.phaseStepActive]}>
                            <Text style={[styles.phaseText, phase === 'confirm' && styles.phaseTextActive]}>2. Confirm</Text>
                        </View>
                    </View>

                    {/* Number Pad — recessed keys, no borders */}
                    <View style={styles.keypad}>
                        {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => (
                            <TouchableOpacity
                                key={num}
                                style={styles.key}
                                onPress={() => handleNumberPress(num.toString())}
                                disabled={loading}
                                activeOpacity={0.7}
                            >
                                <Text style={styles.keyText}>{num}</Text>
                            </TouchableOpacity>
                        ))}
                        <TouchableOpacity
                            style={styles.key}
                            onPress={handleClear}
                            disabled={loading}
                            activeOpacity={0.7}
                        >
                            <Text style={styles.keyTextSecondary}>Clear</Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                            style={styles.key}
                            onPress={() => handleNumberPress('0')}
                            disabled={loading}
                            activeOpacity={0.7}
                        >
                            <Text style={styles.keyText}>0</Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                            style={styles.key}
                            onPress={handleBackspace}
                            disabled={loading}
                            activeOpacity={0.7}
                        >
                            <Text style={styles.keyTextSecondary}>⌫</Text>
                        </TouchableOpacity>
                    </View>

                    {/* Confirm CTA */}
                    <TouchableOpacity
                        style={[styles.confirmButton, currentPin.length < 4 && styles.confirmButtonDisabled]}
                        disabled={currentPin.length < 4 || loading}
                        activeOpacity={0.85}
                    >
                        <Text style={styles.confirmButtonText}>
                            {phase === 'create' ? 'Set Security Key' : 'Confirm Security Key'}
                        </Text>
                    </TouchableOpacity>

                    {/* Forgot link */}
                    <TouchableOpacity style={styles.forgotLink}>
                        <Text style={styles.forgotLinkText}>I FORGOT MY PREVIOUS KEY</Text>
                    </TouchableOpacity>
                </View>

                {/* Info card */}
                <View style={styles.infoCard}>
                    <View style={styles.infoAccent} />
                    <View style={styles.infoContent}>
                        <Text style={styles.infoTitle}>Why a Security Key?</Text>
                        <Text style={styles.infoText}>
                            The master key protects sensitive actions like editing stock levels, deleting records, and overriding schedules. Only authorized administrators should know this key.
                        </Text>
                    </View>
                </View>

                {/* Footer */}
                <Text style={styles.footerText}>
                    CLINICAL CURATOR SECURITY PROTOCOL V2.4.0
                </Text>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.surface,
    },
    scrollContent: {
        flexGrow: 1,
        paddingBottom: SPACING.xxl,
    },
    headerBar: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.md,
        backgroundColor: COLORS.white,
    },
    headerAvatar: {
        width: 34,
        height: 34,
        borderRadius: 17,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.sm,
    },
    headerAvatarText: {
        fontSize: 12,
        fontWeight: '700',
        color: COLORS.white,
    },
    headerBrand: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.primary,
    },
    content: {
        alignItems: 'center',
        paddingHorizontal: SPACING.xl,
        paddingTop: SPACING.xl,
    },
    title: {
        fontSize: 28,
        fontWeight: '800',
        color: COLORS.text,
        textAlign: 'center',
        marginBottom: SPACING.sm,
        letterSpacing: LETTER_SPACING.tight,
    },
    subtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        textAlign: 'center',
        lineHeight: 20,
        marginBottom: SPACING.xl,
        paddingHorizontal: SPACING.md,
    },
    dotsContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        gap: SPACING.lg,
        marginBottom: SPACING.lg,
    },
    dot: {
        width: 22,
        height: 22,
        borderRadius: 11,
        backgroundColor: COLORS.surfaceContainerHighest,
    },
    dotFilled: {
        backgroundColor: COLORS.primary,
    },
    dotError: {
        backgroundColor: COLORS.error,
    },
    errorText: {
        color: COLORS.error,
        fontSize: FONT_SIZES.sm,
        textAlign: 'center',
        marginBottom: SPACING.md,
        fontWeight: '600',
        minHeight: 22,
    },
    errorPlaceholder: {
        minHeight: 22,
        marginBottom: SPACING.md,
    },
    phaseContainer: {
        flexDirection: 'row',
        gap: SPACING.sm,
        marginBottom: SPACING.xl,
    },
    phaseStep: {
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.sm,
        borderRadius: BORDER_RADIUS.full,
        backgroundColor: COLORS.surfaceContainerLow,
    },
    phaseStepActive: {
        backgroundColor: COLORS.primary,
    },
    phaseText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        fontWeight: '600',
    },
    phaseTextActive: {
        color: COLORS.white,
    },
    keypad: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: SPACING.sm,
        marginBottom: SPACING.lg,
    },
    key: {
        width: 72,
        height: 72,
        borderRadius: BORDER_RADIUS.md,
        backgroundColor: COLORS.surfaceContainerHighest,
        justifyContent: 'center',
        alignItems: 'center',
    },
    keyText: {
        fontSize: 28,
        fontWeight: '700',
        color: COLORS.text,
    },
    keyTextSecondary: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
    confirmButton: {
        backgroundColor: COLORS.primary,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: 16,
        paddingHorizontal: SPACING.xl,
        width: '100%',
        alignItems: 'center',
        marginBottom: SPACING.md,
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 4,
    },
    confirmButtonDisabled: {
        opacity: 0.5,
    },
    confirmButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.white,
    },
    forgotLink: {
        paddingVertical: SPACING.md,
    },
    forgotLinkText: {
        fontSize: FONT_SIZES.xs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: LETTER_SPACING.wider,
    },
    infoCard: {
        flexDirection: 'row',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        marginHorizontal: SPACING.lg,
        marginTop: SPACING.xl,
        overflow: 'hidden',
        ...CARD_SHADOW,
    },
    infoAccent: {
        width: 4,
        backgroundColor: COLORS.primary,
    },
    infoContent: {
        flex: 1,
        padding: SPACING.lg,
    },
    infoTitle: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    infoText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
    },
    footerText: {
        textAlign: 'center',
        fontSize: FONT_SIZES.xxs,
        fontWeight: '600',
        color: COLORS.textLight,
        letterSpacing: LETTER_SPACING.wider,
        marginTop: SPACING.xl,
    },
});
