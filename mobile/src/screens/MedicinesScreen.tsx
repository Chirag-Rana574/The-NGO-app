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
    ScrollView,
} from 'react-native';
import ApiService from '../services/api.service';
import PasskeyModal from '../components/PasskeyModal';
import SuccessToast from '../components/SuccessToast';
import { Medicine } from '../types';
import {
    COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET,
    SECTION_HEADER_STYLE, CARD_SHADOW, BORDER_RADIUS,
} from '../constants/theme';

type ModalMode = 'add' | 'edit' | 'stock' | null;

export default function MedicinesScreen() {
    const [medicines, setMedicines] = useState<Medicine[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [modalMode, setModalMode] = useState<ModalMode>(null);
    const [selectedMedicine, setSelectedMedicine] = useState<Medicine | null>(null);
    const [showPasskeyModal, setShowPasskeyModal] = useState(false);
    const [passkeyAction, setPasskeyAction] = useState<'edit' | 'delete' | null>(null);
    const [showSuccessToast, setShowSuccessToast] = useState(false);
    const [successMessage, setSuccessMessage] = useState('');
    const [searchQuery, setSearchQuery] = useState('');

    const [formData, setFormData] = useState({
        name: '',
        description: '',
        dosage_unit: '',
        initial_stock: '',
        min_stock_level: '',
    });

    const [stockData, setStockData] = useState({
        adjustment: '',
        notes: '',
    });

    const loadMedicines = useCallback(async () => {
        try {
            const data = await ApiService.getMedicines(true);
            setMedicines(data);
        } catch (error) {
            console.error('Failed to load medicines:', error);
            Alert.alert('Error', 'Failed to load medicines');
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        loadMedicines();
    }, [loadMedicines]);

    const onRefresh = () => {
        setRefreshing(true);
        loadMedicines();
    };

    const openAddModal = () => {
        setSelectedMedicine(null);
        setFormData({
            name: '',
            description: '',
            dosage_unit: '',
            initial_stock: '',
            min_stock_level: '10',
        });
        setModalMode('add');
    };

    const openEditStockModal = (medicine: Medicine) => {
        setSelectedMedicine(medicine);
        setStockData({ adjustment: '', notes: '' });
        setPasskeyAction('edit');
        setShowPasskeyModal(true);
    };

    const handlePasskeySuccess = () => {
        setShowPasskeyModal(false);
        if (passkeyAction === 'edit' && selectedMedicine) {
            setModalMode('stock');
        } else if (passkeyAction === 'delete' && selectedMedicine) {
            confirmDelete();
        }
        setPasskeyAction(null);
    };

    const handleAddMedicine = async () => {
        if (!formData.name.trim()) {
            Alert.alert('Validation Error', 'Please enter medicine name');
            return;
        }
        if (!formData.dosage_unit.trim()) {
            Alert.alert('Validation Error', 'Please enter dosage unit');
            return;
        }
        if (!formData.initial_stock || parseInt(formData.initial_stock) < 0) {
            Alert.alert('Validation Error', 'Please enter valid initial stock');
            return;
        }
        try {
            await ApiService.createMedicine({
                name: formData.name,
                description: formData.description || undefined,
                dosage_unit: formData.dosage_unit,
                initial_stock: parseInt(formData.initial_stock),
                min_stock_level: parseInt(formData.min_stock_level) || 10,
            });
            setSuccessMessage('Medicine added successfully');
            setShowSuccessToast(true);
            setModalMode(null);
            loadMedicines();
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to add medicine';
            Alert.alert('Error', errorMsg);
        }
    };

    const handleStockAdjustment = async () => {
        if (!selectedMedicine) return;
        if (!stockData.adjustment || parseInt(stockData.adjustment) === 0) {
            Alert.alert('Validation Error', 'Please enter stock adjustment amount');
            return;
        }
        try {
            await ApiService.adjustStock(selectedMedicine.id, {
                amount: parseInt(stockData.adjustment),
                notes: stockData.notes || 'Stock adjustment',
                created_by: 'Admin',
            });
            setSuccessMessage('Stock updated successfully');
            setShowSuccessToast(true);
            setModalMode(null);
            setSelectedMedicine(null);
            loadMedicines();
        } catch (error: any) {
            const errorMsg = error.response?.data?.detail || 'Failed to update stock';
            Alert.alert('Error', errorMsg);
        }
    };

    const handleDeleteRequest = (medicine: Medicine) => {
        setSelectedMedicine(medicine);
        setPasskeyAction('delete');
        setShowPasskeyModal(true);
    };

    const confirmDelete = () => {
        if (!selectedMedicine) return;
        Alert.alert(
            'Confirm Delete',
            `Are you sure you want to delete ${selectedMedicine.name}?`,
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                        try {
                            await ApiService.deleteMedicine(selectedMedicine.id);
                            setSuccessMessage('Medicine deleted successfully');
                            setShowSuccessToast(true);
                            setSelectedMedicine(null);
                            loadMedicines();
                        } catch (error: any) {
                            const errorMsg = error.response?.data?.detail || 'Failed to delete medicine';
                            Alert.alert('Error', errorMsg);
                        }
                    },
                },
            ]
        );
    };

    // ─── Derived data ─────────────────────────────────────────────
    const lowStockCount = medicines.filter(m => m.current_stock <= (m.min_stock_level ?? 10)).length;
    const totalSKUs = medicines.length;

    const filteredMedicines = medicines.filter(m =>
        m.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    // ─── Card Renderer ────────────────────────────────────────────
    const renderMedicineItem = ({ item }: { item: Medicine }) => {
        const isLowStock = item.current_stock <= (item.min_stock_level ?? 10);

        return (
            <View style={[
                styles.medicineCard,
                isLowStock ? styles.medicineCardLow : styles.medicineCardStable,
            ]}>
                {/* Status badge */}
                <View style={styles.cardHeaderRow}>
                    <View style={[
                        styles.stockStatusBadge,
                        { backgroundColor: isLowStock ? '#FEE2E2' : '#ECFDF5' },
                    ]}>
                        <Text style={[
                            styles.stockStatusText,
                            { color: isLowStock ? COLORS.error : COLORS.green },
                        ]}>
                            {isLowStock ? '⚠ LOW STOCK' : '✓ STABLE'}
                        </Text>
                    </View>
                </View>

                {/* Name + Stock count */}
                <View style={styles.medicineRow}>
                    <View style={styles.medicineInfo}>
                        <Text style={styles.medicineName}>{item.name}</Text>
                        {item.description ? (
                            <Text style={styles.medicineDesc}>{item.description}</Text>
                        ) : null}
                    </View>
                    <View style={styles.stockCountContainer}>
                        <Text style={[
                            styles.stockCountBig,
                            { color: isLowStock ? COLORS.error : COLORS.text },
                        ]}>
                            {item.current_stock.toString().padStart(2, '0')}
                        </Text>
                        <Text style={styles.stockCountUnit}>
                            {item.dosage_unit?.toUpperCase() || 'UNITS'} LEFT
                        </Text>
                    </View>
                </View>

                {/* Action buttons */}
                <View style={styles.actionButtons}>
                    <TouchableOpacity
                        style={styles.actionBtn}
                        onPress={() => {
                            setSelectedMedicine(item);
                            setFormData({
                                name: item.name,
                                description: item.description || '',
                                dosage_unit: item.dosage_unit,
                                initial_stock: item.current_stock.toString(),
                                min_stock_level: (item.min_stock_level ?? 10).toString(),
                            });
                            setModalMode('edit');
                        }}
                    >
                        <Text style={styles.actionBtnIcon}>✏️</Text>
                        <Text style={styles.actionBtnText}>EDIT</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.actionBtn, styles.actionBtnPrimary]}
                        onPress={() => openEditStockModal(item)}
                    >
                        <Text style={styles.actionBtnIconWhite}>➕</Text>
                        <Text style={styles.actionBtnTextWhite}>STOCK +/-</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.actionBtn}
                        onPress={() => handleDeleteRequest(item)}
                    >
                        <Text style={styles.actionBtnIcon}>🗑</Text>
                        <Text style={styles.actionBtnText}>DELETE</Text>
                    </TouchableOpacity>
                </View>
            </View>
        );
    };

    // ─── Header ───────────────────────────────────────────────────
    const ListHeader = () => (
        <View style={styles.headerSection}>
            <Text style={styles.heroTitle}>Pharmacy Inventory</Text>
            <Text style={styles.heroSubtitle}>
                Monitor and manage essential medical supplies. Real-time stock alerts for field coordinators.
            </Text>

            {/* Summary chips */}
            <View style={styles.chipRow}>
                <View style={styles.chipCard}>
                    <Text style={styles.chipLabel}>TOTAL SKUS</Text>
                    <Text style={styles.chipValue}>{totalSKUs}</Text>
                </View>
                <View style={[styles.chipCard, styles.chipCardAlert]}>
                    <Text style={[styles.chipLabel, { color: COLORS.error }]}>LOW STOCK</Text>
                    <Text style={[styles.chipValue, { color: COLORS.error }]}>
                        {lowStockCount.toString().padStart(2, '0')}
                    </Text>
                </View>
            </View>

            {/* Search */}
            <View style={styles.searchBar}>
                <Text style={styles.searchIcon}>🔍</Text>
                <TextInput
                    style={styles.searchInput}
                    placeholder="Search medicines by name or salt..."
                    placeholderTextColor={COLORS.textHint}
                    value={searchQuery}
                    onChangeText={setSearchQuery}
                />
            </View>

            {/* Filters button */}
            <TouchableOpacity style={styles.filtersBtn}>
                <Text style={styles.filtersBtnIcon}>☰</Text>
                <Text style={styles.filtersBtnText}>Filters</Text>
            </TouchableOpacity>
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

            <PasskeyModal
                visible={showPasskeyModal}
                onClose={() => {
                    setShowPasskeyModal(false);
                    setPasskeyAction(null);
                    setSelectedMedicine(null);
                }}
                onSuccess={handlePasskeySuccess}
                onVerify={(pin) => ApiService.verifyPasskey(pin)}
                title={passkeyAction === 'edit' ? 'Edit Stock' : 'Delete Medicine'}
            />

            <FlatList
                data={filteredMedicines}
                renderItem={renderMedicineItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                ListHeaderComponent={<ListHeader />}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>💊</Text>
                        <Text style={styles.emptyText}>No medicines yet</Text>
                        <Text style={styles.emptySubtext}>Tap + to add one</Text>
                    </View>
                }
                showsVerticalScrollIndicator={false}
            />

            {/* FAB */}
            <TouchableOpacity style={styles.fab} onPress={openAddModal} activeOpacity={0.85}>
                <Text style={styles.fabText}>+</Text>
            </TouchableOpacity>

            {/* Add Medicine Modal */}
            <Modal
                visible={modalMode === 'add' || modalMode === 'edit'}
                transparent
                animationType="slide"
                onRequestClose={() => setModalMode(null)}
            >
                <View style={styles.modalOverlay}>
                    <ScrollView contentContainerStyle={styles.modalScrollContent}>
                        <View style={styles.modalContainer}>
                            <View style={styles.modalHeader}>
                                <Text style={styles.modalBrand}>CLINICAL CURATOR</Text>
                                <TouchableOpacity onPress={() => setModalMode(null)}>
                                    <Text style={styles.modalClose}>✕</Text>
                                </TouchableOpacity>
                            </View>

                            <Text style={styles.modalTitle}>
                                {modalMode === 'edit' ? 'Edit Medicine' : 'Add Medicine'}
                            </Text>

                            <Text style={styles.formLabel}>MEDICINE NAME *</Text>
                            <View style={styles.inputContainer}>
                                <TextInput
                                    style={styles.input}
                                    value={formData.name}
                                    onChangeText={(text) => setFormData({ ...formData, name: text })}
                                    placeholder="e.g., Amoxicillin 500mg"
                                    placeholderTextColor={COLORS.textHint}
                                />
                            </View>

                            <Text style={styles.formLabel}>DESCRIPTION</Text>
                            <View style={styles.inputContainer}>
                                <TextInput
                                    style={styles.input}
                                    value={formData.description}
                                    onChangeText={(text) => setFormData({ ...formData, description: text })}
                                    placeholder="Optional description"
                                    placeholderTextColor={COLORS.textHint}
                                />
                            </View>

                            <Text style={styles.formLabel}>DOSAGE UNIT *</Text>
                            <View style={styles.inputContainer}>
                                <TextInput
                                    style={styles.input}
                                    value={formData.dosage_unit}
                                    onChangeText={(text) => setFormData({ ...formData, dosage_unit: text })}
                                    placeholder="e.g., mg, ml, tablets"
                                    placeholderTextColor={COLORS.textHint}
                                />
                            </View>

                            <View style={styles.halfRow}>
                                <View style={{ flex: 1 }}>
                                    <Text style={styles.formLabel}>INITIAL STOCK *</Text>
                                    <View style={styles.inputContainer}>
                                        <TextInput
                                            style={styles.input}
                                            value={formData.initial_stock}
                                            onChangeText={(text) => setFormData({ ...formData, initial_stock: text })}
                                            placeholder="0"
                                            placeholderTextColor={COLORS.textHint}
                                            keyboardType="numeric"
                                        />
                                    </View>
                                </View>
                                <View style={{ width: SPACING.md }} />
                                <View style={{ flex: 1 }}>
                                    <Text style={styles.formLabel}>MIN LEVEL</Text>
                                    <View style={styles.inputContainer}>
                                        <TextInput
                                            style={styles.input}
                                            value={formData.min_stock_level}
                                            onChangeText={(text) => setFormData({ ...formData, min_stock_level: text })}
                                            placeholder="10"
                                            placeholderTextColor={COLORS.textHint}
                                            keyboardType="numeric"
                                        />
                                    </View>
                                </View>
                            </View>

                            <TouchableOpacity style={styles.saveButton} onPress={handleAddMedicine}>
                                <Text style={styles.saveButtonText}>
                                    {modalMode === 'edit' ? '💾  Save Changes' : '➕  Add Medicine'}
                                </Text>
                            </TouchableOpacity>

                            <TouchableOpacity style={styles.cancelButton} onPress={() => setModalMode(null)}>
                                <Text style={styles.cancelButtonText}>Cancel</Text>
                            </TouchableOpacity>
                        </View>
                    </ScrollView>
                </View>
            </Modal>

            {/* Stock Adjustment Modal */}
            <Modal
                visible={modalMode === 'stock'}
                transparent
                animationType="slide"
                onRequestClose={() => setModalMode(null)}
            >
                <View style={styles.modalOverlay}>
                    <View style={styles.modalContainerCenter}>
                        <View style={styles.modalHeader}>
                            <Text style={styles.modalBrand}>STOCK ADJUSTMENT</Text>
                            <TouchableOpacity onPress={() => setModalMode(null)}>
                                <Text style={styles.modalClose}>✕</Text>
                            </TouchableOpacity>
                        </View>

                        <Text style={styles.modalTitle}>{selectedMedicine?.name}</Text>
                        <Text style={styles.currentStockLabel}>
                            Current: {selectedMedicine?.current_stock} {selectedMedicine?.dosage_unit}
                        </Text>

                        <Text style={styles.formLabel}>ADJUSTMENT AMOUNT</Text>
                        <Text style={styles.helpText}>
                            Use positive numbers to add stock, negative to remove
                        </Text>
                        <View style={styles.inputContainer}>
                            <TextInput
                                style={styles.input}
                                value={stockData.adjustment}
                                onChangeText={(text) => setStockData({ ...stockData, adjustment: text })}
                                placeholder="e.g., +50 or -20"
                                placeholderTextColor={COLORS.textHint}
                                keyboardType="numeric"
                            />
                        </View>

                        <Text style={styles.formLabel}>NOTES</Text>
                        <View style={styles.inputContainer}>
                            <TextInput
                                style={styles.input}
                                value={stockData.notes}
                                onChangeText={(text) => setStockData({ ...stockData, notes: text })}
                                placeholder="Reason for adjustment"
                                placeholderTextColor={COLORS.textHint}
                            />
                        </View>

                        <TouchableOpacity style={styles.saveButton} onPress={handleStockAdjustment}>
                            <Text style={styles.saveButtonText}>💾  Update Stock</Text>
                        </TouchableOpacity>

                        <TouchableOpacity style={styles.cancelButton} onPress={() => setModalMode(null)}>
                            <Text style={styles.cancelButtonText}>Cancel</Text>
                        </TouchableOpacity>
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
    heroTitle: {
        fontSize: 30,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: SPACING.xs,
    },
    heroSubtitle: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
        marginBottom: SPACING.lg,
    },
    chipRow: {
        flexDirection: 'row',
        gap: SPACING.sm,
        marginBottom: SPACING.lg,
    },
    chipCard: {
        backgroundColor: COLORS.grayLight,
        borderRadius: BORDER_RADIUS.md,
        paddingVertical: SPACING.sm,
        paddingHorizontal: SPACING.lg,
    },
    chipCardAlert: {
        backgroundColor: '#FEE2E2',
    },
    chipLabel: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: 2,
    },
    chipValue: {
        fontSize: FONT_SIZES.xl,
        fontWeight: '800',
        color: COLORS.text,
    },
    searchBar: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.sm,
        marginBottom: SPACING.sm,
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
    filtersBtn: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        paddingVertical: SPACING.sm,
        marginBottom: SPACING.md,
        ...CARD_SHADOW,
    },
    filtersBtnIcon: {
        fontSize: 14,
        marginRight: SPACING.sm,
        color: COLORS.textSecondary,
    },
    filtersBtnText: {
        fontSize: FONT_SIZES.sm,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },

    // ─── Medicine Card ──────────────────────────────────────────
    medicineCard: {
        backgroundColor: COLORS.white,
        borderRadius: BORDER_RADIUS.xl,
        padding: SPACING.lg,
        marginHorizontal: SPACING.md,
        marginBottom: SPACING.md,
        borderLeftWidth: 4,
        ...CARD_SHADOW,
    },
    medicineCardStable: {
        borderLeftColor: COLORS.green,
    },
    medicineCardLow: {
        borderLeftColor: COLORS.error,
    },
    cardHeaderRow: {
        marginBottom: SPACING.sm,
    },
    stockStatusBadge: {
        alignSelf: 'flex-start',
        paddingHorizontal: SPACING.sm,
        paddingVertical: 3,
        borderRadius: 6,
    },
    stockStatusText: {
        fontSize: 10,
        fontWeight: '700',
        letterSpacing: 0.5,
    },
    medicineRow: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginBottom: SPACING.md,
    },
    medicineInfo: {
        flex: 1,
        marginRight: SPACING.md,
    },
    medicineName: {
        fontSize: FONT_SIZES.xl,
        fontWeight: '800',
        color: COLORS.text,
        marginBottom: 4,
    },
    medicineDesc: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        lineHeight: 20,
    },
    stockCountContainer: {
        alignItems: 'flex-end',
    },
    stockCountBig: {
        fontSize: 40,
        fontWeight: '800',
        lineHeight: 44,
    },
    stockCountUnit: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.textLight,
        letterSpacing: 0.5,
        marginTop: 2,
    },

    // ─── Action Buttons ─────────────────────────────────────────
    actionButtons: {
        flexDirection: 'row',
        gap: SPACING.sm,
    },
    actionBtn: {
        flex: 1,
        flexDirection: 'column',
        alignItems: 'center',
        paddingVertical: SPACING.sm,
        borderRadius: BORDER_RADIUS.md,
        backgroundColor: COLORS.grayLight,
    },
    actionBtnPrimary: {
        backgroundColor: COLORS.primary,
    },
    actionBtnIcon: {
        fontSize: 16,
        marginBottom: 2,
    },
    actionBtnIconWhite: {
        fontSize: 16,
        marginBottom: 2,
    },
    actionBtnText: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 0.5,
    },
    actionBtnTextWhite: {
        fontSize: 9,
        fontWeight: '700',
        color: COLORS.white,
        letterSpacing: 0.5,
    },

    // ─── Empty ──────────────────────────────────────────────────
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
    modalScrollContent: {
        flexGrow: 1,
        justifyContent: 'flex-end',
    },
    modalContainer: {
        backgroundColor: COLORS.white,
        borderTopLeftRadius: 24,
        borderTopRightRadius: 24,
        padding: SPACING.xl,
        paddingBottom: SPACING.xxl,
    },
    modalContainerCenter: {
        backgroundColor: COLORS.white,
        borderTopLeftRadius: 24,
        borderTopRightRadius: 24,
        padding: SPACING.xl,
        paddingBottom: SPACING.xxl,
        marginTop: 'auto',
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
        marginBottom: SPACING.sm,
    },
    currentStockLabel: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textSecondary,
        marginBottom: SPACING.xl,
    },
    formLabel: {
        fontSize: FONT_SIZES.xxs,
        fontWeight: '700',
        color: COLORS.textSecondary,
        letterSpacing: 1,
        marginBottom: SPACING.sm,
    },
    helpText: {
        fontSize: FONT_SIZES.xs,
        color: COLORS.textLight,
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
    halfRow: {
        flexDirection: 'row',
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
    },
    cancelButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
});
