import Link from "next/link"

import { LifeOSMark } from "@/core/components/lifeos-mark"

export default function AuthLayout({
	children,
}: Readonly<{
	children: React.ReactNode
}>) {
	return (
		<div className="bg-background text-foreground relative flex min-h-screen flex-col overflow-hidden">
			<div className="from-lifeos-primary-subtle via-background to-lifeos-violet-subtle dark:from-lifeos-primary-subtle dark:via-background dark:to-lifeos-bg-surface absolute inset-0 bg-linear-to-br" />
			<div
				className="border-lifeos-border-subtle bg-card/80 absolute -left-20 top-24 hidden h-96 w-36 rotate-[-14deg] rounded-[2rem] border shadow-2xl shadow-primary/10 md:block"
				aria-hidden
			/>
			<div
				className="border-lifeos-border-subtle bg-card/70 absolute -right-16 top-[-3rem] hidden h-80 w-32 rotate-[-16deg] rounded-[2rem] border shadow-2xl shadow-primary/10 md:block"
				aria-hidden
			/>
			<div
				className="border-lifeos-border-subtle bg-card/70 absolute -bottom-24 left-12 hidden h-64 w-36 rotate-[-11deg] rounded-[2rem] border shadow-2xl shadow-primary/10 lg:block"
				aria-hidden
			/>
			<header className="absolute left-0 right-0 top-0 z-10 flex items-center justify-between px-6 py-5 sm:px-8">
				<Link href="/" className="flex items-center gap-2 text-base font-extrabold">
					<LifeOSMark className="size-7" />
					LifeOS AI
				</Link>
				<p className="text-muted-foreground hidden text-sm sm:block">Your private second mind</p>
			</header>
			<main className="relative z-1 flex flex-1 items-center justify-center px-5 py-24">
				{children}
			</main>
		</div>
	)
}
