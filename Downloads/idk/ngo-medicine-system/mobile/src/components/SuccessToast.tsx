import React, { useEffect, useRef } from 'react';
import {
    View,
    Text,
    StyleSheet,
    Animated,
} from 'react-native';
import { COLORS, SPACING, FONT_SIZES, BORDER_RADIUS } from '../constants/theme';

interface SuccessToastProps {
    visible: boolean;
    message: string;
    onHide: () => void;
    duration?: number;
}

export default function SuccessToast({
    visible,
    message,
    onHide,
    duration = 2000,
}: SuccessToastProps) {
    const opacity = useRef(new Animated.Value(0)).current;
    const translateY = useRef(new Animated.Value(-100)).current;

    useEffect(() => {
        if (visible) {
            // Fade in and slide down
            Animated.parallel([
                Animated.timing(opacity, {
                    toValue: 1,
                    duration: 300,
                    useNativeDriver: true,
                }),
                Animated.spring(translateY, {
                    toValue: 0,
                    tension: 50,
                    friction: 7,
                    useNativeDriver: true,
                }),
            ]).start();

            // Auto-hide after duration
            const timer = setTimeout(() => {
                Animated.parallel([
                    Animated.timing(opacity, {
                        toValue: 0,
                        duration: 300,
                        useNativeDriver: true,
                    }),
                    Animated.timing(translateY, {
                        toValue: -100,
                        duration: 300,
                        useNativeDriver: true,
                    }),
                ]).start(() => {
                    onHide();
                });
            }, duration);

            return () => clearTimeout(timer);
        }
    }, [visible, duration, onHide, opacity, translateY]);

    if (!visible) return null;

    return (
        <Animated.View
            style={[
                styles.container,
                {
                    opacity,
                    transform: [{ translateY }],
                },
            ]}
        >
            <View style={styles.content}>
                <View style={styles.iconContainer}>
                    <Text style={styles.icon}>✓</Text>
                </View>
                <Text style={styles.message}>{message}</Text>
            </View>
        </Animated.View>
    );
}

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        top: 60,
        left: SPACING.lg,
        right: SPACING.lg,
        zIndex: 9999,
    },
    content: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.success,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        // Tinted ambient shadow
        shadowColor: COLORS.success,
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.25,
        shadowRadius: 16,
        elevation: 8,
    },
    iconContainer: {
        width: 32,
        height: 32,
        borderRadius: 16,
        backgroundColor: 'rgba(255,255,255,0.25)',
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.md,
    },
    icon: {
        fontSize: 18,
        color: COLORS.white,
        fontWeight: 'bold',
    },
    message: {
        flex: 1,
        fontSize: FONT_SIZES.md,
        color: COLORS.white,
        fontWeight: '600',
    },
});
