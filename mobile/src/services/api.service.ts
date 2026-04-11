import axios, { AxiosInstance, AxiosError } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const API_BASE_URL = 'http://192.168.0.104:8000/api';

class ApiService {
    private client: AxiosInstance;

    constructor() {
        this.client = axios.create({
            baseURL: API_BASE_URL,
            timeout: 10000,
            headers: {
                'Content-Type': 'application/json',
            },
        });

        // Request interceptor: attach JWT token
        this.client.interceptors.request.use(
            async (config) => {
                const token = await AsyncStorage.getItem('jwt_token');
                if (token) {
                    config.headers.Authorization = `Bearer ${token}`;
                }
                return config;
            },
            (error) => Promise.reject(error)
        );

        // Response interceptor for error handling
        this.client.interceptors.response.use(
            (response) => response,
            (error: AxiosError) => {
                this.handleError(error);
                return Promise.reject(error);
            }
        );
    }

    private handleError(error: AxiosError) {
        if (error.response) {
            const status = error.response.status;
            const data = error.response.data as any;
            const detail = data?.detail || data?.message || '';

            // Map common HTTP errors to user-friendly messages
            if (status === 401) {
                console.error('Auth Error: Session expired or invalid.');
            } else if (status === 403) {
                console.error('Permission denied:', detail);
            } else if (status === 404) {
                console.error('Not found:', detail);
            } else if (status === 422) {
                console.error('Validation error:', detail);
            } else if (status >= 500) {
                console.error('Server error. Please try again later.');
            } else {
                console.error('API Error:', status, detail);
            }
        } else if (error.request) {
            console.error('Network Error: Could not reach the server. Check your connection.');
        } else {
            console.error('Error:', error.message);
        }
    }

    /**
     * Get a user-friendly error message from an error.
     */
    static getErrorMessage(error: any): string {
        if (error?.response) {
            const status = error.response.status;
            const detail = error.response.data?.detail || '';
            if (status === 401) return 'Session expired. Please log in again.';
            if (status === 403) return 'You don\'t have permission for this action.';
            if (status === 404) return 'The requested item was not found.';
            if (status === 422) return detail || 'Invalid data. Please check your inputs.';
            if (status >= 500) return 'Server error. Please try again later.';
            return detail || 'Something went wrong.';
        }
        if (error?.request) return 'No network connection. Please check your internet.';
        return error?.message || 'An unexpected error occurred.';
    }

    // ─── Authentication (Google OAuth) ──────────────────────

    async loginWithGoogle(idToken: string) {
        const response = await this.client.post('/auth/google', { id_token: idToken });
        return response.data;
    }

    async getMe() {
        const response = await this.client.get('/auth/me');
        return response.data;
    }

    // ─── Push Notifications ─────────────────────────────────

    async registerPushToken(token: string, deviceInfo?: string) {
        const response = await this.client.post('/push/register', {
            token,
            device_info: deviceInfo,
        });
        return response.data;
    }

    async unregisterPushToken(token: string) {
        const response = await this.client.delete('/push/unregister', {
            params: { token },
        });
        return response.data;
    }

    async getNotifications(limit: number = 50) {
        const response = await this.client.get('/push/notifications', {
            params: { limit },
        });
        return response.data;
    }

    async markNotificationRead(id: number) {
        const response = await this.client.post(`/push/notifications/${id}/read`);
        return response.data;
    }

    async markAllNotificationsRead() {
        const response = await this.client.post('/push/notifications/read-all');
        return response.data;
    }

    async getUnreadNotificationCount() {
        const response = await this.client.get('/push/notifications/unread-count');
        return response.data;
    }

    // ─── Settings ───────────────────────────────────────────

    async getAppSettings() {
        const response = await this.client.get('/settings');
        return response.data;
    }

    async updateTimezone(timezone: string) {
        const response = await this.client.put('/settings/timezone', { timezone });
        return response.data;
    }

    // ─── Reports & Dashboard ────────────────────────────────

    async getDashboard() {
        const response = await this.client.get('/reports/dashboard');
        return response.data;
    }

    async getReportHistory(days: number = 30) {
        const response = await this.client.get('/reports/history', { params: { days } });
        return response.data;
    }

    async getWorkerPerformance(days: number = 30) {
        const response = await this.client.get('/reports/worker-performance', { params: { days } });
        return response.data;
    }

    async getStockSummary() {
        const response = await this.client.get('/reports/stock-summary');
        return response.data;
    }

    // ─── Patients ───────────────────────────────────────────

    async getPatients(activeOnly: boolean = true) {
        const response = await this.client.get('/patients', {
            params: { active_only: activeOnly },
        });
        return response.data;
    }

    async createPatient(data: { name: string }) {
        const response = await this.client.post('/patients', data);
        return response.data;
    }

    async updatePatient(id: number, data: any) {
        const response = await this.client.put(`/patients/${id}`, data);
        return response.data;
    }

    async deletePatient(id: number) {
        const response = await this.client.delete(`/patients/${id}`);
        return response.data;
    }

    // ─── Workers ────────────────────────────────────────────

    async getWorkers(activeOnly: boolean = true) {
        const response = await this.client.get('/workers', {
            params: { active_only: activeOnly },
        });
        return response.data;
    }

    async createWorker(data: { name: string; mobile_number: string }) {
        const response = await this.client.post('/workers', data);
        return response.data;
    }

    async updateWorker(id: number, data: any) {
        const response = await this.client.put(`/workers/${id}`, data);
        return response.data;
    }

    async deleteWorker(id: number) {
        const response = await this.client.delete(`/workers/${id}`);
        return response.data;
    }

    // ─── Medicines ──────────────────────────────────────────

    async getMedicines(activeOnly: boolean = true) {
        const response = await this.client.get('/medicines', {
            params: { active_only: activeOnly },
        });
        return response.data;
    }

    async createMedicine(data: {
        name: string;
        description?: string;
        dosage_unit: string;
        initial_stock: number;
        min_stock_level?: number;
    }) {
        const response = await this.client.post('/medicines', data);
        return response.data;
    }

    async updateMedicine(id: number, data: any) {
        const response = await this.client.put(`/medicines/${id}`, data);
        return response.data;
    }

    async adjustStock(id: number, data: {
        amount: number;
        notes: string;
        created_by: string;
    }) {
        const response = await this.client.post(`/medicines/${id}/adjust-stock`, data);
        return response.data;
    }

    async getStockTransactions(medicineId: number, limit: number = 50) {
        const response = await this.client.get(`/medicines/${medicineId}/transactions`, {
            params: { limit },
        });
        return response.data;
    }

    // ─── Schedules ──────────────────────────────────────────

    async getSchedules(filters?: {
        worker_id?: number;
        medicine_id?: number;
        status?: string;
        date_from?: string;
        date_to?: string;
    }) {
        const response = await this.client.get('/schedules', { params: filters });
        return response.data;
    }

    async createSchedule(data: {
        patient_id: number;
        worker_id: number;
        medicine_id: number;
        scheduled_time: string;
        dose_amount: number;
    }) {
        const response = await this.client.post('/schedules', data);
        return response.data;
    }

    async updateSchedule(id: number, data: {
        scheduled_time?: string;
        dose_amount?: number;
        patient_id?: number;
        worker_id?: number;
        medicine_id?: number;
        master_key?: string;
    }) {
        const response = await this.client.put(`/schedules/${id}`, data);
        return response.data;
    }

    async overrideSchedule(id: number, data: {
        master_password: string;
        reason: string;
        update_data: any;
    }) {
        const response = await this.client.post(`/schedules/${id}/override`, data);
        return response.data;
    }

    async deleteSchedule(id: number, masterKey?: string) {
        const params = masterKey ? { master_key: masterKey } : {};
        const response = await this.client.delete(`/schedules/${id}`, { params });
        return response.data;
    }

    // ─── Audit Logs ─────────────────────────────────────────

    async getAuditLogs(filters?: {
        entity_type?: string;
        entity_id?: number;
        action?: string;
        date_from?: string;
        date_to?: string;
        limit?: number;
    }) {
        const response = await this.client.get('/audit', { params: filters });
        return response.data;
    }

    // ─── Master Key System ──────────────────────────────────

    async getKeyStatus(): Promise<{ is_setup: boolean; pin_length: number | null }> {
        const response = await this.client.get('/auth/key-status');
        return response.data;
    }

    async setupKey(pin: string): Promise<void> {
        await this.client.post('/auth/setup-key', { pin });
    }

    async verifyKey(pin: string): Promise<boolean> {
        try {
            const response = await this.client.post('/auth/verify-key', { pin });
            return response.data?.data?.valid === true;
        } catch (error) {
            return false;
        }
    }

    async changeKey(currentPin: string, newPin: string): Promise<void> {
        await this.client.post('/auth/change-key', {
            current_pin: currentPin,
            new_pin: newPin,
        });
    }

    async verifyPasskey(passkey: string): Promise<boolean> {
        return this.verifyKey(passkey);
    }

    // ─── Medicine Deletion ──────────────────────────────────

    async deleteMedicine(id: number) {
        const response = await this.client.delete(`/medicines/${id}`);
        return response.data;
    }
}

export default new ApiService();
