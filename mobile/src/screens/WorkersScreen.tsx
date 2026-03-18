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
import { Worker } from '../types';
import { COLORS, SPACING, FONT_SIZES, MIN_TOUCH_TARGET } from '../constants/theme';

export default function WorkersScreen() {
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [modalVisible, setModalVisible] = useState(false);
    const [editingWorker, setEditingWorker] = useState<Worker | null>(null);
    const [formData, setFormData] = useState({ name: '', mobile_number: '' });
    const [showSuccessToast, setShowSuccessToast] = useState(false);
    const [successMessage, setSuccessMessage] = useState('');

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
                // Update existing worker
                await ApiService.updateWorker(editingWorker.id, formData);
                setSuccessMessage('Worker updated successfully');
            } else {
                // Create new worker
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

    const renderWorkerItem = ({ item }: { item: Worker }) => (
        <TouchableOpacity
            style={styles.workerCard}
            onPress={() => openEditModal(item)}
        >
            <View style={styles.workerHeader}>
                <Text style={styles.workerName}>{item.name}</Text>
            </View>
            <Text style={styles.mobileNumber}>{item.mobile_number}</Text>
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
                data={workers}
                renderItem={renderWorkerItem}
                keyExtractor={(item) => item.id.toString()}
                contentContainerStyle={styles.listContainer}
                refreshControl={
                    <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyIcon}>👷</Text>
                        <Text style={styles.emptyText}>No workers yet</Text>
                        <Text style={styles.emptySubtext}>Tap "+ Add" to create one</Text>
                    </View>
                }
            />

            <TouchableOpacity style={styles.fab} onPress={openAddModal}>
                <Text style={styles.fabText}>+ Add</Text>
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
                        <Text style={styles.modalTitle}>
                            {editingWorker ? 'Edit Worker' : 'Add Worker'}
                        </Text>

                        <View style={styles.formSection}>
                            <Text style={styles.label}>Name</Text>
                            <TextInput
                                style={styles.input}
                                value={formData.name}
                                onChangeText={(text) => setFormData({ ...formData, name: text })}
                                placeholder="Enter worker name"
                                placeholderTextColor={COLORS.textLight}
                            />
                        </View>

                        <View style={styles.formSection}>
                            <Text style={styles.label}>Mobile Number</Text>
                            <TextInput
                                style={styles.input}
                                value={formData.mobile_number}
                                onChangeText={(text) => setFormData({ ...formData, mobile_number: text })}
                                placeholder="Enter mobile number"
                                placeholderTextColor={COLORS.textLight}
                                keyboardType="phone-pad"
                            />
                        </View>

                        <View style={styles.modalButtons}>
                            <TouchableOpacity
                                style={[styles.button, styles.cancelButton]}
                                onPress={closeModal}
                            >
                                <Text style={styles.cancelButtonText}>Cancel</Text>
                            </TouchableOpacity>

                            <TouchableOpacity
                                style={[styles.button, styles.saveButton]}
                                onPress={handleSave}
                            >
                                <Text style={styles.saveButtonText}>Save</Text>
                            </TouchableOpacity>
                        </View>

                        {editingWorker && (
                            <TouchableOpacity
                                style={styles.deleteButton}
                                onPress={handleDelete}
                            >
                                <Text style={styles.deleteButtonText}>Delete Worker</Text>
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
        padding: SPACING.md,
    },
    workerCard: {
        backgroundColor: COLORS.white,
        borderRadius: 16,
        padding: SPACING.xl,
        marginBottom: SPACING.md,
        borderLeftWidth: 6,
        borderLeftColor: COLORS.success,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
        minHeight: MIN_TOUCH_TARGET,
    },
    workerHeader: {
        marginBottom: SPACING.sm,
    },
    workerName: {
        fontSize: FONT_SIZES.xl,
        fontWeight: 'bold',
        color: COLORS.text,
    },
    mobileNumber: {
        fontSize: FONT_SIZES.md,
        color: COLORS.textLight,
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
        backgroundColor: COLORS.success,
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
        marginBottom: SPACING.xl,
        textAlign: 'center',
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
        fontSize: FONT_SIZES.lg,
        fontWeight: '600',
        color: COLORS.textLight,
    },
    saveButton: {
        backgroundColor: COLORS.success,
    },
    saveButtonText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
        color: COLORS.white,
    },
    deleteButton: {
        marginTop: SPACING.lg,
        padding: SPACING.lg,
        alignItems: 'center',
        borderRadius: 12,
        backgroundColor: COLORS.error,
        minHeight: MIN_TOUCH_TARGET,
        justifyContent: 'center',
    },
    deleteButtonText: {
        fontSize: FONT_SIZES.lg,
        fontWeight: 'bold',
        color: COLORS.white,
    },
});
