import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    ActivityIndicator,
    Image,
    Alert,
} from 'react-native';
import * as WebBrowser from 'expo-web-browser';
import * as AuthSession from 'expo-auth-session';
import AsyncStorage from '@react-native-async-storage/async-storage';
import ApiService from '../services/api.service';
import {
    COLORS, SPACING, FONT_SIZES, FONT_WEIGHTS,
    BORDER_RADIUS, CARD_SHADOW, LETTER_SPACING,
} from '../constants/theme';

// Required for Google auth redirect
WebBrowser.maybeCompleteAuthSession();

const GOOGLE_CLIENT_ID = '882072791591-7a7b2l5dnahhf702ait801akaood65tn.apps.googleusercontent.com';
const redirectUri = AuthSession.makeRedirectUri({
    scheme: 'ngomedicine',
});

// Log redirect URI for debugging
console.log('OAuth Redirect URI:', redirectUri);

interface LoginScreenProps {
    onLoginSuccess: () => void;
}

export default function LoginScreen({ onLoginSuccess }: LoginScreenProps) {
    const [loading, setLoading] = useState(false);

    const [request, response, promptAsync] = AuthSession.useAuthRequest(
        {
            clientId: GOOGLE_CLIENT_ID,
            redirectUri,
            scopes: ['openid', 'profile', 'email'],
            responseType: AuthSession.ResponseType.IdToken,
            usePKCE: false,   // IdToken implicit flow does not support PKCE
        },
        AuthSession.useAutoDiscovery('https://accounts.google.com')
    );

    useEffect(() => {
        if (response?.type === 'success') {
            const idToken = response.params?.id_token;
            if (idToken) {
                handleGoogleLogin(idToken);
            }
        }
    }, [response]);

    const handleGoogleLogin = async (idToken: string) => {
        setLoading(true);
        try {
            const result = await ApiService.loginWithGoogle(idToken);
            if (result?.token) {
                await AsyncStorage.setItem('jwt_token', result.token);
                await AsyncStorage.setItem('user', JSON.stringify(result.user));
                onLoginSuccess();
            }
        } catch (error: any) {
            console.error('Login error:', error);
            Alert.alert(
                'Login Failed',
                'Could not sign in with Google. Please try again.'
            );
        } finally {
            setLoading(false);
        }
    };

    return (
        <View style={styles.container}>
            {/* Subtle cross-pattern overlay */}
            <View style={styles.patternOverlay} />

            {/* Header branding */}
            <View style={styles.header}>
                <View style={styles.pillContainer}>
                    <Text style={styles.pillEmoji}>💊</Text>
                </View>
                <Text style={styles.brandName}>Vitalis NGO</Text>
                <Text style={styles.systemLabel}>ADMINISTRATION SYSTEM</Text>
            </View>

            {/* Main card */}
            <View style={styles.card}>
                <Text style={styles.welcomeText}>Welcome</Text>
                <Text style={styles.descText}>
                    Sign in to manage medicine schedules, track stock, and coordinate with workers.
                </Text>

                {/* Google Sign In */}
                <TouchableOpacity
                    style={[styles.googleButton, (!request || loading) && styles.disabledButton]}
                    onPress={() => promptAsync()}
                    disabled={!request || loading}
                    activeOpacity={0.85}
                >
                    {loading ? (
                        <ActivityIndicator color={COLORS.white} />
                    ) : (
                        <>
                            <View style={styles.googleIconContainer}>
                                <Text style={styles.googleIcon}>G</Text>
                            </View>
                            <Text style={styles.googleButtonText}>Sign in with Google</Text>
                        </>
                    )}
                </TouchableOpacity>

                {/* OR divider */}
                <View style={styles.orDivider}>
                    <View style={styles.orLine} />
                    <Text style={styles.orText}>OR</Text>
                    <View style={styles.orLine} />
                </View>

                {/* Dev bypass */}
                <TouchableOpacity
                    style={styles.devBypass}
                    onPress={async () => {
                        await AsyncStorage.setItem('jwt_token', 'dev-bypass-token');
                        await AsyncStorage.setItem('user', JSON.stringify({
                            id: 1, name: 'Admin', email: 'admin@ngo.org',
                        }));
                        onLoginSuccess();
                    }}
                    activeOpacity={0.7}
                >
                    <Text style={styles.devBypassIcon}>→</Text>
                    <Text style={styles.devBypassText}>Continue without Google (Dev)</Text>
                </TouchableOpacity>

                {/* Restricted access note */}
                <Text style={styles.restrictedNote}>
                    Restricted access for NGO personnel.
                </Text>
            </View>

            {/* Footer */}
            <Text style={styles.footerText}>
                🛡 SECURE NODE  ·  {'<>'} V2.4.0-STABLE
            </Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
        padding: SPACING.lg,
    },
    patternOverlay: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: 'rgba(0,0,0,0.03)',
    },
    header: {
        alignItems: 'center',
        marginBottom: SPACING.xl,
    },
    pillContainer: {
        width: 80,
        height: 80,
        borderRadius: BORDER_RADIUS.lg,
        backgroundColor: 'rgba(255,255,255,0.15)',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: SPACING.lg,
    },
    pillEmoji: {
        fontSize: 40,
    },
    brandName: {
        fontSize: 32,
        fontWeight: '800',
        color: COLORS.white,
        letterSpacing: LETTER_SPACING.tight,
    },
    systemLabel: {
        fontSize: FONT_SIZES.xs,
        fontWeight: '700',
        color: 'rgba(255,255,255,0.6)',
        letterSpacing: LETTER_SPACING.widest,
        marginTop: SPACING.xs,
    },
    card: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.xl,
        width: '100%',
        maxWidth: 380,
        alignItems: 'center',
        ...CARD_SHADOW,
    },
    welcomeText: {
        fontSize: FONT_SIZES.xl,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.sm,
        letterSpacing: LETTER_SPACING.tight,
    },
    descText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        textAlign: 'center',
        lineHeight: 20,
        marginBottom: SPACING.xl,
    },
    googleButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: COLORS.primary,
        paddingVertical: 16,
        paddingHorizontal: 24,
        borderRadius: BORDER_RADIUS.xl,
        width: '100%',
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 4,
    },
    disabledButton: {
        opacity: 0.6,
    },
    googleIconContainer: {
        width: 28,
        height: 28,
        borderRadius: 8,
        backgroundColor: 'rgba(255,255,255,0.2)',
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: SPACING.sm,
    },
    googleIcon: {
        fontSize: 16,
        fontWeight: 'bold',
        color: COLORS.white,
    },
    googleButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.white,
    },
    orDivider: {
        flexDirection: 'row',
        alignItems: 'center',
        width: '100%',
        marginVertical: SPACING.lg,
    },
    orLine: {
        flex: 1,
        height: 1,
        backgroundColor: COLORS.surfaceContainerHigh,
    },
    orText: {
        fontSize: FONT_SIZES.xs,
        fontWeight: '700',
        color: COLORS.textLight,
        marginHorizontal: SPACING.md,
        letterSpacing: LETTER_SPACING.wider,
    },
    devBypass: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: SPACING.md,
        width: '100%',
    },
    devBypassIcon: {
        fontSize: 16,
        color: COLORS.primary,
        fontWeight: '700',
        marginRight: SPACING.sm,
    },
    devBypassText: {
        color: COLORS.primary,
        fontSize: FONT_SIZES.sm,
        fontWeight: '600',
    },
    restrictedNote: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        textAlign: 'center',
        marginTop: SPACING.md,
    },
    footerText: {
        color: 'rgba(255,255,255,0.5)',
        fontSize: FONT_SIZES.xxs,
        marginTop: SPACING.xl,
        letterSpacing: LETTER_SPACING.wider,
        fontWeight: '600',
    },
});
