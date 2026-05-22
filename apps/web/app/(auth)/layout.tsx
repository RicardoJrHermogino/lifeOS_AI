import Link from "next/link"

export default function AuthLayout({
	children,
}: Readonly<{
	children: React.ReactNode
}>) {
	return (
		<div className="bg-background text-foreground relative flex min-h-screen flex-col">
			<header className="border-border flex flex-col items-center gap-2 border-b px-8 py-6 text-center">
				<Link href="/" className="flex items-center gap-2 text-base font-extrabold tracking-tight">
					<span className="bg-primary inline-block size-2.5 rounded-full" aria-hidden />
					LifeOS AI
				</Link>
				<p className="text-muted-foreground text-sm">Your private second mind</p>
			</header>
			<main className="flex flex-1 items-center justify-center p-6">{children}</main>
		</div>
	)
}
