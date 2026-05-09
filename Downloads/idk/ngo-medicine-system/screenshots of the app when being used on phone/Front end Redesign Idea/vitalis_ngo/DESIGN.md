# Design System Strategy: The Clinical Curator

## 1. Overview & Creative North Star
**Creative North Star: The Clinical Curator**
This design system rejects the "utilitarian database" look of traditional medical software. Instead, it adopts the persona of a **Clinical Curator**: an interface that feels as precise as a prescription but as legible and calm as a high-end editorial journal. 

To break the "template" look, we utilize **intentional asymmetry** (e.g., offset headers), **tonal depth** (layering instead of outlining), and a **high-contrast typography scale**. The goal is to instill trust through sophisticated white space and a "Human-Centric Professionalism" that reduces cognitive load for NGO workers in high-stress environments.

---

## 2. Colors & Surface Philosophy
Our palette is rooted in a "Pure & Professional" spectrum. We move beyond flat color application by treating the UI as a series of physical, interactive layers.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are strictly prohibited for sectioning or containment. Boundaries must be defined solely through:
- **Background Color Shifts:** Placing a `surface-container-low` section against a `surface` background.
- **Tonal Transitions:** Using depth to imply edge.

### Surface Hierarchy & Nesting
Treat the screen as a stack of fine paper. 
- **Base Layer:** `surface` (#F8F9FA)
- **Secondary Layouts:** `surface-container-low` (#F3F4F5)
- **Interactive Cards:** `surface-container-lowest` (#FFFFFF)
- **High-Emphasis Overlays:** `surface-bright` (#F8F9FA) with 85% opacity.

### Glass & Gradient (The Polish)
To move beyond "out-of-the-box" React Native styles:
- **Floating Elements:** Use Glassmorphism (semi-transparent `surface` with a `backdrop-blur` of 10-15px).
- **Primary CTAs:** Use a subtle linear gradient from `primary` (#0058BE) to `primary_container` (#2170E4) at a 135° angle. This adds "visual soul" and a tactile, premium feel.

---

## 3. Typography: The Editorial Voice
We use a dual-typeface system to balance authority with utility.

| Level | Token | Font | Size | Character |
| :--- | :--- | :--- | :--- | :--- |
| **Display** | `display-lg` | Manrope | 3.5rem | Bold, authoritative, editorial. |
| **Headline**| `headline-md`| Manrope | 1.75rem | Clear, confident section breaks. |
| **Title**   | `title-md`   | Inter | 1.125rem | Medium weight for card titles. |
| **Body**    | `body-md`    | Inter | 0.875rem | High legibility for medical data. |
| **Label**   | `label-sm`   | Inter | 0.6875rem | Uppercase, tracked out (+5%) for metadata. |

**The Identity Gap:** Large `display` headlines should use `on_surface` (#191C1D) with tight letter spacing (-2%), creating a modern, "Swiss-style" typographic impact that contrasts with the functional, airy `body` text.

---

## 4. Elevation & Depth: Tonal Layering
Forget 2014-era drop shadows. Hierarchy is achieved through **Ambient Light Physics**.

*   **The Layering Principle:** Depth is created by stacking. A `surface-container-lowest` card placed on a `surface-container-low` background creates a natural lift.
*   **Ambient Shadows:** For floating elements (like the Pill Tab Bar), use an extra-diffused shadow:
    *   `shadowOffset: { width: 0, height: 8 }`
    *   `shadowOpacity: 0.06`
    *   `shadowRadius: 24`
    *   `shadowColor: tokens.primary` (Tinted shadows feel more natural than grey).
*   **The "Ghost Border" Fallback:** If accessibility requires a border, use the `outline_variant` at **15% opacity**. Never 100%.

---

## 5. Components

### Cards (The Signature Pattern)
- **Structure:** No dividers. Use `xl` (1.5rem) rounded corners.
- **The Signature Edge:** A 4px left-aligned accent bar using the specific Status Colors (e.g., `REMINDER_SENT`: #8B5CF6). 
- **Nesting:** Place content inside with `padding: 20` (Spacing scale 5).

### Floating Pill Tab Bar
- **Style:** A floating `full` rounded container. 
- **Visuals:** Glassmorphic background (80% `surface_container_lowest`) with a `primary` tinted active state. 
- **Animation:** Use a spring-based "slide-and-expand" interaction for the active icon.

### Custom Numeric Keypad (PIN Entry)
- **Layout:** Abandon the grid-line look. Use a 3x4 layout with large `3.5rem` spacing between buttons.
- **Buttons:** Circular or Soft-Square (`lg` rounding). 
- **Interaction:** On press, the button should shift from `surface` to `surface-container-high` without a border.

### Primary Action Buttons
- **Geometry:** `full` (Pill-style) or `xl` (24px) rounding.
- **Surface:** Linear gradient (Primary to Primary Container).
- **Text:** `title-sm` in `on_primary` (#FFFFFF), centered, semi-bold.

---

## 6. Do's and Don'ts

### Do
*   **DO** use whitespace as a functional tool. If two elements feel cluttered, increase the spacing to `spacing-8` (2rem) rather than adding a divider.
*   **DO** use "Surface Tints." A very slight blue tint in your background colors reinforces the medical trust of the `primary` blue.
*   **DO** utilize `surface-container-highest` for inactive input states to give them a recessed, tactile feel.

### Don't
*   **DON'T** use 1px dividers to separate list items. Use a `spacing-4` (1rem) gap or a subtle shift in background tone.
*   **DON'T** use pure black for text. Always use `on_surface` (#191C1D) to maintain the premium, soft-contrast look.
*   **DON'T** use default "System" shadows. They are too heavy and make the app feel dated. Stick to the "Ambient Shadow" formula.
*   **DON'T** crowd the edges. Respect the "Gutter": keep a minimum of `spacing-5` (1.25rem) from the screen edge for all primary content.