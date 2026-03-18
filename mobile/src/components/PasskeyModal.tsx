import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    Modal,
    TouchableOpacity,
    Vibration,
} from 'react-native';
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

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
    title = 'Enter Passkey',
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
                    <Text style={styles.title}>{title}</Text>
                    <Text style={styles.subtitle}>Enter 4-digit PIN</Text>

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
        backgroundColor: 'rgba(0, 0, 0, 0.7)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    container: {
        backgroundColor: COLORS.white,
        borderRadius: 24,
        padding: SPACING.xl,
        width: '85%',
        maxWidth: 400,
    },
    title: {
        fontSize: FONT_SIZES.xxl,
        fontWeight: 'bold',
        color: COLORS.text,
        textAlign: 'center',
        marginBottom: SPACING.xs,
    },
    subtitle: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
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
        borderWidth: 2,
        borderColor: COLORS.border,
        backgroundColor: COLORS.white,
    },
    dotFilled: {
        backgroundColor: COLORS.primary,
        borderColor: COLORS.primary,
    },
    dotError: {
        backgroundColor: COLORS.error,
        borderColor: COLORS.error,
    },
    errorText: {
        color: COLORS.error,
        fontSize: FONT_SIZES.md,
        textAlign: 'center',
        marginBottom: SPACING.md,
        minHeight: 24,
    },
    errorPlaceholder: {
        minHeight: 24,
        marginBottom: SPACING.md,
    },
    keypad: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: SPACING.md,
        marginBottom: SPACING.lg,
    },
    key: {
        width: 80,
        height: 80,
        borderRadius: 40,
        backgroundColor: COLORS.background,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 1,
        borderColor: COLORS.border,
    },
    keyText: {
        fontSize: 32,
        fontWeight: 'bold',
        color: COLORS.text,
    },
    keyTextSecondary: {
        fontSize: 20,
        fontWeight: '600',
        color: COLORS.textLight,
    },
    cancelButton: {
        padding: SPACING.lg,
        alignItems: 'center',
    },
    cancelButtonText: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.textLight,
        fontWeight: '600',
    },
});
