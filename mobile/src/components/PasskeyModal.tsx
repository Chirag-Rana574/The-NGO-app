import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    Modal,
    TouchableOpacity,
    Vibration,
} from 'react-native';
import {
    COLORS, SPACING, FONT_SIZES, BORDER_RADIUS, CARD_SHADOW,
} from '../constants/theme';

interface PasskeyModalProps {
    visible: boolean;
    onClose: () => void;
    onSuccess: () => void;
    onVerify: (passkey: string) => Promise<boolean>;
    title?: string;
}

export default function PasskeyModal({
    visible,
    onClose,
    onSuccess,
    onVerify,
    title = 'Security Key',
}: PasskeyModalProps) {
    const [passkey, setPasskey] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleNumberPress = (num: string) => {
        if (passkey.length < 4) {
            const newPasskey = passkey + num;
            setPasskey(newPasskey);
            setError('');

            // Auto-verify when 4 digits entered
            if (newPasskey.length === 4) {
                verifyPasskey(newPasskey);
            }
        }
    };

    const handleBackspace = () => {
        setPasskey(passkey.slice(0, -1));
        setError('');
    };

    const handleClear = () => {
        setPasskey('');
        setError('');
    };

    const verifyPasskey = async (code: string) => {
        setLoading(true);
        try {
            const isValid = await onVerify(code);
            if (isValid) {
                Vibration.vibrate(50); // Success haptic
                onSuccess();
                handleClear();
            } else {
                Vibration.vibrate([0, 100, 50, 100]); // Error haptic
                setError('Incorrect passkey');
                setPasskey('');
            }
        } catch (err) {
            setError('Verification failed');
            setPasskey('');
        } finally {
            setLoading(false);
        }
    };

    const handleClose = () => {
        handleClear();
        onClose();
    };

    return (
        <Modal
            visible={visible}
            transparent
            animationType="fade"
            onRequestClose={handleClose}
        >
            <View style={styles.overlay}>
                <View style={styles.container}>
                    {/* Lock icon */}
                    <View style={styles.lockContainer}>
                        <Text style={styles.lockIcon}>🔐</Text>
                    </View>

                    <Text style={styles.title}>{title}</Text>
                    <Text style={styles.subtitle}>Enter 4-digit PIN to continue</Text>

                    {/* PIN Dots */}
                    <View style={styles.dotsContainer}>
                        {[0, 1, 2, 3].map((index) => (
                            <View
                                key={index}
                                style={[
                                    styles.dot,
                                    passkey.length > index ? styles.dotFilled : null,
                                    error ? styles.dotError : null,
                                ]}
                            />
                        ))}
                    </View>

                    {/* Error Message */}
                    {error ? (
                        <Text style={styles.errorText}>{error}</Text>
                    ) : (
                        <View style={styles.errorPlaceholder} />
                    )}

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

                    {/* Cancel Button */}
                    <TouchableOpacity style={styles.cancelButton} onPress={handleClose}>
                        <Text style={styles.cancelButtonText}>Cancel</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </Modal>
    );
}

const styles = StyleSheet.create({
    overlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    container: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.xl,
        width: '85%',
        maxWidth: 400,
        ...CARD_SHADOW,
    },
    lockContainer: {
        alignSelf: 'center',
        width: 64,
        height: 64,
        borderRadius: 32,
        backgroundColor: COLORS.surfaceContainerHighest,
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: SPACING.md,
    },
    lockIcon: {
        fontSize: 28,
    },
    title: {
        fontSize: FONT_SIZES.xl,
        fontWeight: '800',
        color: COLORS.text,
        textAlign: 'center',
        marginBottom: SPACING.xs,
        letterSpacing: -0.5,
    },
    subtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
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
        width: 20,
        height: 20,
        borderRadius: 10,
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
        fontSize: 18,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
    cancelButton: {
        padding: SPACING.md,
        alignItems: 'center',
        backgroundColor: COLORS.surfaceContainerLow,
        borderRadius: BORDER_RADIUS.xl,
    },
    cancelButtonText: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textSecondary,
        fontWeight: '600',
    },
});
