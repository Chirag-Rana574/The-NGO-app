import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    Vibration,
    Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import ApiService from '../services/api.service';
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

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
            <View style={styles.content}>
                <Text style={styles.icon}>🔐</Text>
                <Text style={styles.title}>Set Up Master Key</Text>
                <Text style={styles.subtitle}>
                    {phase === 'create'
                        ? 'Create a 4-digit PIN to protect sensitive actions'
                        : 'Confirm your PIN'}
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

                {/* Number Pad */}
                <View style={styles.keypad}>
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => (
                        <TouchableOpacity
                            key={num}
                            style={styles.key}
                            onPress={() => handleNumberPress(num.toString())}
                            disabled={loading}
                        >
                            <Text style={styles.keyText}>{num}</Text>
                        </TouchableOpacity>
                    ))}
                    <TouchableOpacity
                        style={styles.key}
                        onPress={handleClear}
                        disabled={loading}
                    >
                        <Text style={styles.keyTextSecondary}>Clear</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.key}
                        onPress={() => handleNumberPress('0')}
                        disabled={loading}
                    >
                        <Text style={styles.keyText}>0</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.key}
                        onPress={handleBackspace}
                        disabled={loading}
                    >
                        <Text style={styles.keyTextSecondary}>⌫</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.primary,
    },
    content: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: SPACING.xl,
    },
    icon: {
        fontSize: 64,
        marginBottom: SPACING.lg,
    },
    title: {
        fontSize: FONT_SIZES.xxl,
        fontWeight: 'bold',
        color: COLORS.white,
        textAlign: 'center',
        marginBottom: SPACING.sm,
    },
    subtitle: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.white,
        opacity: 0.9,
        textAlign: 'center',
        marginBottom: SPACING.xl,
    },
    dotsContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        gap: SPACING.lg,
        marginBottom: SPACING.lg,
    },
    dot: {
        width: 24,
        height: 24,
        borderRadius: 12,
        borderWidth: 2,
        borderColor: 'rgba(255,255,255,0.5)',
        backgroundColor: 'transparent',
    },
    dotFilled: {
        backgroundColor: COLORS.white,
        borderColor: COLORS.white,
    },
    dotError: {
        backgroundColor: COLORS.error,
        borderColor: COLORS.error,
    },
    errorText: {
        color: '#FFD700',
        fontSize: FONT_SIZES.md,
        textAlign: 'center',
        marginBottom: SPACING.md,
        fontWeight: '600',
        minHeight: 24,
    },
    errorPlaceholder: {
        minHeight: 24,
        marginBottom: SPACING.md,
    },
    phaseContainer: {
        flexDirection: 'row',
        gap: SPACING.md,
        marginBottom: SPACING.xl,
    },
    phaseStep: {
        paddingHorizontal: SPACING.lg,
        paddingVertical: SPACING.sm,
        borderRadius: 20,
        backgroundColor: 'rgba(255,255,255,0.2)',
    },
    phaseStepActive: {
        backgroundColor: COLORS.white,
    },
    phaseText: {
        fontSize: FONT_SIZES.md,
        color: 'rgba(255,255,255,0.7)',
        fontWeight: '600',
    },
    phaseTextActive: {
        color: COLORS.primary,
    },
    keypad: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: SPACING.md,
    },
    key: {
        width: 76,
        height: 76,
        borderRadius: 38,
        backgroundColor: 'rgba(255,255,255,0.15)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    keyText: {
        fontSize: 32,
        fontWeight: 'bold',
        color: COLORS.white,
    },
    keyTextSecondary: {
        fontSize: 18,
        fontWeight: '600',
        color: 'rgba(255,255,255,0.7)',
    },
});
