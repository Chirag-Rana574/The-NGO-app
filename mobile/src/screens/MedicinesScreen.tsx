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
import { COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET } from '../constants/theme';

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

    // Form data
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        dosage_unit: '',
        initial_stock: '',
        min_stock_level: '',
    });

    // Stock adjustment data
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

    const renderMedicineItem = ({ item }: { item: Medicine }) => {
        const isLowStock = item.current_stock <= (item.min_stock_level ?? 10);

        return (
            <View style={styles.medicineCard}>
                <View style={styles.medicineHeader}>
                    <Text style={styles.medicineName}>{item.name}</Text>
                    {isLowStock && (
                        <View style={styles.lowStockBadge}>
                            <Text style={styles.lowStockText}>Low Stock</Text>
                        </View>
                    )}
                </View>

                {item.description && (
                    <Text style={styles.description}>{item.description}</Text>
                )}

                <View style={styles.stockInfo}>
                    <Text style={styles.stockLabel}>Current Stock:</Text>
                    <Text style={[styles.stockValue, isLowStock && styles.stockValueLow]}>
                        {item.current_stock} {item.dosage_unit}
                    </Text>
                </View>

                <View style={styles.stockInfo}>
                    <Text style={styles.stockLabel}>Min Stock Level:</Text>
                    <Text style={styles.stockValue}>
                        {item.min_stock_level ?? 10} {item.dosage_unit}
                    </Text>
                </View>

                <View style={styles.actionButtons}>
                    <TouchableOpacity
                        style={[styles.actionButton, styles.editButton]}
                        onPress={() => openEditStockModal(item)}
                    >
                        <Text style={styles.actionButtonText}>Edit Stock</Text>
                    </TouchableOpacity>

                    <TouchableOpacity
                        style={[styles.actionButton, styles.deleteButton]}
                        onPress={() => handleDeleteRequest(item)}
                    >
                        <Text style={styles.actionButtonText}>Delete</Text>
                    </TouchableOpacity>
                </View>
            </View>
        );
    };

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
                data={medicines}
                renderItem={renderMedicineItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>💊</Text>
                        <Text style={styles.emptyText}>No medicines yet</Text>
                        <Text style={styles.emptySubtext}>Tap "+ Add" to create one</Text>
                    </View>
                }
            />

            <TouchableOpacity style={styles.fab} onPress={openAddModal}>
                <Text style={styles.fabText}>+ Add</Text>
            </TouchableOpacity>

            {/* Add Medicine Modal */}
            <Modal
                visible={modalMode === 'add'}
                transparent
                animationType="slide"
                onRequestClose={() => setModalMode(null)}
            >
                <View style={styles.modalOverlay}>
                    <ScrollView contentContainerStyle={styles.modalScrollContent}>
                        <View style={styles.modalContainer}>
                            <Text style={styles.modalTitle}>Add Medicine</Text>

                            <View style={styles.formSection}>
                                <Text style={styles.label}>Medicine Name *</Text>
                                <TextInput
                                    style={styles.input}
                                    value={formData.name}
                                    onChangeText={(text) => setFormData({ ...formData, name: text })}
                                    placeholder="e.g., Aspirin"
                                    placeholderTextColor={COLORS.textLight}
                                />
                            </View>

                            <View style={styles.formSection}>
                                <Text style={styles.label}>Description</Text>
                                <TextInput
                                    style={styles.input}
                                    value={formData.description}
                                    onChangeText={(text) => setFormData({ ...formData, description: text })}
                                    placeholder="Optional description"
                                    placeholderTextColor={COLORS.textLight}
                                />
                            </View>

                            <View style={styles.formSection}>
                                <Text style={styles.label}>Dosage Unit *</Text>
                                <TextInput
                                    style={styles.input}
                                    value={formData.dosage_unit}
                                    onChangeText={(text) => setFormData({ ...formData, dosage_unit: text })}
                                    placeholder="e.g., mg, ml, tablets"
                                    placeholderTextColor={COLORS.textLight}
                                />
                            </View>

                            <View style={styles.formSection}>
                                <Text style={styles.label}>Initial Stock *</Text>
                                <TextInput
                                    style={styles.input}
                                    value={formData.initial_stock}
                                    onChangeText={(text) => setFormData({ ...formData, initial_stock: text })}
                                    placeholder="0"
                                    placeholderTextColor={COLORS.textLight}
                                    keyboardType="numeric"
                                />
                            </View>

                            <View style={styles.formSection}>
                                <Text style={styles.label}>Minimum Stock Level</Text>
                                <TextInput
                                    style={styles.input}
                                    value={formData.min_stock_level}
                                    onChangeText={(text) => setFormData({ ...formData, min_stock_level: text })}
                                    placeholder="10"
                                    placeholderTextColor={COLORS.textLight}
                                    keyboardType="numeric"
                                />
                            </View>

                            <View style={styles.modalButtons}>
                                <TouchableOpacity
                                    style={[styles.button, styles.cancelButton]}
                                    onPress={() => setModalMode(null)}
                                >
                                    <Text style={styles.cancelButtonText}>Cancel</Text>
                                </TouchableOpacity>

                                <TouchableOpacity
                                    style={[styles.button, styles.saveButton]}
                                    onPress={handleAddMedicine}
                                >
                                    <Text style={styles.saveButtonText}>Add</Text>
                                </TouchableOpacity>
                            </View>
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
                    <View style={styles.modalContainer}>
                        <Text style={styles.modalTitle}>Adjust Stock</Text>
                        <Text style={styles.modalSubtitle}>{selectedMedicine?.name}</Text>
                        <Text style={styles.currentStock}>
                            Current: {selectedMedicine?.current_stock} {selectedMedicine?.dosage_unit}
                        </Text>

                        <View style={styles.formSection}>
                            <Text style={styles.label}>Adjustment Amount</Text>
                            <Text style={styles.helpText}>
                                Use positive numbers to add stock, negative to remove
                            </Text>
                            <TextInput
                                style={styles.input}
                                value={stockData.adjustment}
                                onChangeText={(text) => setStockData({ ...stockData, adjustment: text })}
                                placeholder="e.g., +50 or -20"
                                placeholderTextColor={COLORS.textLight}
                                keyboardType="numeric"
                            />
                        </View>

                        <View style={styles.formSection}>
                            <Text style={styles.label}>Notes</Text>
                            <TextInput
                                style={styles.input}
                                value={stockData.notes}
                                onChangeText={(text) => setStockData({ ...stockData, notes: text })}
                                placeholder="Reason for adjustment"
                                placeholderTextColor={COLORS.textLight}
                            />
                        </View>

                        <View style={styles.modalButtons}>
                            <TouchableOpacity
                                style={[styles.button, styles.cancelButton]}
                                onPress={() => setModalMode(null)}
                            >
                                <Text style={styles.cancelButtonText}>Cancel</Text>
                            </TouchableOpacity>

                            <TouchableOpacity
                                style={[styles.button, styles.saveButton]}
                                onPress={handleStockAdjustment}
                            >
                                <Text style={styles.saveButtonText}>Save</Text>
                            </TouchableOpacity>
                        </View>
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
        padding: SPACING.md,
    },
    medicineCard: {
        backgroundColor: COLORS.white,
        borderRadius: 16,
        padding: SPACING.xl,
        marginBottom: SPACING.md,
        borderLeftWidth: 6,
        borderLeftColor: COLORS.green,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
    },
    medicineHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: SPACING.sm,
    },
    medicineName: {
        fontSize: FONT_SIZES.xl,
        fontWeight: 'bold',
        color: COLORS.text,
        flex: 1,
    },
    lowStockBadge: {
        backgroundColor: COLORS.error,
        paddingHorizontal: SPACING.md,
        paddingVertical: SPACING.xs,
        borderRadius: 12,
    },
    lowStockText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.sm,
        fontWeight: 'bold',
    },
    description: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
        marginBottom: SPACING.md,
    },
    stockInfo: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: SPACING.lg,
    },
    stockLabel: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.textLight,
        marginRight: SPACING.sm,
    },
    stockValue: {
        fontSize: FONT_SIZES.xl,
        fontWeight: 'bold',
        color: COLORS.success,
    },
    stockValueLow: {
        color: COLORS.error,
    },
    actionButtons: {
        flexDirection: 'row',
        gap: SPACING.md,
    },
    actionButton: {
        flex: 1,
        borderRadius: 12,
        padding: SPACING.lg,
        alignItems: 'center',
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
    },
    editButton: {
        backgroundColor: COLORS.primary,
    },
    deleteButton: {
        backgroundColor: COLORS.error,
    },
    actionButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: 'bold',
        color: COLORS.white,
    },
    emptyContainer: {
        padding: SPACING.xl,
        alignItems: 'center',
        marginTop: SPACING.xxl,
    },
    emptyIcon: {
        fontSize: 64,
        marginBottom: SPACING.lg,
    },
    emptyText: {
        fontSize: FONT_SIZES.xl,
        color: COLORS.textLight,
        fontWeight: '600',
        marginBottom: SPACING.sm,
    },
    emptySubtext: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
    },
    fab: {
        position: 'absolute',
        right: SPACING.lg,
        bottom: SPACING.lg,
        backgroundColor: COLORS.green,
        borderRadius: 28,
        paddingHorizontal: SPACING.xl,
        paddingVertical: SPACING.lg,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 8,
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
    },
    fabText: {
        color: COLORS.white,
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
    },
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    modalScrollContent: {
        flexGrow: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: SPACING.lg,
    },
    modalContainer: {
        backgroundColor: COLORS.white,
        borderRadius: 24,
        padding: SPACING.xl,
        width: '90%',
        maxWidth: 500,
    },
    modalTitle: {
        fontSize: FONT_SIZES.xxl,
        fontWeight: 'bold',
        color: COLORS.text,
        marginBottom: SPACING.sm,
        textAlign: 'center',
    },
    modalSubtitle: {
        fontSize: FONT_SIZES.lg,
        color: COLORS.textLight,
        textAlign: 'center',
        marginBottom: SPACING.xs,
    },
    currentStock: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
        textAlign: 'center',
        marginBottom: SPACING.xl,
    },
    formSection: {
        marginBottom: SPACING.lg,
    },
    label: {
        fontSize: FONT_SIZES.lg,
        fontWeight: '600',
        color: COLORS.text,
        marginBottom: SPACING.sm,
    },
    helpText: {
        fontSize: FONT_SIZES.sm,
        color: COLORS.textLight,
        marginBottom: SPACING.sm,
    },
    input: {
        backgroundColor: COLORS.background,
        borderRadius: 12,
        padding: SPACING.lg,
        fontSize: FONT_SIZES.lg,
        color: COLORS.text,
        borderWidth: 2,
        borderColor: COLORS.border,
        minHeight: MIN_TOUCH_TARGET,
    },
    modalButtons: {
        flexDirection: 'row',
        gap: SPACING.md,
        marginTop: SPACING.lg,
    },
    button: {
        flex: 1,
        borderRadius: 12,
        padding: SPACING.lg,
        alignItems: 'center',
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
    },
    cancelButton: {
        backgroundColor: COLORS.background,
        borderWidth: 2,
        borderColor: COLORS.border,
    },
    cancelButtonText: {
        fontSize: FONT_SIZES.md,
        fontWeight: '600',
        color: COLORS.textLight,
    },
    saveButton: {
        backgroundColor: COLORS.primary,
    },
    saveButtonText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
        color: COLORS.white,
    },
});
