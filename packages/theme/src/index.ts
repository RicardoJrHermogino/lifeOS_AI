/**
 * Void Intelligence design system — shared token source of truth.
 *
 * Web (`@repo/web`) consumes these via CSS variables in globals.css; the Flutter
 * app (`@repo/mobile`) mirrors the same names in Dart (`AppColors`). Keep token
 * names identical across both so developers can mentally map one to the other.
 */

export const dark = {
	// Backgrounds
	bgApp: "#0d0f1a", // Abyss — main app background
	bgSurface: "#141829", // Surface — sidebar, panels
	bgElevated: "#1f2744", // Elevated — cards, hover states
	bgOverlay: "#2d3a6a", // Overlay — modals, tooltips

	// Borders
	borderSubtle: "#1f2744",
	borderDefault: "#2d3a6a",
	borderStrong: "#3d5af1",

	// Text
	textPrimary: "#c8d0f0",
	textSecondary: "#7880a0",
	textMuted: "#4a5270",
	textInverse: "#0d0f1a",
} as const

export const light = {
	// Backgrounds
	bgApp: "#f7f8fd", // Frost — main app background
	bgSurface: "#eef0fb", // Cloud — sidebar, panels
	bgElevated: "#ffffff", // White — cards, modals
	bgOverlay: "#e2e6fa", // Overlay — hover states

	// Borders
	borderSubtle: "#d8dcf5",
	borderDefault: "#c4caee",
	borderStrong: "#3d5af1",

	// Text
	textPrimary: "#1a2050",
	textSecondary: "#5a6490",
	textMuted: "#9099c0",
	textInverse: "#ffffff",
} as const

export const shared = {
	// Brand accents
	accentPrimary: "#3d5af1", // Electric Blue — CTAs, links, active states
	accentTeal: "#5eead4", // Teal — goals, progress, health metrics
	accentViolet: "#a78bfa", // Violet — AI features, insights, suggestions
	accentAmber: "#f59e0b", // Amber — streaks, achievements, warnings

	// Accent on-color text (for text placed ON the accent backgrounds)
	onPrimary: "#ffffff",
	onTeal: "#065f46",
	onViolet: "#3b0764",
	onAmber: "#451a03",

	// Accent tinted backgrounds (dark mode chips, badges, pills)
	primarySubtle: "#1a2460",
	tealSubtle: "#0a2e28",
	violetSubtle: "#1e1540",
	amberSubtle: "#451a03",

	// Accent tinted backgrounds (light mode chips, badges, pills)
	primarySubtleLight: "#dde2fb",
	tealSubtleLight: "#d0f4ec",
	violetSubtleLight: "#ede8ff",
	amberSubtleLight: "#fef3c7",

	// Semantic
	success: "#10b981",
	warning: "#f59e0b",
	danger: "#ef4444",
	info: "#3d5af1",

	// Radius
	radiusSm: 4,
	radiusMd: 8,
	radiusLg: 12,
	radiusXl: 16,
	radiusFull: 9999,

	// Spacing scale (base 4)
	space1: 4,
	space2: 8,
	space3: 12,
	space4: 16,
	space5: 20,
	space6: 24,
	space8: 32,
	space10: 40,
	space12: 48,

	// Typography scale
	fontSizeXs: 11,
	fontSizeSm: 13,
	fontSizeMd: 15,
	fontSizeLg: 18,
	fontSizeXl: 22,
	fontSize2xl: 28,
	fontSize3xl: 36,

	fontWeightRegular: "400",
	fontWeightMedium: "500",
	fontWeightBold: "600",
} as const

/** Theme mode identifier. Dark is the default/fallback. */
export type ThemeMode = "dark" | "light"

/**
 * The full theme: per-mode color tokens merged with the mode-agnostic `shared`
 * tokens, plus `shared` exposed on its own for consumers that only need accents.
 */
export const theme = {
	dark: { ...dark, ...shared },
	light: { ...light, ...shared },
	shared,
} as const

export type Theme = typeof theme

/** Widen `as const` literal token values to their primitive types. */
type Widen<T> = {
	[K in keyof T]: T[K] extends string
		? string
		: T[K] extends number
			? number
			: T[K]
}

/** A single resolved token set (one mode's colors merged with `shared`). */
export type ThemeTokens = Widen<typeof dark & typeof shared>

/** Resolve the token set for a given mode. */
export function getTheme(mode: ThemeMode): ThemeTokens {
	return theme[mode]
}
