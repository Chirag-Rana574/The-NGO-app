export const COLORS = {
    // Status colors
    blue: '#3B82F6',      // Upcoming
    yellow: '#F59E0B',    // Awaiting Response
    green: '#10B981',     // Completed
    orange: '#F97316',    // Late Completed
    red: '#EF4444',       // Expired
    gray: '#6B7280',      // Not Done

    // UI colors
    primary: '#3B82F6',
    background: '#F9FAFB',
    white: '#FFFFFF',
    text: '#111827',
    textLight: '#6B7280',
    border: '#E5E7EB',
    error: '#EF4444',
    success: '#10B981',
};

export const SPACING = {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
};

export const MIN_TOUCH_TARGET = 56; // Minimum accessible touch target size

export const FONT_SIZES = {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
};

export const STATUS_COLORS = {
    CREATED: COLORS.blue,
    REMINDER_SENT: COLORS.blue,
    AWAITING_RESPONSE: COLORS.yellow,
    COMPLETED: COLORS.green,
    NOT_DONE: COLORS.gray,
    LATE_COMPLETED: COLORS.orange,
    EXPIRED: COLORS.red,
};

export const STATUS_LABELS = {
    CREATED: 'Upcoming',
    REMINDER_SENT: 'Reminder Sent',
    AWAITING_RESPONSE: 'Awaiting Response',
    COMPLETED: 'Completed',
    NOT_DONE: 'Not Done',
    LATE_COMPLETED: 'Late Completed',
    EXPIRED: 'Expired',
};

export const BORDER_RADIUS = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
};

export const CARD_SHADOW = {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 2,
};
