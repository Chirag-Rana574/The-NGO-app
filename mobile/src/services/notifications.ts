/**
 * Push notification service for Expo.
 * Handles registration, permission requests, and notification listeners.
 */
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import Constants from 'expo-constants';
import { Platform, Alert } from 'react-native';
import ApiService from './api.service';

// Configure how notifications appear when the app is in the foreground
// Wrapped in try/catch — this runs at module import time and can crash
// if the native Notifications module isn't ready yet
try {
    Notifications.setNotificationHandler({
        handleNotification: async () => ({
            shouldShowAlert: true,
            shouldPlaySound: true,
            shouldSetBadge: true,
            shouldShowBanner: true,
            shouldShowList: true,
        }),
    });
} catch (e) {
    console.warn('Notifications.setNotificationHandler failed:', e);
}

/**
 * Register for push notifications and return the Expo Push Token.
 * Sends the token to the backend.
 */
export async function registerForPushNotifications(): Promise<string | null> {
    let token: string | null = null;

    // Must be a physical device
    if (!Device.isDevice) {
        console.log('Push notifications require a physical device');
        return null;
    }

    // Check/request permission
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;

    if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
    }

    if (finalStatus !== 'granted') {
        console.log('Push notification permission not granted');
        return null;
    }

    // Get Expo Push Token
    try {
        // Push notifications are removed from Expo Go via remote in SDK 53
        if (Constants.appOwnership === 'expo') {
            console.log('Push notifications are not fully supported in Expo Go SDK 53+. Skipping push token registration.');
            return null;
        }

        const projectId = Constants.expoConfig?.extra?.eas?.projectId
            ?? Constants.easConfig?.projectId ?? 'default-project-id';

        const pushToken = await Notifications.getExpoPushTokenAsync({
            projectId: projectId,
        });
        token = pushToken.data;
        console.log('Expo Push Token:', token);
    } catch (error) {
        // Using console.log instead of error to avoid red screen blocks in dev
        console.log('Registration for push token failed (expected in dev/simulators):', error);
        return null;
    }

    // Android notification channel
    if (Platform.OS === 'android') {
        await Notifications.setNotificationChannelAsync('default', {
            name: 'Default',
            importance: Notifications.AndroidImportance.MAX,
            vibrationPattern: [0, 250, 250, 250],
            lightColor: '#0058BE',
        });
    }

    // Register token with backend
    try {
        await ApiService.registerPushToken(token, `${Device.modelName} (${Platform.OS})`);
        console.log('Push token registered with backend');
    } catch (error) {
        console.error('Failed to register push token with backend:', error);
    }

    return token;
}

/**
 * Add a listener for when a notification is received while the app is foregrounded.
 */
export function addNotificationReceivedListener(
    callback: (notification: Notifications.Notification) => void
): Notifications.EventSubscription {
    return Notifications.addNotificationReceivedListener(callback);
}

/**
 * Add a listener for when the user taps on a notification.
 */
export function addNotificationResponseListener(
    callback: (response: Notifications.NotificationResponse) => void
): Notifications.EventSubscription {
    return Notifications.addNotificationResponseReceivedListener(callback);
}

/**
 * Unregister push token on logout.
 */
export async function unregisterPushToken(token: string): Promise<void> {
    try {
        await ApiService.unregisterPushToken(token);
        console.log('Push token unregistered');
    } catch (error) {
        console.error('Failed to unregister push token:', error);
    }
}
