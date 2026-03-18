/**
 * Offline queue service.
 * Queues create operations (schedules, patients, workers) in AsyncStorage
 * when the device is offline, and syncs them when back online.
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Alert } from 'react-native';
import ApiService from './api.service';

const QUEUE_KEY = 'offline_queue';

export interface QueuedItem {
    id: string;       // UUID for the queued item
    type: 'schedule' | 'patient' | 'worker';
    data: any;
    createdAt: string;
    retries: number;
}

/**
 * Get all queued items.
 */
export async function getQueue(): Promise<QueuedItem[]> {
    try {
        const raw = await AsyncStorage.getItem(QUEUE_KEY);
        return raw ? JSON.parse(raw) : [];
    } catch {
        return [];
    }
}

/**
 * Add an item to the offline queue.
 */
export async function enqueue(type: QueuedItem['type'], data: any): Promise<void> {
    const queue = await getQueue();
    const item: QueuedItem = {
        id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        type,
        data,
        createdAt: new Date().toISOString(),
        retries: 0,
    };
    queue.push(item);
    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
    console.log(`📦 Queued ${type} for sync (${queue.length} items in queue)`);
}

/**
 * Get count of queued items.
 */
export async function getQueueCount(): Promise<number> {
    const queue = await getQueue();
    return queue.length;
}

/**
 * Sync all queued items with the server.
 * Returns the number of successfully synced items.
 */
export async function syncQueue(): Promise<{ synced: number; failed: number }> {
    const queue = await getQueue();
    if (queue.length === 0) return { synced: 0, failed: 0 };

    console.log(`🔄 Syncing ${queue.length} queued items...`);

    let synced = 0;
    let failed = 0;
    const remaining: QueuedItem[] = [];

    for (const item of queue) {
        try {
            switch (item.type) {
                case 'schedule':
                    await ApiService.createSchedule(item.data);
                    break;
                case 'patient':
                    await ApiService.createPatient(item.data);
                    break;
                case 'worker':
                    await ApiService.createWorker(item.data);
                    break;
            }
            synced++;
            console.log(`✅ Synced ${item.type} (${item.id})`);
        } catch (error) {
            item.retries++;
            if (item.retries < 3) {
                remaining.push(item);
            }
            failed++;
            console.error(`❌ Failed to sync ${item.type} (${item.id}):`, error);
        }
    }

    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(remaining));

    if (synced > 0) {
        console.log(`🔄 Sync complete: ${synced} synced, ${failed} failed`);
    }

    return { synced, failed };
}

/**
 * Clear the entire queue.
 */
export async function clearQueue(): Promise<void> {
    await AsyncStorage.removeItem(QUEUE_KEY);
}

/**
 * Try to create an item online, fallback to offline queue.
 * Returns true if created online, false if queued for later.
 */
export async function createWithFallback(
    type: QueuedItem['type'],
    data: any,
    createFn: (data: any) => Promise<any>,
): Promise<{ online: boolean; result?: any }> {
    try {
        const result = await createFn(data);
        return { online: true, result };
    } catch (error: any) {
        // Network error → queue for later
        if (!error.response) {
            await enqueue(type, data);
            Alert.alert(
                'Saved Offline',
                `${type.charAt(0).toUpperCase() + type.slice(1)} saved locally and will sync when you\'re back online.`,
                [{ text: 'OK' }]
            );
            return { online: false };
        }
        // Server error → throw (don't queue)
        throw error;
    }
}
