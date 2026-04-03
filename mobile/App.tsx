import React, { useState, useEffect, useRef, Component } from 'react';
import {
    ActivityIndicator, View, Text, StyleSheet, TouchableOpacity,
    AppState, Animated, Dimensions, TouchableWithoutFeedback, ScrollView,
} from 'react-native';
import { NavigationContainer, useNavigation } from '@react-navigation/native';
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
import SetupKeyScreen from './src/screens/SetupKeyScreen';
import LoginScreen from './src/screens/LoginScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import NotificationsScreen from './src/screens/NotificationsScreen';
import ReportScreen from './src/screens/ReportScreen';
import ExportScreen from './src/screens/ExportScreen';
import MoreScreen from './src/screens/MoreScreen';

import ApiService from './src/services/api.service';
import { registerForPushNotifications, addNotificationReceivedListener, addNotificationResponseListener } from './src/services/notifications';
import { syncQueue, getQueueCount } from './src/services/offline';
import { COLORS, FONT_SIZES, SPACING, HEADER_STYLE, HEADER_TITLE_STYLE, BORDER_RADIUS, CARD_SHADOW } from './src/constants/theme';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();
const SCREEN_WIDTH = Dimensions.get('window').width;
const DRAWER_WIDTH = 280;

// ─── Clinical Curator Header ─────────────────────────────────────────────────
// White header with blue "Clinical Curator" text, matching the redesign mockups

const clinicalCuratorHeaderOptions = {
    headerStyle: {
        ...HEADER_STYLE,
    },
    headerTintColor: COLORS.primary,
    headerTitleStyle: {
        ...HEADER_TITLE_STYLE,
    },
};

const stackScreenOptions = {
    ...clinicalCuratorHeaderOptions,
};

// ─── Drawer Context ───────────────────────────────────────────────────────────
const DrawerContext = React.createContext<{
    openDrawer: () => void;
    closeDrawer: () => void;
}>({ openDrawer: () => {}, closeDrawer: () => {} });

// ─── Header components ───────────────────────────────────────────────────────

function ClinicalCuratorTitle() {
    return (
        <Text style={{ fontSize: FONT_SIZES.lg, fontWeight: '700', color: COLORS.primary }}>
            Clinical Curator
        </Text>
    );
}

function HeaderAvatar() {
    const [initial, setInitial] = useState('?');

    useEffect(() => {
        AsyncStorage.getItem('user').then(u => {
            if (u) {
                const user = JSON.parse(u);
                setInitial(user?.name?.charAt(0)?.toUpperCase() || '?');
            }
        });
    }, []);

    return (
        <View style={{
            width: 36,
            height: 36,
            borderRadius: 18,
            backgroundColor: COLORS.primary,
            justifyContent: 'center',
            alignItems: 'center',
            marginRight: 16,
        }}>
            <Text style={{ color: COLORS.white, fontWeight: '700', fontSize: 14 }}>{initial}</Text>
        </View>
    );
}

function HeaderMenuButton({ onPress }: { onPress: () => void }) {
    return (
        <TouchableOpacity onPress={onPress} style={{ marginLeft: 16 }}>
            <Text style={{ fontSize: 22, color: COLORS.text }}>☰</Text>
        </TouchableOpacity>
    );
}

function HeaderMoreButton() {
    return (
        <View style={{ marginRight: 16 }}>
            <Text style={{ fontSize: 20, color: COLORS.textSecondary }}>⋮</Text>
        </View>
    );
}

// ─── Stack Navigators ─────────────────────────────────────────────────────────

function HomeStack() {
    const drawer = React.useContext(DrawerContext);
    return (
        <Stack.Navigator screenOptions={stackScreenOptions}>
            <Stack.Screen
                name="HomeMain"
                component={HomeScreen}
                options={{
                    headerTitle: () => <ClinicalCuratorTitle />,
                    headerLeft: () => <HeaderMenuButton onPress={drawer.openDrawer} />,
                    headerRight: () => <HeaderAvatar />,
                }}
            />
            <Stack.Screen name="CreateSchedule" component={CreateScheduleScreen} options={{ title: 'Create Schedule' }} />
            <Stack.Screen name="NotificationsScreen" component={NotificationsScreen} options={{ title: 'Notifications' }} />
        </Stack.Navigator>
    );
}

function SchedulesStack() {
    const drawer = React.useContext(DrawerContext);
    return (
        <Stack.Navigator screenOptions={stackScreenOptions}>
            <Stack.Screen
                name="SchedulesMain"
                component={SchedulesScreen}
                options={{
                    headerTitle: () => <ClinicalCuratorTitle />,
                    headerLeft: () => <HeaderMenuButton onPress={drawer.openDrawer} />,
                    headerRight: () => (
                        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                            <TouchableOpacity style={{ marginRight: 16 }}>
                                <Text style={{ fontSize: 20, color: COLORS.primary }}>🔍</Text>
                            </TouchableOpacity>
                            <HeaderMoreButton />
                        </View>
                    ),
                }}
            />
            <Stack.Screen name="CreateSchedule" component={CreateScheduleScreen} options={{ title: 'Create Schedule' }} />
            <Stack.Screen name="EditSchedule" component={EditScheduleScreen} options={{ title: 'Edit Schedule' }} />
        </Stack.Navigator>
    );
}

// ─── Tab Icon Component ───────────────────────────────────────────────────────

function TabIcon({ emoji, focused }: { emoji: string; focused: boolean }) {
    return (
        <Text style={{ fontSize: 22, opacity: focused ? 1 : 0.5 }}>
            {emoji}
        </Text>
    );
}

// ─── Bottom Tabs: 5 main screens ──────────────────────────────────────────────

function MainTabs({ onSwipe }: { onSwipe?: (dir: 'left' | 'right') => void }) {
    const [unreadCount, setUnreadCount] = useState(0);

    useEffect(() => {
        fetchUnread();
        const interval = setInterval(fetchUnread, 30000);
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
            screenListeners={{
                state: () => {},
            }}
            screenOptions={{
                tabBarActiveTintColor: COLORS.primary,
                tabBarInactiveTintColor: COLORS.textLight,
                tabBarStyle: {
                    position: 'absolute',
                    bottom: 16,
                    left: 16,
                    right: 16,
                    height: 68,
                    paddingBottom: 10,
                    paddingTop: 8,
                    backgroundColor: 'rgba(255,255,255,0.95)',
                    borderTopWidth: 0,
                    borderRadius: 24,
                    shadowColor: COLORS.primary,
                    shadowOffset: { width: 0, height: -4 },
                    shadowOpacity: 0.08,
                    shadowRadius: 16,
                    elevation: 12,
                },
                tabBarLabelStyle: {
                    fontSize: 10,
                    fontWeight: '600',
                    letterSpacing: 0.5,
                    textTransform: 'uppercase',
                },
                ...clinicalCuratorHeaderOptions,
            }}
        >
            <Tab.Screen
                name="Home"
                component={HomeStack}
                options={{
                    headerShown: false,
                    tabBarLabel: 'HOME',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="🏠" focused={focused} />,
                    tabBarBadge: unreadCount > 0 ? unreadCount : undefined,
                }}
            />
            <Tab.Screen
                name="Schedules"
                component={SchedulesStack}
                options={{
                    headerShown: false,
                    tabBarLabel: 'SCHEDULES',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="📅" focused={focused} />,
                }}
            />
            <Tab.Screen
                name="Patients"
                component={PatientsScreen}
                options={{
                    headerShown: true,
                    headerTitle: () => <ClinicalCuratorTitle />,
                    headerRight: () => (
                        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                            <TouchableOpacity style={{ marginRight: 16 }}>
                                <Text style={{ fontSize: 20, color: COLORS.primary }}>🔍</Text>
                            </TouchableOpacity>
                            <HeaderMoreButton />
                        </View>
                    ),
                    tabBarLabel: 'PATIENTS',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="👥" focused={focused} />,
                }}
            />
            <Tab.Screen
                name="Medicines"
                component={MedicinesScreen}
                options={{
                    headerShown: true,
                    headerTitle: () => <ClinicalCuratorTitle />,
                    headerRight: () => <HeaderMoreButton />,
                    tabBarLabel: 'STOCK',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="💊" focused={focused} />,
                }}
            />
            <Tab.Screen
                name="Workers"
                component={WorkersScreen}
                options={{
                    headerShown: true,
                    headerTitle: () => <ClinicalCuratorTitle />,
                    headerRight: () => <HeaderMoreButton />,
                    tabBarLabel: 'WORKERS',
                    tabBarIcon: ({ focused }) => <TabIcon emoji="👷" focused={focused} />,
                }}
            />
        </Tab.Navigator>
    );
}

// ─── Custom Drawer Sidebar ────────────────────────────────────────────────────

interface SidebarProps {
    isOpen: boolean;
    onClose: () => void;
    onLogout: () => void;
    navigationRef: React.RefObject<any>;
}

function DrawerItem({ icon, label, onPress, isDestructive }: {
    icon: string; label: string; onPress: () => void; isDestructive?: boolean;
}) {
    return (
        <TouchableOpacity style={dStyles.item} onPress={onPress} activeOpacity={0.7}>
            <Text style={dStyles.itemIcon}>{icon}</Text>
            <Text style={[dStyles.itemLabel, isDestructive && { color: '#EF4444', fontWeight: '600' }]}>
                {label}
            </Text>
        </TouchableOpacity>
    );
}

function Sidebar({ isOpen, onClose, onLogout, navigationRef }: SidebarProps) {
    const translateX = useRef(new Animated.Value(-DRAWER_WIDTH)).current;
    const overlayOpacity = useRef(new Animated.Value(0)).current;
    const [user, setUser] = useState<any>(null);

    useEffect(() => {
        AsyncStorage.getItem('user').then(u => {
            if (u) setUser(JSON.parse(u));
        });
    }, []);

    useEffect(() => {
        Animated.parallel([
            Animated.timing(translateX, {
                toValue: isOpen ? 0 : -DRAWER_WIDTH,
                duration: 250,
                useNativeDriver: true,
            }),
            Animated.timing(overlayOpacity, {
                toValue: isOpen ? 0.5 : 0,
                duration: 250,
                useNativeDriver: true,
            }),
        ]).start();
    }, [isOpen]);

    const navigateTo = (screen: string, tab?: string) => {
        onClose();
        if (navigationRef.current) {
            if (tab) {
                navigationRef.current.navigate(tab);
            } else {
                navigationRef.current.navigate(screen);
            }
        }
    };

    if (!isOpen) {
        return null;
    }

    return (
        <View style={dStyles.overlay}>
            {/* Dark overlay */}
            <TouchableWithoutFeedback onPress={onClose}>
                <Animated.View style={[dStyles.backdrop, { opacity: overlayOpacity }]} />
            </TouchableWithoutFeedback>

            {/* Drawer panel */}
            <Animated.View style={[dStyles.panel, { transform: [{ translateX }] }]}>
                <ScrollView contentContainerStyle={{ flexGrow: 1 }}>
                    {/* Profile header */}
                    <View style={dStyles.header}>
                        <View style={dStyles.avatar}>
                            <Text style={dStyles.avatarText}>
                                {user?.name?.charAt(0)?.toUpperCase() || '?'}
                            </Text>
                        </View>
                        <Text style={dStyles.userName}>{user?.name || 'Admin'}</Text>
                        <Text style={dStyles.userEmail}>{user?.email || ''}</Text>
                    </View>

                    {/* Navigate */}
                    <Text style={dStyles.sectionTitle}>NAVIGATE</Text>
                    <DrawerItem icon="🏠" label="Home" onPress={() => navigateTo('Home', 'Home')} />
                    <DrawerItem icon="📅" label="Schedules" onPress={() => navigateTo('Schedules', 'Schedules')} />
                    <DrawerItem icon="👥" label="Patients" onPress={() => navigateTo('Patients', 'Patients')} />
                    <DrawerItem icon="💊" label="Medicine Stock" onPress={() => navigateTo('Medicines', 'Medicines')} />
                    <DrawerItem icon="👷" label="Workers" onPress={() => navigateTo('Workers', 'Workers')} />

                    <View style={dStyles.divider} />

                    {/* Tools */}
                    <Text style={dStyles.sectionTitle}>TOOLS</Text>
                    <DrawerItem icon="📊" label="Reports" onPress={() => navigateTo('ReportsScreen')} />
                    <DrawerItem icon="📋" label="Activity Log" onPress={() => navigateTo('AuditLogScreen')} />
                    <DrawerItem icon="📤" label="Export Data" onPress={() => navigateTo('ExportScreen')} />
                    <DrawerItem icon="🔔" label="Notifications" onPress={() => navigateTo('NotificationsScreen')} />

                    <View style={dStyles.divider} />

                    {/* Account */}
                    <Text style={dStyles.sectionTitle}>ACCOUNT</Text>
                    <DrawerItem icon="⚙️" label="Settings" onPress={() => navigateTo('SettingsScreen')} />
                    <DrawerItem icon="🚪" label="Sign Out" isDestructive onPress={async () => {
                        onClose();
                        await AsyncStorage.multiRemove(['jwt_token', 'user']);
                        onLogout();
                    }} />

                    {/* Footer */}
                    <View style={dStyles.footer}>
                        <Text style={dStyles.footerText}>Clinical Curator v2.4.0</Text>
                    </View>
                </ScrollView>
            </Animated.View>
        </View>
    );
}

const dStyles = StyleSheet.create({
    overlay: {
        ...StyleSheet.absoluteFillObject,
        zIndex: 1000,
        elevation: 1000,
    },
    backdrop: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: '#000',
    },
    panel: {
        position: 'absolute',
        top: 0,
        left: 0,
        bottom: 0,
        width: DRAWER_WIDTH,
        backgroundColor: COLORS.white,
        shadowColor: COLORS.primary,
        shadowOffset: { width: 4, height: 0 },
        shadowOpacity: 0.15,
        shadowRadius: 16,
        elevation: 20,
    },
    header: {
        backgroundColor: COLORS.primary,
        paddingHorizontal: 20,
        paddingTop: 50,
        paddingBottom: 20,
    },
    avatar: {
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: 'rgba(255,255,255,0.25)',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 10,
    },
    avatarText: {
        fontSize: 24,
        fontWeight: 'bold',
        color: COLORS.white,
    },
    userName: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.white,
    },
    userEmail: {
        fontSize: FONT_SIZES.sm,
        color: 'rgba(255,255,255,0.7)',
        marginTop: 2,
    },
    divider: {
        height: 1,
        backgroundColor: COLORS.surfaceContainerLow,
        marginHorizontal: 16,
        marginVertical: 8,
    },
    sectionTitle: {
        fontSize: 11,
        fontWeight: '700',
        color: COLORS.textLight,
        letterSpacing: 1.2,
        paddingHorizontal: 20,
        paddingTop: 12,
        paddingBottom: 6,
    },
    item: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingVertical: 12,
        marginHorizontal: 8,
        borderRadius: 8,
    },
    itemIcon: {
        fontSize: 20,
        width: 32,
    },
    itemLabel: {
        fontSize: FONT_SIZES.md,
        fontWeight: '500',
        color: COLORS.text,
    },
    footer: {
        marginTop: 'auto',
        alignItems: 'center',
        paddingVertical: 20,
        borderTopWidth: 1,
        borderTopColor: COLORS.surfaceContainerLow,
        marginHorizontal: 16,
    },
    footerText: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
    },
});

// ─── Main Navigator (Tabs + drawer-only screens in a root stack) ──────────────

function MainNavigator({ onLogout }: { onLogout: () => void }) {
    const [drawerOpen, setDrawerOpen] = useState(false);
    const navigationRef = useRef<any>(null);
    const currentTabIdx = useRef(0);
    const TAB_NAMES = ['Home', 'Schedules', 'Patients', 'Medicines', 'Workers'];

    const drawerContext = {
        openDrawer: () => setDrawerOpen(true),
        closeDrawer: () => setDrawerOpen(false),
    };

    // Track current tab from navigation state changes
    const onStateChange = (state: any) => {
        if (state) {
            // Find the MainTabs route and get its index
            const tabsRoute = state.routes?.find((r: any) => r.name === 'MainTabs');
            if (tabsRoute?.state?.index !== undefined) {
                currentTabIdx.current = tabsRoute.state.index;
            }
        }
    };

    // PanResponder for horizontal swipe between tabs
    const panResponder = useRef(
        React.useMemo(() => (
            require('react-native').PanResponder.create({
                onMoveShouldSetPanResponder: (_: any, gs: any) => {
                    // Only capture clearly horizontal swipes
                    return Math.abs(gs.dx) > 25 && Math.abs(gs.dx) > Math.abs(gs.dy) * 2.5;
                },
                onPanResponderRelease: (_: any, gs: any) => {
                    if (Math.abs(gs.dx) > 80) {
                        const idx = currentTabIdx.current;
                        if (gs.dx < 0 && idx < TAB_NAMES.length - 1) {
                            // Swipe left → next tab
                            navigationRef.current?.navigate('MainTabs', {
                                screen: TAB_NAMES[idx + 1],
                            });
                        } else if (gs.dx > 0 && idx > 0) {
                            // Swipe right → prev tab
                            navigationRef.current?.navigate('MainTabs', {
                                screen: TAB_NAMES[idx - 1],
                            });
                        }
                    }
                },
            })
        ), [])
    ).current;

    return (
        <DrawerContext.Provider value={drawerContext}>
            <NavigationContainer ref={navigationRef} onStateChange={onStateChange}>
                <View style={{ flex: 1 }} {...panResponder.panHandlers}>
                    <Stack.Navigator screenOptions={{ ...stackScreenOptions, headerShown: false }}>
                        <Stack.Screen name="MainTabs" component={MainTabs} />
                        <Stack.Screen
                            name="ReportsScreen"
                            component={ReportScreen}
                            options={{ headerShown: true, headerTitle: () => <ClinicalCuratorTitle /> }}
                        />
                        <Stack.Screen
                            name="AuditLogScreen"
                            component={AuditLogScreen}
                            options={{ headerShown: true, headerTitle: () => <ClinicalCuratorTitle /> }}
                        />
                        <Stack.Screen
                            name="ExportScreen"
                            component={ExportScreen}
                            options={{ headerShown: true, headerTitle: () => <ClinicalCuratorTitle /> }}
                        />
                        <Stack.Screen
                            name="NotificationsScreen"
                            component={NotificationsScreen}
                            options={{ headerShown: true, headerTitle: () => <ClinicalCuratorTitle /> }}
                        />
                        <Stack.Screen
                            name="SettingsScreen"
                            options={{ headerShown: true, headerTitle: () => <ClinicalCuratorTitle /> }}
                        >
                            {(props) => <SettingsScreen {...props} onLogout={onLogout} />}
                        </Stack.Screen>
                        <Stack.Screen
                            name="MoreScreen"
                            component={MoreScreen}
                            options={{ headerShown: true, headerTitle: () => <ClinicalCuratorTitle /> }}
                        />
                    </Stack.Navigator>

                    {/* Custom animated drawer overlay */}
                    <Sidebar
                        isOpen={drawerOpen}
                        onClose={() => setDrawerOpen(false)}
                        onLogout={onLogout}
                        navigationRef={navigationRef}
                    />
                </View>
            </NavigationContainer>
        </DrawerContext.Provider>
    );
}

// ─── Root App with login → key setup → main flow ─────────────────────────────

function App() {
    const [isLoggedIn, setIsLoggedIn] = useState<boolean | null>(null);
    const [isKeySetup, setIsKeySetup] = useState<boolean | null>(null);

    useEffect(() => {
        checkAuthState();
    }, []);

    useEffect(() => {
        if (isLoggedIn) {
            registerForPushNotifications();

            const receivedSub = addNotificationReceivedListener((notification) => {
                console.log('Notification received:', notification.request.content.title);
            });

            const responseSub = addNotificationResponseListener((response) => {
                console.log('Notification tapped:', response.notification.request.content.title);
            });

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

            syncQueue().catch(() => { });

            return () => {
                receivedSub.remove();
                responseSub.remove();
                appStateSub.remove();
            };
        }
    }, [isLoggedIn]);

    const checkAuthState = async () => {
        const token = await AsyncStorage.getItem('jwt_token');
        if (!token) {
            setIsLoggedIn(false);
            return;
        }
        setIsLoggedIn(true);

        try {
            const status = await ApiService.getKeyStatus();
            setIsKeySetup(status.is_setup);
        } catch (error) {
            console.warn('Could not check key status:', error);
            setIsKeySetup(true);
        }
    };

    if (isLoggedIn === null) {
        return (
            <SafeAreaProvider>
                <View style={styles.loadingContainer}>
                    <ActivityIndicator size="large" color={COLORS.primary} />
                </View>
            </SafeAreaProvider>
        );
    }

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
            <MainNavigator onLogout={() => setIsLoggedIn(false)} />
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
