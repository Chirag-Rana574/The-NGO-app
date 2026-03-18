import React, { useState, useEffect, useRef, Component } from 'react';
import { ActivityIndicator, View, Text, StyleSheet, TouchableOpacity, AppState } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';

import HomeScreen from './src/screens/HomeScreen';
import CreateScheduleScreen from './src/screens/CreateScheduleScreen';
import EditScheduleScreen from './src/screens/EditScheduleScreen';
import MedicinesScreen from './src/screens/MedicinesScreen';
import AuditLogScreen from './src/screens/AuditLogScreen';
import PatientsScreen from './src/screens/PatientsScreen';
import WorkersScreen from './src/screens/WorkersScreen';
import SchedulesScreen from './src/screens/SchedulesScreen';
import MoreScreen from './src/screens/MoreScreen';
import SetupKeyScreen from './src/screens/SetupKeyScreen';
import LoginScreen from './src/screens/LoginScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import NotificationsScreen from './src/screens/NotificationsScreen';
import ReportScreen from './src/screens/ReportScreen';
import ExportScreen from './src/screens/ExportScreen';

import ApiService from './src/services/api.service';
import { registerForPushNotifications, addNotificationReceivedListener, addNotificationResponseListener } from './src/services/notifications';
import { syncQueue, getQueueCount } from './src/services/offline';
import { COLORS, FONT_SIZES, SPACING } from './src/constants/theme';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

const stackScreenOptions = {
    headerStyle: {
        backgroundColor: COLORS.primary,
        elevation: 0,
        shadowOpacity: 0,
    },
    headerTintColor: COLORS.white,
    headerTitleStyle: {
        fontWeight: 'bold' as const,
        fontSize: FONT_SIZES.lg,
    },
};

// Stack navigator for Home screen
function HomeStack() {
    return (
        <Stack.Navigator screenOptions={stackScreenOptions}>
            <Stack.Screen
                name="HomeMain"
                component={HomeScreen}
                options={{ title: 'Home' }}
            />
            <Stack.Screen
                name="CreateSchedule"
                component={CreateScheduleScreen}
                options={{ title: 'Create Schedule' }}
            />
            <Stack.Screen
                name="NotificationsScreen"
                component={NotificationsScreen}
                options={{ title: 'Notifications' }}
            />
        </Stack.Navigator>
    );
}

// Stack navigator for Schedules screen
function SchedulesStack() {
    return (
        <Stack.Navigator screenOptions={stackScreenOptions}>
            <Stack.Screen
                name="SchedulesMain"
                component={SchedulesScreen}
                options={{ title: 'Calendar' }}
            />
            <Stack.Screen
                name="CreateSchedule"
                component={CreateScheduleScreen}
                options={{ title: 'Create Schedule' }}
            />
            <Stack.Screen
                name="EditSchedule"
                component={EditScheduleScreen}
                options={{ title: 'Edit Schedule' }}
            />
        </Stack.Navigator>
    );
}

// Stack navigator for More section
function MoreStack() {
    return (
        <Stack.Navigator screenOptions={stackScreenOptions}>
            <Stack.Screen
                name="MoreMain"
                component={MoreScreen}
                options={{ title: 'More' }}
            />
            <Stack.Screen
                name="PatientsScreen"
                component={PatientsScreen}
                options={{ title: 'Patients' }}
            />
            <Stack.Screen
                name="WorkersScreen"
                component={WorkersScreen}
                options={{ title: 'Workers' }}
            />
            <Stack.Screen
                name="AuditLogScreen"
                component={AuditLogScreen}
                options={{ title: 'Activity Log' }}
            />
            <Stack.Screen
                name="SettingsScreen"
                component={SettingsScreen}
                options={{ title: 'Settings' }}
            />
            <Stack.Screen
                name="ExportScreen"
                component={ExportScreen}
                options={{ title: 'Export Data' }}
            />
        </Stack.Navigator>
    );
}

// Tab icon component using emoji
function TabIcon({ emoji, focused }: { emoji: string; focused: boolean }) {
    return (
        <Text style={{ fontSize: 22, opacity: focused ? 1 : 0.5 }}>
            {emoji}
        </Text>
    );
}

// Bottom tab navigator — 4 clean tabs
function MainTabs() {
    const [unreadCount, setUnreadCount] = useState(0);

    useEffect(() => {
        fetchUnread();
        const interval = setInterval(fetchUnread, 30000); // Refresh every 30s
        return () => clearInterval(interval);
    }, []);

    const fetchUnread = async () => {
        try {
            const data = await ApiService.getUnreadNotificationCount();
            setUnreadCount(data.unread_count || 0);
        } catch {
            // Silently fail
        }
    };

    return (
        <Tab.Navigator
            screenOptions={{
                tabBarActiveTintColor: COLORS.primary,
                tabBarInactiveTintColor: COLORS.textLight,
                tabBarStyle: {
                    height: 60,
                    paddingBottom: 8,
                    paddingTop: 6,
                    backgroundColor: COLORS.white,
                    borderTopWidth: 1,
                    borderTopColor: '#F0F0F0',
                },
                tabBarLabelStyle: {
                    fontSize: 11,
                    fontWeight: '600',
                },
                headerStyle: {
                    backgroundColor: COLORS.primary,
                    elevation: 0,
                    shadowOpacity: 0,
                },
                headerTintColor: COLORS.white,
                headerTitleStyle: {
                    fontWeight: 'bold',
                    fontSize: FONT_SIZES.lg,
                },
            }}
        >
            <Tab.Screen
                name="Home"
                component={HomeStack}
                options={{
                    headerShown: false,
                    tabBarLabel: 'Home',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="🏠" focused={focused} />,
                    tabBarBadge: unreadCount > 0 ? unreadCount : undefined,
                }}
            />
            <Tab.Screen
                name="Schedules"
                component={SchedulesStack}
                options={{
                    headerShown: false,
                    tabBarLabel: 'Calendar',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="📅" focused={focused} />,
                }}
            />
            <Tab.Screen
                name="Medicines"
                component={MedicinesScreen}
                options={{
                    title: 'Medicine Stock',
                    tabBarLabel: 'Stock',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="💊" focused={focused} />,
                }}
            />
            <Tab.Screen
                name="Reports"
                component={ReportScreen}
                options={{
                    title: 'Reports',
                    tabBarLabel: 'Reports',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="📊" focused={focused} />,
                }}
            />
            <Tab.Screen
                name="More"
                component={MoreStack}
                options={{
                    headerShown: false,
                    tabBarLabel: 'More',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="⋯" focused={focused} />,
                }}
            />
        </Tab.Navigator>
    );
}

// Root App with login → key setup → main flow
function App() {
    const [isLoggedIn, setIsLoggedIn] = useState<boolean | null>(null);
    const [isKeySetup, setIsKeySetup] = useState<boolean | null>(null);

    useEffect(() => {
        checkAuthState();
    }, []);

    useEffect(() => {
        if (isLoggedIn) {
            // Register push notifications after login
            registerForPushNotifications();

            // Listen for incoming notifications
            const receivedSub = addNotificationReceivedListener((notification) => {
                console.log('Notification received:', notification.request.content.title);
            });

            const responseSub = addNotificationResponseListener((response) => {
                console.log('Notification tapped:', response.notification.request.content.title);
            });

            // Sync offline queue when app comes to foreground
            const appStateSub = AppState.addEventListener('change', async (state) => {
                if (state === 'active') {
                    const count = await getQueueCount();
                    if (count > 0) {
                        console.log(`📦 ${count} items in offline queue, syncing...`);
                        const result = await syncQueue();
                        if (result.synced > 0) {
                            console.log(`✅ Synced ${result.synced} offline items`);
                        }
                    }
                }
            });

            // Try syncing immediately on login
            syncQueue().catch(() => { });

            return () => {
                receivedSub.remove();
                responseSub.remove();
                appStateSub.remove();
            };
        }
    }, [isLoggedIn]);

    const checkAuthState = async () => {
        // Check login
        const token = await AsyncStorage.getItem('jwt_token');
        if (!token) {
            setIsLoggedIn(false);
            return;
        }
        setIsLoggedIn(true);

        // Check master key
        try {
            const status = await ApiService.getKeyStatus();
            setIsKeySetup(status.is_setup);
        } catch (error) {
            console.warn('Could not check key status:', error);
            setIsKeySetup(true);
        }
    };

    // Loading
    if (isLoggedIn === null) {
        return (
            <SafeAreaProvider>
                <View style={styles.loadingContainer}>
                    <ActivityIndicator size="large" color={COLORS.primary} />
                </View>
            </SafeAreaProvider>
        );
    }

    // Login gate
    if (!isLoggedIn) {
        return (
            <SafeAreaProvider>
                <LoginScreen onLoginSuccess={() => {
                    setIsLoggedIn(true);
                    checkAuthState();
                }} />
            </SafeAreaProvider>
        );
    }

    // Key setup gate
    if (isKeySetup === null) {
        return (
            <SafeAreaProvider>
                <View style={styles.loadingContainer}>
                    <ActivityIndicator size="large" color={COLORS.primary} />
                </View>
            </SafeAreaProvider>
        );
    }

    if (!isKeySetup) {
        return (
            <SafeAreaProvider>
                <SetupKeyScreen onComplete={() => setIsKeySetup(true)} />
            </SafeAreaProvider>
        );
    }

    return (
        <SafeAreaProvider>
            <NavigationContainer>
                <MainTabs />
            </NavigationContainer>
        </SafeAreaProvider>
    );
}

const styles = StyleSheet.create({
    loadingContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: COLORS.background,
    },
});

// ─── Global Error Boundary ────────────────────────────────────────────────────
class ErrorBoundary extends Component<
    { children: React.ReactNode },
    { hasError: boolean; error: string }
> {
    constructor(props: any) {
        super(props);
        this.state = { hasError: false, error: '' };
    }

    static getDerivedStateFromError(error: any) {
        return { hasError: true, error: error?.message || String(error) };
    }

    componentDidCatch(error: any, info: any) {
        console.error('App crashed:', error, info);
    }

    render() {
        if (this.state.hasError) {
            return (
                <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 24, backgroundColor: '#fff' }}>
                    <Text style={{ fontSize: 22, fontWeight: 'bold', color: '#e74c3c', marginBottom: 12 }}>App Error</Text>
                    <Text style={{ fontSize: 13, color: '#333', textAlign: 'center', fontFamily: 'monospace' }}>
                        {this.state.error}
                    </Text>
                    <Text style={{ marginTop: 16, color: '#999', fontSize: 12 }}>Check Metro logs for full details</Text>
                </View>
            );
        }
        return this.props.children;
    }
}

export default function Root() {
    return (
        <ErrorBoundary>
            <App />
        </ErrorBoundary>
    );
}
