"use client"

import { useTheme as useNextTheme } from "next-themes"

import { theme as voidTheme, type ThemeTokens } from "@repo/theme"

export type ThemeMode = "dark" | "light" | "system"

/**
 * Thin wrapper over next-themes (which owns `.dark`-class switching + FOUC
 * prevention) that also resolves the Void Intelligence token set for the active
 * mode. Keeps the same `theme` / `setTheme` / `isDark` shape as the mobile hook.
 */
export function useTheme(): {
	theme: ThemeMode
	setTheme: (mode: ThemeMode) => void
	isDark: boolean
	tokens: ThemeTokens
} {
	const { theme, setTheme, resolvedTheme } = useNextTheme()
	const isDark = resolvedTheme === "dark"

	return {
		theme: (theme ?? "system") as ThemeMode,
		setTheme: (mode: ThemeMode) => setTheme(mode),
		isDark,
		tokens: isDark ? voidTheme.dark : voidTheme.light,
	}
}
