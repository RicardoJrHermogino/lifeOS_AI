import type { Route } from "next"
import Link from "next/link"

import { getSession } from "@/services/better-auth/auth-server"

type Feature = {
	icon: string
	title: string
	body: string
}

type Step = {
	num: string
	title: string
	body: string
}

const features: Feature[] = [
	{
		icon: "🎙️",
		title: "Voice & Text Capture",
		body: "Speak or type a thought in seconds. LifeOS AI transcribes, structures, and stores it as a memory.",
	},
	{
		icon: "🧠",
		title: "AI Memory Extraction",
		body: "AI identifies emotions, people, goals, decisions, and actions from your captures — automatically.",
	},
	{
		icon: "📅",
		title: "Life Timeline",
		body: "Browse your memories chronologically. Filter by mood, person, topic, or date range.",
	},
	{
		icon: "💬",
		title: "Ask Your Past",
		body: "\"Why was I stressed last month?\" Get grounded answers from your own stored memories.",
	},
	{
		icon: "✨",
		title: "Daily Reflections",
		body: "A gentle daily summary of your key moments, mood arc, decisions, and open actions.",
	},
	{
		icon: "🔒",
		title: "Private by Default",
		body: "You own your data. Export, edit, or delete any memory at any time. No sharing, no surveillance.",
	},
]

const steps: Step[] = [
	{
		num: "STEP 01",
		title: "Capture",
		body: "Record a voice thought or type a reflection. Takes under 10 seconds.",
	},
	{
		num: "STEP 02",
		title: "Review",
		body: "AI structures your input into a memory. You review, correct, and save it.",
	},
	{
		num: "STEP 03",
		title: "Reflect",
		body: "Ask questions, browse your timeline, and read daily summaries of your life.",
	},
]

export default async function Home() {
	const session = await getSession()
	const isLoggedIn = !!session
	const primaryHref: Route = isLoggedIn ? "/dashboard" : "/register"
	const primaryLabel = isLoggedIn ? "Open your dashboard" : "Start for free"

	return (
		<>
			<nav className="border-border bg-background sticky top-0 z-10 flex items-center justify-between border-b px-6 py-5 md:px-10">
				<Link href="/" className="flex items-center gap-2 text-base font-extrabold tracking-tight">
					<span className="bg-primary inline-block size-2.5 rounded-full" aria-hidden />
					LifeOS AI
				</Link>
				<div className="flex items-center gap-2">
					<Link
						href={"/#features" as Route}
						className="text-muted-foreground hover:bg-accent/15 hidden rounded-full px-4 py-2 text-sm font-medium md:inline-block"
					>
						Features
					</Link>
					<Link
						href={"/#how" as Route}
						className="text-muted-foreground hover:bg-accent/15 hidden rounded-full px-4 py-2 text-sm font-medium md:inline-block"
					>
						How it works
					</Link>
					{isLoggedIn ? (
						<Link
							href={"/dashboard" as Route}
							className="bg-primary text-primary-foreground rounded-full px-5 py-2 text-sm font-bold"
						>
							Dashboard
						</Link>
					) : (
						<>
							<Link
								href={"/login" as Route}
								className="text-muted-foreground hover:bg-accent/15 rounded-full px-4 py-2 text-sm font-medium"
							>
								Sign in
							</Link>
							<Link
								href={"/register" as Route}
								className="bg-primary text-primary-foreground rounded-full px-5 py-2 text-sm font-bold"
								data-element-id="nav-cta-register"
							>
								Get started
							</Link>
						</>
					)}
				</div>
			</nav>

			<section className="mx-auto flex max-w-3xl flex-col items-center gap-6 px-6 pt-20 pb-16 text-center">
				<div className="border-primary/30 bg-primary/10 text-primary-foreground inline-flex items-center gap-2 rounded-full border px-4 py-1.5 text-xs font-semibold">
					<span className="bg-primary inline-block size-1.5 rounded-full" aria-hidden />
					<span className="text-foreground">Your private second mind</span>
				</div>
				<h1 className="text-5xl leading-[1.05] font-black tracking-tight md:text-7xl">
					Capture your life.
					<br />
					<span className="text-primary">Understand it</span> over time.
				</h1>
				<p className="text-muted-foreground max-w-xl text-lg leading-relaxed md:text-xl">
					LifeOS AI turns your voice thoughts, reflections, and daily moments into structured
					memories — then helps you find patterns, recall decisions, and reflect with clarity.
				</p>
				<div className="mt-2 flex flex-wrap justify-center gap-3">
					<Link
						href={primaryHref}
						className="bg-primary text-primary-foreground rounded-full px-8 py-3.5 text-base font-bold"
						data-element-id="hero-cta-register"
					>
						{primaryLabel}
					</Link>
					<Link
						href={"/#how" as Route}
						className="border-border text-foreground rounded-full border-2 px-8 py-3.5 text-base font-semibold"
						data-element-id="hero-cta-learn"
					>
						See how it works
					</Link>
				</div>
			</section>

			<section id="features" className="mx-auto max-w-6xl px-6 py-16">
				<div className="text-primary mb-3 text-center text-xs font-bold tracking-widest uppercase">
					What LifeOS AI does
				</div>
				<h2 className="mb-12 text-center text-3xl font-extrabold tracking-tight md:text-4xl">
					Everything your memory needs
				</h2>
				<div className="grid grid-cols-1 gap-5 md:grid-cols-3">
					{features.map(f => (
						<div
							key={f.title}
							className="border-border bg-card text-card-foreground flex flex-col gap-3 rounded-3xl border p-7"
						>
							<div className="bg-primary/15 flex size-11 items-center justify-center rounded-2xl text-xl">
								<span aria-hidden>{f.icon}</span>
							</div>
							<h3 className="text-base font-bold">{f.title}</h3>
							<p className="text-muted-foreground text-sm leading-relaxed">{f.body}</p>
						</div>
					))}
				</div>
			</section>

			<section id="how" className="bg-foreground text-background px-6 py-16">
				<div className="mx-auto max-w-4xl text-center">
					<h2 className="text-3xl font-extrabold tracking-tight md:text-4xl">How it works</h2>
					<p className="text-muted mt-1 mb-12 opacity-70">
						Three simple steps to a smarter personal memory
					</p>
					<div className="flex flex-wrap justify-center gap-6">
						{steps.map(s => (
							<div
								key={s.num}
								className="border-foreground/20 bg-foreground/5 w-60 rounded-3xl border p-6 text-left"
							>
								<div className="text-primary mb-2 text-xs font-bold tracking-widest">{s.num}</div>
								<h3 className="text-background mb-1 text-base font-bold">{s.title}</h3>
								<p className="text-muted text-sm leading-relaxed opacity-70">{s.body}</p>
							</div>
						))}
					</div>
				</div>
			</section>

			<section className="px-6 py-20 text-center">
				<div className="bg-primary/15 border-primary/30 mx-auto flex max-w-xl flex-col items-center gap-4 rounded-[2rem] border p-14">
					<h2 className="text-3xl font-extrabold tracking-tight">Your second mind is waiting.</h2>
					<p className="text-muted-foreground">
						Start capturing your life today. Private, editable, and always yours.
					</p>
					<Link
						href={primaryHref}
						className="bg-primary text-primary-foreground mt-3 rounded-full px-8 py-3.5 text-base font-bold"
						data-element-id="bottom-cta-register"
					>
						{isLoggedIn ? "Open your dashboard" : "Create your account"}
					</Link>
				</div>
			</section>

			<footer className="border-border text-muted-foreground flex flex-wrap items-center justify-between gap-2 border-t px-10 py-6 text-xs">
				<span>© 2026 LifeOS AI. All rights reserved.</span>
				<span>Privacy · Terms · Support</span>
			</footer>
		</>
	)
}
