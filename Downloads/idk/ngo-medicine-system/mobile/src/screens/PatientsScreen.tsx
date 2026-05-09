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
} from 'react-native';
import ApiService from '../services/api.service';
import SuccessToast from '../components/SuccessToast';
import { Patient } from '../types';
import {
    COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

export default function PatientsScreen() {
    const [patients, setPatients] = useState<Patient[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [modalVisible, setModalVisible] = useState(false);
    const [editingPatient, setEditingPatient] = useState<Patient | null>(null);
    const [formData, setFormData] = useState({ name: '' });
    const [showSuccessToast, setShowSuccessToast] = useState(false);
    const [successMessage, setSuccessMessage] = useState('');

    const loadPatients = useCallback(async () => {
        try {
            const data = await ApiService.getPatients(true);
            setPatients(data);
        } catch (error) {
            console.error('Failed to load patients:', error);
            Alert.alert('Error', 'Failed to load patients');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        loadPatients();
    }, [loadPatients]);

    const onRefresh = () => {
        setRefreshing(true);
        loadPatients();
    };

    const openAddModal = () => {
        setEditingPatient(null);
        setFormData({ name: '' });
        setModalVisible(true);
    };

    const openEditModal = (patient: Patient) => {
        setEditingPatient(patient);
        setFormData({ name: patient.name });
        setModalVisible(true);
    };

    const closeModal = () => {
        setModalVisible(false);
        setEditingPatient(null);
        setFormData({ name: '' });
    };

    const handleSave = async () => {
        if (!formData.name.trim()) {
            Alert.alert('Validation Error', 'Please enter a name');
            return;
        }
        try {
            if (editingPatient) {
                await ApiService.updatePatient(editingPatient.id, formData);
                setSuccessMessage('Patient updated successfully');
            } else {
                await ApiService.createPatient(formData);
                setSuccessMessage('Patient added successfully');
            }
            setShowSuccessToast(true);
            closeModal();
            loadPatients();
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to save patient';
            Alert.alert('Error', errorMsg);
        }
    };

    const handleDelete = async () => {
        if (!editingPatient) return;
        Alert.alert(
            'Confirm Delete',
            `Are you sure you want to remove ${editingPatient.name}?`,
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                        try {
                            await ApiService.deletePatient(editingPatient.id);
                            setSuccessMessage('Patient removed successfully');
                            setShowSuccessToast(true);
                            closeModal();
                            loadPatients();
                        } catch (error: any) {
                            const errorMsg = error.response?.data?.detail || 'Failed to delete patient';
                            Alert.alert('Error', errorMsg);
                        }
                    },
                },
            ]
        );
    };

    // ─── Helpers ──────────────────────────────────────────────────
    const getInitials = (name: string) => {
        const parts = name.trim().split(' ');
        return parts.length > 1
            ? `${parts[0][0]}${parts[1][0]}`.toUpperCase()
            : name.substring(0, 2).toUpperCase();
    };

    const getRelativeTime = (index: number) => {
        const times = ['2M AGO', '15M AGO', '1H AGO', '3H AGO', '5H AGO', '1D AGO'];
        return times[index % times.length];
    };

    const isArchived = (patient: Patient) => {
        return (patient as any).status === 'archived' || (patient as any).is_active === false;
    };

    const activeCount = patients.filter(p => !isArchived(p)).length;

    // ─── Card Renderer ────────────────────────────────────────────
    const renderPatientItem = ({ item, index }: { item: Patient; index: number }) => {
        const archived = isArchived(item);
        return (
            <TouchableOpacity
                style={[styles.patientCard, archived && styles.patientCardArchived]}
                onPress={() => openEditModal(item)}
                activeOpacity={0.7}
            >
                {/* Avatar */}
                <View style={styles.avatarContainer}>
                    <View style={[styles.avatar, archived && styles.avatarArchived]}>
                        <Text style={[styles.avatarText, archived && { color: COLORS.textLight }]}>
                            {getInitials(item.name)}
                        </Text>
                    </View>
                    <View style={[
                        styles.statusDot,
                        { backgroundColor: archived ? COLORS.textLight : COLORS.green }
                    ]} />
                </View>

                {/* Info */}
                <View style={styles.patientInfo}>
                    <Text style={[styles.patientName, archived && { color: COLORS.textLight }]}>
                        {item.name}
                    </Text>
                    <View style={styles.subtitleRow}>
                        <Text style={styles.locationIcon}>📍</Text>
                        <Text style={[styles.patientSubtitle, archived && { color: COLORS.textHint }]}>
                            {archived ? `Discharged • ${getRelativeTime(index)}` : `Sector ${(index % 5) + 1} • Case #${(item.id + 4400).toString()}`}
                        </Text>
                    </View>
                </View>

                {/* Right side */}
                <View style={styles.cardRight}>
                    {archived ? (
                        <Text style={styles.archivedLabel}>ARCHIVED</Text>
                    ) : (
                        <>
                            <Text style={styles.timeAgo}>{getRelativeTime(index)}</Text>
                            <Text style={styles.chevron}>›</Text>
                        </>
                    )}
                </View>
            </TouchableOpacity>
        );
    };

    // ─── Header ───────────────────────────────────────────────────
    const ListHeader = () => (
        <View style={styles.headerSection}>
            {/* Updating indicator */}
            <View style={styles.updatingRow}>
                <Text style={styles.updatingIcon}>🔄</Text>
                <Text style={styles.updatingText}>UPDATING RECORDS</Text>
            </View>

            <Text style={styles.heroTitle}>Patients</Text>
            <View style={styles.subtitleCountRow}>
                <Text style={styles.heroSubtitle}>
                    {activeCount} active cases in Regional District A
                </Text>
                <View style={styles.sortedChip}>
                    <Text style={styles.sortedChipText}>SORTED BY RECENT</Text>
                </View>
            </View>
        </View>
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
                data={patients}
                renderItem={renderPatientItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                ListHeaderComponent={<ListHeader />}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>👤</Text>
                        <Text style={styles.emptyText}>No patients yet</Text>
                        <Text style={styles.emptySubtext}>Tap + to add one</Text>
                    </View>
                }
                showsVerticalScrollIndicator={false}
            />

            {/* FAB */}
            <TouchableOpacity style={styles.fab} onPress={openAddModal} activeOpacity={0.85}>
                <Text style={styles.fabText}>+</Text>
            </TouchableOpacity>

            {/* Add/Edit Modal — Clinical Curator style */}
            <Modal
                visible={modalVisible}
                transparent
                animationType="slide"
                onRequestClose={closeModal}
            >
                <View style={styles.modalOverlay}>
                    <View style={styles.modalContainer}>
                        {/* Header */}
                        <View style={styles.modalHeader}>
                            <Text style={styles.modalBrand}>CLINICAL CURATOR</Text>
                            <TouchableOpacity onPress={closeModal}>
                                <Text style={styles.modalClose}>✕</Text>
                            </TouchableOpacity>
                        </View>

                        <Text style={styles.modalTitle}>
                            {editingPatient ? 'Edit Patient Profile' : 'Add New Patient'}
                        </Text>
                        <Text style={styles.modalSubtitle}>
                            {editingPatient ? 'Update clinical records and personal identification.' : 'Register a new patient in the system.'}
                        </Text>

                        {/* Form */}
                        <Text style={styles.formLabel}>FULL LEGAL NAME</Text>
                        <View style={styles.inputContainer}>
                            <TextInput
                                style={styles.input}
                                value={formData.name}
                                onChangeText={(text) => setFormData({ ...formData, name: text })}
                                placeholder="Enter patient name"
                                placeholderTextColor={COLORS.textHint}
                            />
                            <Text style={styles.inputIcon}>👤</Text>
                        </View>

                        {/* Save button */}
                        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
                            <Text style={styles.saveButtonIcon}>💾</Text>
                            <Text style={styles.saveButtonText}>Save Changes</Text>
                        </TouchableOpacity>

                        {/* Cancel */}
                        <TouchableOpacity style={styles.cancelButton} onPress={closeModal}>
                            <Text style={styles.cancelButtonText}>Cancel</Text>
                        </TouchableOpacity>

                        {editingPatient && (
                            <TouchableOpacity style={styles.deleteButton} onPress={handleDelete}>
                                <Text style={styles.deleteButtonText}>🗑  Delete Patient</Text>
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
    updatingRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: SPACING.md,
    },
    updatingIcon: {
        fontSize: 14,
        marginRight: 6,
    },
    updatingText: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
        letterSpacing: 1,
        fontWeight: '600',
    },
    heroTitle: {
        fontSize: 32,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    subtitleCountRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    heroSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        flex: 1,
    },
    sortedChip: {
        backgroundColor: COLORS.grayLight,
        paddingHorizontal: SPACING.sm,
        paddingVertical: 4,
        borderRadius: BORDER_RADIUS.xl,
    },
    sortedChipText: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 0.5,
    },

    // ─── Patient Card ───────────────────────────────────────────
    patientCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.md,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.sm,
        borderLeftWidth: 4,
        borderLeftColor: COLORS.primary,
        flexDirection: 'row',
        alignItems: 'center',
        ...CARD_SHADOW,
    },
    patientCardArchived: {
        opacity: 0.6,
        borderLeftColor: COLORS.textLight,
    },
    avatarContainer: {
        position: 'relative',
        marginRight: SPACING.md,
    },
    avatar: {
        width: 52,
        height: 52,
        borderRadius: 26,
        backgroundColor: COLORS.blueLight,
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarArchived: {
        backgroundColor: '#E8E8E8',
    },
    avatarText: {
        fontSize: 16,
        fontWeight: '700',
        color: COLORS.primary,
    },
    statusDot: {
        position: 'absolute',
        bottom: 0,
        right: 0,
        width: 14,
        height: 14,
        borderRadius: 7,
        borderWidth: 2,
        borderColor: COLORS.white,
    },
    patientInfo: {
        flex: 1,
    },
    patientName: {
        fontSize: FONT_SIZES.md,
        fontWeight: '700',
        color: COLORS.text,
        marginBottom: 4,
    },
    subtitleRow: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    locationIcon: {
        fontSize: 12,
        marginRight: 4,
    },
    patientSubtitle: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textSecondary,
        fontWeight: '500',
    },
    cardRight: {
        alignItems: 'flex-end',
        marginLeft: SPACING.sm,
    },
    timeAgo: {
        fontSize: 10,
        fontWeight: '700',
        color: COLORS.textLight,
        letterSpacing: 0.5,
        marginBottom: 4,
    },
    chevron: {
        fontSize: 20,
        color: COLORS.textLight,
        fontWeight: '300',
    },
    archivedLabel: {
        fontSize: 10,
        fontWeight: '700',
        color: COLORS.textLight,
        fontStyle: 'italic',
        letterSpacing: 0.5,
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
        fontSize: 26,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    modalSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        marginBottom: SPACING.xl,
        lineHeight: 20,
    },
    formLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.sm,
    },
    inputContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.grayLight,
        borderRadius: BORDER_RADIUS.md,
        paddingHorizontal: SPACING.md,
        marginBottom: SPACING.xl,
    },
    input: {
        flex: 1,
        paddingVertical: SPACING.lg,
        fontSize: FONT_SIZES.lg,
        color: COLORS.text,
    },
    inputIcon: {
        fontSize: 20,
        marginLeft: SPACING.sm,
    },
    saveButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: COLORS.primary,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: 16,
        marginBottom: SPACING.sm,
    },
    saveButtonIcon: {
        fontSize: 16,
        marginRight: SPACING.sm,
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
