import { redirect } from "next/navigation"

import { SiteSidebar } from "@/features/lifeos/components/site-sidebar"
import { getSession } from "@/services/better-auth/auth-server"

export default async function SiteLayout({
	children,
}: Readonly<{
	children: React.ReactNode
}>) {
	const session = await getSession()

	if (!session) {
		redirect("/login")
	}

	return (
		<div className="bg-background text-foreground grid min-h-screen grid-cols-1 md:grid-cols-[240px_1fr]">
			<SiteSidebar
				userName={session.user.name || "You"}
				userEmail={session.user.email || ""}
			/>
			<main className="min-w-0 overflow-y-auto">{children}</main>
		</div>
	)
}
