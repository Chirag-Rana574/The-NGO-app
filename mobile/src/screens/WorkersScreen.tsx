import React, { useState, useEffect, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    TouchableOpacity,
    RefreshControl,
    ActivityIndicator,
    Alert,
    Modal,
    TextInput,
    Linking,
} from 'react-native';
import ApiService from '../services/api.service';
import SuccessToast from '../components/SuccessToast';
import { Worker } from '../types';
import {
    COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

const STATUS_LABELS_WORKER = ['ACTIVE', 'ON DUTY', 'OFFLINE'];
const STATUS_COLORS_WORKER: Record<string, string> = {
    'ACTIVE': COLORS.green,
    'ON DUTY': COLORS.primary,
    'OFFLINE': COLORS.textLight,
};

export default function WorkersScreen() {
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [modalVisible, setModalVisible] = useState(false);
    const [editingWorker, setEditingWorker] = useState<Worker | null>(null);
    const [formData, setFormData] = useState({ name: '', mobile_number: '' });
    const [showSuccessToast, setShowSuccessToast] = useState(false);
    const [successMessage, setSuccessMessage] = useState('');
    const [searchQuery, setSearchQuery] = useState('');

    const loadWorkers = useCallback(async () => {
        try {
            const data = await ApiService.getWorkers(true);
            setWorkers(data);
        } catch (error) {
            console.error('Failed to load workers:', error);
            Alert.alert('Error', 'Failed to load workers');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        loadWorkers();
    }, [loadWorkers]);

    const onRefresh = () => {
        setRefreshing(true);
        loadWorkers();
    };

    const openAddModal = () => {
        setEditingWorker(null);
        setFormData({ name: '', mobile_number: '' });
        setModalVisible(true);
    };

    const openEditModal = (worker: Worker) => {
        setEditingWorker(worker);
        setFormData({ name: worker.name, mobile_number: worker.mobile_number });
        setModalVisible(true);
    };

    const closeModal = () => {
        setModalVisible(false);
        setEditingWorker(null);
        setFormData({ name: '', mobile_number: '' });
    };

    const handleSave = async () => {
        if (!formData.name.trim()) {
            Alert.alert('Validation Error', 'Please enter a name');
            return;
        }
        if (!formData.mobile_number.trim()) {
            Alert.alert('Validation Error', 'Please enter a mobile number');
            return;
        }
        try {
            if (editingWorker) {
                await ApiService.updateWorker(editingWorker.id, formData);
                setSuccessMessage('Worker updated successfully');
            } else {
                await ApiService.createWorker(formData);
                setSuccessMessage('Worker added successfully');
            }
            setShowSuccessToast(true);
            closeModal();
            loadWorkers();
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to save worker';
            Alert.alert('Error', errorMsg);
        }
    };

    const handleDelete = async () => {
        if (!editingWorker) return;
        Alert.alert(
            'Confirm Delete',
            `Are you sure you want to remove ${editingWorker.name}?`,
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                        try {
                            await ApiService.deleteWorker(editingWorker.id);
                            setSuccessMessage('Worker removed successfully');
                            setShowSuccessToast(true);
                            closeModal();
                            loadWorkers();
                        } catch (error: any) {
                            const errorMsg = error.response?.data?.detail || 'Failed to delete worker';
                            Alert.alert('Error', errorMsg);
                        }
                    },
                },
            ]
        );
    };

    const openWhatsApp = (phone: string) => {
        const url = `https://wa.me/${phone.replace(/[^\d+]/g, '')}`;
        Linking.openURL(url).catch(() => Alert.alert('Error', 'Cannot open WhatsApp'));
    };

    // ─── Helpers ──────────────────────────────────────────────────
    const getInitials = (name: string) => {
        const parts = name.trim().split(' ');
        return parts.length > 1
            ? `${parts[0][0]}${parts[1][0]}`.toUpperCase()
            : name.substring(0, 2).toUpperCase();
    };

    const getWorkerStatus = (index: number) => STATUS_LABELS_WORKER[index % 3];

    const filteredWorkers = workers.filter(w =>
        w.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        w.mobile_number.includes(searchQuery)
    );

    // ─── Card Renderer ────────────────────────────────────────────
    const renderWorkerItem = ({ item, index }: { item: Worker; index: number }) => {
        const status = getWorkerStatus(index);
        const statusColor = STATUS_COLORS_WORKER[status];

        return (
            <View style={styles.workerCard}>
                {/* Header row */}
                <View style={styles.workerHeaderRow}>
                    <View style={styles.avatarContainer}>
                        <View style={styles.avatar}>
                            <Text style={styles.avatarText}>{getInitials(item.name)}</Text>
                        </View>
                    </View>
                    <View style={styles.workerInfo}>
                        <Text style={styles.workerName}>{item.name}</Text>
                        <Text style={styles.workerSubtitle}>
                            DISTRICT {String.fromCharCode(65 + (index % 3))} • {['SENIOR FIELD WORKER', 'LOGISTICS LEAD', 'FIELD NURSE'][index % 3]}
                        </Text>
                    </View>
                    <View style={[styles.statusBadge, { borderColor: statusColor }]}>
                        <Text style={[styles.statusBadgeText, { color: statusColor }]}>{status}</Text>
                    </View>
                </View>

                {/* WhatsApp Contact */}
                <View style={styles.whatsappSection}>
                    <Text style={styles.whatsappLabel}>WHATSAPP CONTACT</Text>
                    <View style={styles.phoneRow}>
                        <Text style={styles.whatsappIcon}>💬</Text>
                        <Text style={styles.phoneNumber}>{item.mobile_number}</Text>
                    </View>
                </View>

                {/* Action buttons */}
                <View style={styles.actionRow}>
                    <TouchableOpacity
                        style={styles.detailsBtn}
                        onPress={() => openEditModal(item)}
                    >
                        <Text style={styles.detailsBtnText}>Details</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.messageBtn}
                        onPress={() => openWhatsApp(item.mobile_number)}
                    >
                        <Text style={styles.messageBtnText}>Message</Text>
                    </TouchableOpacity>
                </View>
            </View>
        );
    };

    // ─── Header ───────────────────────────────────────────────────
    const ListHeader = () => (
        <View style={styles.headerSection}>
            <Text style={styles.sectionLabel}>MANAGEMENT</Text>
            <Text style={styles.heroTitle}>Workers</Text>
            <Text style={styles.heroDescription}>
                Connect and coordinate with your regional field team. Real-time updates and direct contact integration.
            </Text>

            {/* Search bar */}
            <View style={styles.searchRow}>
                <View style={styles.searchBar}>
                    <Text style={styles.searchIcon}>🔍</Text>
                    <TextInput
                        style={styles.searchInput}
                        placeholder="Search by name or district..."
                        placeholderTextColor={COLORS.textHint}
                        value={searchQuery}
                        onChangeText={setSearchQuery}
                    />
                </View>
                <TouchableOpacity style={styles.filterBtn}>
                    <Text style={styles.filterIcon}>☰</Text>
                </TouchableOpacity>
            </View>
        </View>
    );

    // ─── Onboard card ─────────────────────────────────────────────
    const ListFooter = () => (
        <TouchableOpacity style={styles.onboardCard} onPress={openAddModal} activeOpacity={0.7}>
            <Text style={styles.onboardIcon}>👤+</Text>
            <Text style={styles.onboardTitle}>Onboard New Worker</Text>
            <Text style={styles.onboardDesc}>Add a new field agent to your regional directory.</Text>
        </TouchableOpacity>
    );

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return (
        <View style={styles.container}>
            <SuccessToast
                visible={showSuccessToast}
                message={successMessage}
                onHide={() => setShowSuccessToast(false)}
            />

            <FlatList
                data={filteredWorkers}
                renderItem={renderWorkerItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                ListHeaderComponent={<ListHeader />}
                ListFooterComponent={<ListFooter />}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>👷</Text>
                        <Text style={styles.emptyText}>No workers yet</Text>
                        <Text style={styles.emptySubtext}>Tap the card below to onboard one</Text>
                    </View>
                }
                showsVerticalScrollIndicator={false}
            />

            {/* FAB */}
            <TouchableOpacity style={styles.fab} onPress={openAddModal} activeOpacity={0.85}>
                <Text style={styles.fabText}>+</Text>
            </TouchableOpacity>

            {/* Add/Edit Modal */}
            <Modal
                visible={modalVisible}
                transparent
                animationType="slide"
                onRequestClose={closeModal}
            >
                <View style={styles.modalOverlay}>
                    <View style={styles.modalContainer}>
                        <View style={styles.modalHeader}>
                            <Text style={styles.modalBrand}>CLINICAL CURATOR</Text>
                            <TouchableOpacity onPress={closeModal}>
                                <Text style={styles.modalClose}>✕</Text>
                            </TouchableOpacity>
                        </View>

                        <Text style={styles.modalTitle}>
                            {editingWorker ? 'Edit Worker' : 'Onboard New Worker'}
                        </Text>

                        <Text style={styles.formLabel}>FULL NAME</Text>
                        <View style={styles.inputContainer}>
                            <TextInput
                                style={styles.input}
                                value={formData.name}
                                onChangeText={(text) => setFormData({ ...formData, name: text })}
                                placeholder="Enter worker name"
                                placeholderTextColor={COLORS.textHint}
                            />
                        </View>

                        <Text style={styles.formLabel}>MOBILE NUMBER</Text>
                        <View style={styles.inputContainer}>
                            <TextInput
                                style={styles.input}
                                value={formData.mobile_number}
                                onChangeText={(text) => setFormData({ ...formData, mobile_number: text })}
                                placeholder="Enter mobile number"
                                placeholderTextColor={COLORS.textHint}
                                keyboardType="phone-pad"
                            />
                        </View>

                        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
                            <Text style={styles.saveButtonText}>
                                {editingWorker ? '💾  Save Changes' : '➕  Add Worker'}
                            </Text>
                        </TouchableOpacity>

                        <TouchableOpacity style={styles.cancelButton} onPress={closeModal}>
                            <Text style={styles.cancelButtonText}>Cancel</Text>
                        </TouchableOpacity>

                        {editingWorker && (
                            <TouchableOpacity style={styles.deleteButton} onPress={handleDelete}>
                                <Text style={styles.deleteButtonText}>🗑  Delete Worker</Text>
                            </TouchableOpacity>
                        )}
                    </View>
                </View>
            </Modal>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    listContainer: {
        paddingBottom: 100,
    },

    // ─── Header Section ─────────────────────────────────────────
    headerSection: {
        paddingHorizontal: SPACING.lg,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.md,
    },
    sectionLabel: {
        ...SECTION_HEADER_STYLE,
        color: COLORS.textSecondary,
    },
    heroTitle: {
        fontSize: 32,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    heroDescription: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
        marginBottom: SPACING.lg,
    },
    searchRow: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: SPACING.sm,
    },
    searchBar: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm,
        ...CARD_SHADOW,
    },
    searchIcon: {
        fontSize: 16,
        marginRight: SPACING.sm,
    },
    searchInput: {
        flex: 1,
        fontSize: FONT_SIZES.sm,
        color: COLORS.text,
    },
    filterBtn: {
        width: 44,
        height: 44,
        borderRadius: 22,
        backgroundColor: COLORS.white,
        justifyContent: 'center',
        alignItems: 'center',
        ...CARD_SHADOW,
    },
    filterIcon: {
        fontSize: 18,
        color: COLORS.textSecondary,
    },

    // ─── Worker Card ────────────────────────────────────────────
    workerCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.md,
        borderLeftWidth: 4,
        borderLeftColor: COLORS.green,
        ...CARD_SHADOW,
    },
    workerHeaderRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: SPACING.md,
    },
    avatarContainer: {
        marginRight: SPACING.md,
    },
    avatar: {
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: COLORS.greenLight,
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarText: {
        fontSize: 16,
        fontWeight: '700',
        color: COLORS.green,
    },
    workerInfo: {
        flex: 1,
    },
    workerName: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 2,
    },
    workerSubtitle: {
        fontSize: 10,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 0.5,
    },
    statusBadge: {
        borderWidth: 1.5,
        borderRadius: BORDER_RADIUS.xl,
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
    },
    statusBadgeText: {
        fontSize: 9,
        fontWeight: '700',
        letterSpacing: 0.5,
    },

    // ─── WhatsApp Section ───────────────────────────────────────
    whatsappSection: {
        marginBottom: SPACING.md,
    },
    whatsappLabel: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.textLight,
        letterSpacing: 1,
        marginBottom: SPACING.xs,
    },
    phoneRow: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    whatsappIcon: {
        fontSize: 18,
        marginRight: SPACING.sm,
        color: COLORS.whatsapp,
    },
    phoneNumber: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '700',
        color: COLORS.text,
    },

    // ─── Action Buttons ─────────────────────────────────────────
    actionRow: {
        flexDirection: 'row',
        gap: SPACING.sm,
    },
    detailsBtn: {
        flex: 1,
        backgroundColor: COLORS.grayLight,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: 12,
        alignItems: 'center',
    },
    detailsBtnText: {
        fontSize: FONT_SIZES.sm,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
    messageBtn: {
        flex: 1.5,
        backgroundColor: COLORS.primary,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: 12,
        alignItems: 'center',
    },
    messageBtnText: {
        fontSize: FONT_SIZES.sm,
        fontWeight: '700',
        color: COLORS.white,
    },

    // ─── Onboard Card ───────────────────────────────────────────
    onboardCard: {
        marginHorizontal: SPACING.md,
        marginTop: SPACING.md,
        marginBottom: SPACING.xxl,
        borderRadius: BORDER_RADIUS.xl,
        borderWidth: 2,
        borderColor: COLORS.border,
        borderStyle: 'dashed',
        padding: SPACING.xl,
        alignItems: 'center',
        backgroundColor: COLORS.white,
    },
    onboardIcon: {
        fontSize: 32,
        marginBottom: SPACING.sm,
        color: COLORS.primary,
    },
    onboardTitle: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 4,
    },
    onboardDesc: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        textAlign: 'center',
    },

    // ─── Empty State ────────────────────────────────────────────
    emptyContainer: {
        padding: SPACING.xl,
        alignItems: 'center',
        marginTop: SPACING.xxl,
    },
    emptyIcon: {
        fontSize: 48,
        marginBottom: SPACING.md,
    },
    emptyText: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.textLight,
        fontWeight: '600',
        marginBottom: SPACING.xs,
    },
    emptySubtext: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
    },

    // ─── FAB ────────────────────────────────────────────────────
    fab: {
        position: 'absolute',
        bottom: 90,
        right: 24,
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: COLORS.primary,
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: COLORS.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.35,
        shadowRadius: 8,
        elevation: 8,
    },
    fabText: {
        fontSize: 28,
        color: COLORS.white,
        fontWeight: '300',
        marginTop: -2,
    },

    // ─── Modal ──────────────────────────────────────────────────
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        justifyContent: 'flex-end',
    },
    modalContainer: {
        backgroundColor: COLORS.white,
        borderTopLeftRadius: 24,
        borderTopRightRadius: 24,
        padding: SPACING.xl,
        paddingBottom: SPACING.xxl,
    },
    modalHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: SPACING.lg,
    },
    modalBrand: {
        fontSize: FONT_SIZES.xs,
        fontWeight: '700',
        color: COLORS.primary,
        letterSpacing: 1.5,
    },
    modalClose: {
        fontSize: 20,
        color: COLORS.textSecondary,
        padding: 4,
    },
    modalTitle: {
        fontSize: 24,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xl,
    },
    formLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.sm,
    },
    inputContainer: {
        backgroundColor: COLORS.grayLight,
        borderRadius: BORDER_RADIUS.md,
        paddingHorizontal: SPACING.md,
        marginBottom: SPACING.lg,
    },
    input: {
        paddingVertical: SPACING.md,
        fontSize: FONT_SIZES.md,
        color: COLORS.text,
    },
    saveButton: {
        backgroundColor: COLORS.primary,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: 16,
        alignItems: 'center',
        marginBottom: SPACING.sm,
    },
    saveButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.white,
    },
    cancelButton: {
        alignItems: 'center',
        paddingVertical: 16,
        backgroundColor: COLORS.grayLight,
        borderRadius: BORDER_RADIUS.xl,
        marginBottom: SPACING.sm,
    },
    cancelButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
    deleteButton: {
        alignItems: 'center',
        paddingVertical: 14,
        marginTop: SPACING.sm,
    },
    deleteButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.error,
    },
});
