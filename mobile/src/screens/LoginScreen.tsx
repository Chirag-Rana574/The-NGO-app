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
import { COLORS, SPACING, FONT_SIZES } from '../constants/theme';

// Required for Google auth redirect
WebBrowser.maybeCompleteAuthSession();

const GOOGLE_CLIENT_ID = '882072791591-7a7b2l5dnahhf702ait801akaood65tn.apps.googleusercontent.com';
const redirectUri = AuthSession.makeRedirectUri();

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
            <View style={styles.header}>
                <Text style={styles.emoji}>💊</Text>
                <Text style={styles.title}>NGO Medicine</Text>
                <Text style={styles.subtitle}>Administration System</Text>
            </View>

            <View style={styles.card}>
                <Text style={styles.welcomeText}>Welcome</Text>
                <Text style={styles.descText}>
                    Sign in to manage medicine schedules, track stock, and coordinate with workers.
                </Text>

                <TouchableOpacity
                    style={[styles.googleButton, (!request || loading) && styles.disabledButton]}
                    onPress={() => promptAsync()}
                    disabled={!request || loading}
                >
                    {loading ? (
                        <ActivityIndicator color={COLORS.white} />
                    ) : (
                        <>
                            <Text style={styles.googleIcon}>G</Text>
                            <Text style={styles.googleButtonText}>Sign in with Google</Text>
                        </>
                    )}
                </TouchableOpacity>
            </View>

            <Text style={styles.footerText}>
                Secure login powered by Google
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
    header: {
        alignItems: 'center',
        marginBottom: SPACING.xl * 2,
    },
    emoji: {
        fontSize: 64,
        marginBottom: SPACING.md,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: COLORS.white,
        letterSpacing: 1,
    },
    subtitle: {
        fontSize: FONT_SIZES.md,
        color: 'rgba(255,255,255,0.8)',
        marginTop: 4,
    },
    card: {
        backgroundColor: COLORS.white,
        borderRadius: 20,
        padding: SPACING.xl,
        width: '100%',
        maxWidth: 360,
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 12,
        elevation: 8,
    },
    welcomeText: {
        fontSize: 22,
        fontWeight: 'bold',
        color: COLORS.text,
        marginBottom: SPACING.sm,
    },
    descText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        textAlign: 'center',
        lineHeight: 20,
        marginBottom: SPACING.lg,
    },
    googleButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#4285F4',
        paddingVertical: 14,
        paddingHorizontal: 24,
        borderRadius: 12,
        width: '100%',
        shadowColor: '#4285F4',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.3,
        shadowRadius: 4,
        elevation: 4,
    },
    disabledButton: {
        opacity: 0.6,
    },
    googleIcon: {
        fontSize: 20,
        fontWeight: 'bold',
        color: COLORS.white,
        marginRight: 10,
        backgroundColor: 'rgba(255,255,255,0.2)',
        width: 30,
        height: 30,
        textAlign: 'center',
        lineHeight: 30,
        borderRadius: 6,
    },
    googleButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.white,
    },
    footerText: {
        color: 'rgba(255,255,255,0.6)',
        fontSize: FONT_SIZES.xs,
        marginTop: SPACING.xl,
    },
});
