"use client"

import type { Route } from "next"
import Link from "next/link"
import { usePathname, useRouter } from "next/navigation"

import { cn } from "@/core/lib/utils"
import { authClient } from "@/services/better-auth/auth-client"

type NavItem = {
	href: Route
	label: string
	icon: string
	elementId: string
}

const PRIMARY_NAV: NavItem[] = [
	{ href: "/dashboard", label: "Dashboard", icon: "🏠", elementId: "nav-dashboard" },
	{ href: "/review" as Route, label: "Review", icon: "🎙️", elementId: "nav-capture" },
	{ href: "/timeline" as Route, label: "Timeline", icon: "📅", elementId: "nav-timeline" },
	{ href: "/ask" as Route, label: "Ask", icon: "💬", elementId: "nav-ask" },
	{ href: "/insights" as Route, label: "Insights", icon: "✨", elementId: "nav-insights" },
]

const FOOTER_NAV: NavItem[] = [
	{ href: "/submit-ticket", label: "Support", icon: "🎫", elementId: "nav-support" },
	{ href: "/settings" as Route, label: "Settings", icon: "⚙️", elementId: "nav-settings" },
]

type SiteSidebarProps = {
	userName: string
	userEmail: string
}

export function SiteSidebar({ userName, userEmail }: SiteSidebarProps) {
	const pathname = usePathname()
	const router = useRouter()
	const handleLogout = async () => {
		await authClient.signOut()
		router.push("/login")
		router.refresh()
	}
	const initials = userName
		.split(/\s+/)
		.filter(Boolean)
		.slice(0, 2)
		.map(part => part[0]?.toUpperCase())
		.join("")

	return (
		<aside className="bg-sidebar text-sidebar-foreground hidden flex-col gap-1 p-4 md:flex">
			<Link
				href="/"
				className="text-sidebar-accent-foreground mb-3 flex items-center gap-2 px-3 py-2 text-base font-extrabold tracking-tight"
			>
				<span className="bg-sidebar-primary inline-block size-2 rounded-full" aria-hidden />
				LifeOS AI
			</Link>
			{PRIMARY_NAV.map(item => {
				const isActive = pathname === item.href
				return (
					<Link
						key={item.elementId}
						href={item.href}
						data-element-id={item.elementId}
						className={cn(
							"flex items-center gap-2 rounded-2xl px-3.5 py-2.5 text-sm font-medium transition-colors",
							isActive
								? "bg-sidebar-primary text-sidebar-primary-foreground font-bold"
								: "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
						)}
					>
						<span className="w-5 text-center text-base" aria-hidden>
							{item.icon}
						</span>
						{item.label}
					</Link>
				)
			})}
			<div className="flex-1" />
			{FOOTER_NAV.map(item => {
				const isActive = pathname === item.href
				return (
					<Link
						key={item.elementId}
						href={item.href}
						data-element-id={item.elementId}
						className={cn(
							"flex items-center gap-2 rounded-2xl px-3.5 py-2.5 text-sm font-medium transition-colors",
							isActive
								? "bg-sidebar-primary text-sidebar-primary-foreground font-bold"
								: "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
						)}
					>
						<span className="w-5 text-center text-base" aria-hidden>
							{item.icon}
						</span>
						{item.label}
					</Link>
				)
			})}
			<div className="bg-sidebar-accent mt-2 flex items-center gap-3 rounded-2xl p-2.5">
				<div className="bg-sidebar-primary text-sidebar-primary-foreground flex size-8 items-center justify-center rounded-full text-xs font-bold">
					{initials || "U"}
				</div>
				<div className="flex min-w-0 flex-col">
					<span className="text-sidebar-accent-foreground truncate text-sm font-semibold">
						{userName}
					</span>
					<span className="text-sidebar-foreground truncate text-xs">{userEmail}</span>
				</div>
			</div>
			<button
				type="button"
				onClick={handleLogout}
				className="text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground mt-1 flex items-center gap-2 rounded-2xl px-3.5 py-2.5 text-sm font-medium transition-colors"
				data-element-id="nav-logout"
			>
				<span className="w-5 text-center text-base" aria-hidden>
					↪
				</span>
				Sign out
			</button>
		</aside>
	)
}
