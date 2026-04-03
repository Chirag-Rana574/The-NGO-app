// ─── Design Tokens ──────────────────────────────────────────────
// Clinical Curator design system — matches the redesign mockups
// Implements: Tonal Layering, No-Line Rule, Ambient Light Physics

export const COLORS = {
    // Primary palette
    primary: '#0058BE',         // Deep blue — headers, active tabs, CTAs
    primaryLight: '#2170E4',    // Primary container — gradient endpoint
    primaryDark: '#004499',     // Dark blue — pressed states
    accent: '#2196F3',          // Bright blue — links, accents

    // Surface Hierarchy (The "Stack of Fine Paper")
    surface: '#F8F9FA',               // Base layer — page background
    surfaceContainerLow: '#F3F4F5',   // Secondary layouts — section backgrounds
    surfaceContainerLowest: '#FFFFFF', // Interactive cards — card background
    surfaceContainerHigh: '#ECEEF0',  // Pressed/active input states
    surfaceContainerHighest: '#E8EAED', // Inactive input states — recessed feel
    surfaceBright: 'rgba(248,249,250,0.85)', // High-emphasis overlays

    // Status colors
    green: '#2E7D32',          // Completed
    greenLight: '#E8F5E9',     // Completed background
    yellow: '#F9A825',         // Awaiting Response
    yellowLight: '#FFF8E1',    // Awaiting background
    orange: '#EF6C00',         // Late Completed / Overdue
    orangeLight: '#FFF3E0',    // Orange background
    red: '#C62828',            // Expired / Critical / Not Done
    redLight: '#FFEBEE',       // Red background
    blue: '#0058BE',           // Upcoming / Scheduled
    blueLight: '#E3F2FD',      // Blue background
    gray: '#616161',           // Not Done / neutral
    grayLight: '#F3F4F5',      // Gray background (matches surfaceContainerLow)
    purple: '#8B5CF6',         // Reminder Sent accent

    // UI colors
    background: '#F8F9FA',     // = surface
    white: '#FFFFFF',
    card: '#FFFFFF',           // = surfaceContainerLowest
    text: '#191C1D',           // Primary text (on_surface — NOT pure black)
    textSecondary: '#5F6368',  // Secondary text
    textLight: '#9E9E9E',      // Muted text / timestamps
    textHint: '#BDBDBD',       // Placeholder text
    border: '#E8EAF0',         // Ghost borders only (15% opacity usage)
    borderLight: '#F0F0F0',    // Subtle separators (avoid using)
    divider: '#EEEEEE',        // Section dividers (avoid — use spacing instead)
    outlineVariant: 'rgba(200,204,210,0.15)', // Ghost border fallback
    error: '#C62828',
    success: '#2E7D32',
    warning: '#F9A825',

    // Special
    whatsapp: '#25D366',       // WhatsApp green
    overlay: 'rgba(0,0,0,0.5)',
    shimmer: '#E0E0E0',        // Loading skeleton
};

export const SPACING = {
    xs: 4,       // spacing-1
    sm: 8,       // spacing-2
    md: 16,      // spacing-4 (1rem)
    lg: 20,      // spacing-5 (1.25rem) — minimum gutter from screen edge
    xl: 32,      // spacing-8 (2rem) — preferred gap between unrelated elements
    xxl: 48,     // spacing-12
};

export const MIN_TOUCH_TARGET = 48;

export const FONT_SIZES = {
    xxs: 10,     // label-sm metadata
    xs: 11,      // label-sm uppercase tracked
    sm: 14,      // body-md
    md: 16,      // title-md
    lg: 18,      // title-md medium
    xl: 24,      // headline-md
    xxl: 28,     // display
    hero: 40,    // display-lg
};

export const FONT_WEIGHTS = {
    regular: '400' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: '700' as const,
    heavy: '800' as const,
};

export const LETTER_SPACING = {
    tight: -0.5,       // Display headlines (Swiss-style)
    normal: 0,
    wide: 0.5,
    wider: 1.0,
    widest: 1.5,       // Section headers "MANAGEMENT", "ACTION CENTER"
    metadata: 0.8,     // label-sm (+5% tracking)
};

export const STATUS_COLORS: Record<string, string> = {
    CREATED: COLORS.blue,
    REMINDER_SENT: COLORS.purple,
    AWAITING_RESPONSE: COLORS.yellow,
    COMPLETED: COLORS.green,
    NOT_DONE: COLORS.red,
    LATE_COMPLETED: COLORS.orange,
    EXPIRED: COLORS.red,
};

export const STATUS_BG_COLORS: Record<string, string> = {
    CREATED: COLORS.blueLight,
    REMINDER_SENT: '#F3F0FF',
    AWAITING_RESPONSE: COLORS.yellowLight,
    COMPLETED: COLORS.greenLight,
    NOT_DONE: COLORS.redLight,
    LATE_COMPLETED: COLORS.orangeLight,
    EXPIRED: COLORS.redLight,
};

export const STATUS_LABELS: Record<string, string> = {
    CREATED: 'Scheduled',
    REMINDER_SENT: 'Reminder Sent',
    AWAITING_RESPONSE: 'Awaiting',
    COMPLETED: 'Completed',
    NOT_DONE: 'Not Done',
    LATE_COMPLETED: 'Late',
    EXPIRED: 'Expired',
};

export const BORDER_RADIUS = {
    xs: 4,
    sm: 8,
    md: 16,      // Standard card rounding
    lg: 20,      // Soft-square buttons, larger cards
    xl: 24,      // Signature card pattern (1.5rem)
    full: 999,   // Pill shapes
};

// Ambient Light Physics shadow — tinted with primary
export const CARD_SHADOW = {
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.06,
    shadowRadius: 24,
    elevation: 2,
};

export const CARD_SHADOW_MEDIUM = {
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.08,
    shadowRadius: 20,
    elevation: 4,
};

export const CARD_SHADOW_HEAVY = {
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.12,
    shadowRadius: 28,
    elevation: 8,
};

// Section header style (e.g., "MANAGEMENT", "ACTION CENTER")
export const SECTION_HEADER_STYLE = {
    fontSize: FONT_SIZES.xxs,
    fontWeight: FONT_WEIGHTS.bold,
    letterSpacing: LETTER_SPACING.widest,
    color: COLORS.primary,
    textTransform: 'uppercase' as const,
    marginBottom: SPACING.xs,
};

// App header bar — no bottom border (No-Line Rule)
export const HEADER_STYLE = {
    backgroundColor: COLORS.white,
    elevation: 0,
    shadowOpacity: 0,
    borderBottomWidth: 0,
};

export const HEADER_TITLE_STYLE = {
    color: COLORS.primary,
    fontSize: FONT_SIZES.lg,
    fontWeight: FONT_WEIGHTS.bold,
};

// Gradient config for primary CTAs
export const GRADIENT_PRIMARY = {
    colors: [COLORS.primary, COLORS.primaryLight],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
};
