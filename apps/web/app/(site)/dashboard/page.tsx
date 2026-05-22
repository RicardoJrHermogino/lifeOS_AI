import { getSession } from "@/services/better-auth/auth-server"

type Moment = { time: string; text: string }
type Memory = {
	id: string
	when: string
	tags: string[]
	title: string
	summary: string
	mood: string
}
type Stat = { icon: string; value: string; label: string }

const MOMENTS: Moment[] = [
	{ time: "10:20 AM", text: "Defined MVP scope — voice capture about documentation planning" },
	{ time: "2:35 PM", text: "Felt momentum — text note about user stories" },
	{ time: "8:10 PM", text: "Noticed stress — reflection mentioning pressure and fatigue" },
]

const MEMORIES: Memory[] = [
	{
		id: "memory-1",
		when: "Today · 8:10 PM",
		tags: ["Stress", "Work"],
		title: "Pressure around execution timelines",
		summary:
			"Felt overwhelmed by the number of open tasks and worried about hitting the MVP deadline.",
		mood: "😓 Stressed · Pressured",
	},
	{
		id: "memory-2",
		when: "Today · 2:35 PM",
		tags: ["Product"],
		title: "Momentum on user stories",
		summary:
			"Completed the user stories document and felt good about the level of detail in acceptance criteria.",
		mood: "⚡ Energized · Focused",
	},
	{
		id: "memory-3",
		when: "Today · 10:20 AM",
		tags: ["Planning"],
		title: "Defined MVP scope for LifeOS AI",
		summary:
			"Clarified what features belong in MVP vs V2. Decided to focus on capture, review, timeline, and daily reflection.",
		mood: "🎯 Focused · Determined",
	},
]

const STATS: Stat[] = [
	{ icon: "🧠", value: "47", label: "Total memories" },
	{ icon: "🔥", value: "6 days", label: "Current capture streak" },
	{ icon: "📅", value: "3", label: "Memories today" },
	{ icon: "⏳", value: "2", label: "Pending review" },
]

function formatGreetingDate() {
	return new Date().toLocaleDateString("en-US", {
		weekday: "long",
		year: "numeric",
		month: "long",
		day: "numeric",
	})
}

export default async function DashboardPage() {
	const session = await getSession()
	const firstName = session?.user?.name?.split(/\s+/)[0] ?? "there"

	return (
		<div className="flex flex-col gap-8 p-6 md:p-10">
			<header className="flex flex-wrap items-start justify-between gap-4">
				<div>
					<h2 className="text-2xl font-extrabold tracking-tight md:text-3xl">
						Good morning, {firstName} 👋
					</h2>
					<p className="text-muted-foreground mt-1 text-sm">
						{formatGreetingDate()} · 3 memories captured today
					</p>
				</div>
				<button
					type="button"
					data-element-id="quick-capture-btn"
					className="bg-primary text-primary-foreground inline-flex items-center gap-2 rounded-full px-5 py-2.5 text-sm font-bold"
				>
					🎙️ New capture
				</button>
			</header>

			<section className="border-border bg-card text-card-foreground flex flex-wrap items-center gap-4 rounded-3xl border p-5">
				<input
					data-element-id="quick-text-input"
					className="placeholder:text-muted-foreground flex-1 border-none bg-transparent text-base outline-none"
					placeholder="What's on your mind? Type a quick thought..."
				/>
				<div className="flex gap-2">
					<button
						type="button"
						data-element-id="voice-capture-btn"
						className="bg-primary/15 border-primary/30 text-primary-foreground rounded-full border px-4 py-2 text-xs font-semibold"
					>
						<span className="text-foreground">🎙️ Voice</span>
					</button>
					<button
						type="button"
						data-element-id="text-save-btn"
						className="border-border bg-background text-foreground rounded-full border px-4 py-2 text-xs font-semibold"
					>
						Save
					</button>
				</div>
			</section>

			<div className="grid grid-cols-1 gap-6 lg:grid-cols-[1fr_340px]">
				<div className="flex flex-col gap-6">
					<section className="bg-foreground text-background flex flex-col gap-4 rounded-[1.75rem] p-7">
						<div className="text-primary text-xs font-bold tracking-widest uppercase">
							Today&apos;s reflection
						</div>
						<div className="text-lg leading-snug font-bold">
							&quot;A focused but emotionally heavy day&quot;
						</div>
						<div className="text-background/70 text-sm leading-relaxed">
							Today centered on product planning and personal reflection. You seemed energized while
							clarifying the LifeOS AI MVP, but later entries suggested stress around execution
							timelines.
						</div>
						<div className="mt-1 flex flex-col gap-2">
							{MOMENTS.map(m => (
								<div key={m.time} className="flex items-start gap-3">
									<span className="text-primary pt-0.5 text-xs font-semibold whitespace-nowrap">
										{m.time}
									</span>
									<span className="text-background/60 text-sm leading-snug">{m.text}</span>
								</div>
							))}
						</div>
						<div className="mt-2 flex flex-wrap gap-2">
							<button
								type="button"
								data-element-id="reflection-helpful"
								className="bg-primary text-primary-foreground border-primary rounded-full border px-4 py-1.5 text-xs font-semibold"
							>
								👍 Helpful
							</button>
							<button
								type="button"
								data-element-id="reflection-inaccurate"
								className="border-background/15 bg-background/5 text-background/70 rounded-full border px-4 py-1.5 text-xs font-semibold"
							>
								Not accurate
							</button>
							<button
								type="button"
								data-element-id="reflection-save"
								className="border-background/15 bg-background/5 text-background/70 rounded-full border px-4 py-1.5 text-xs font-semibold"
							>
								Save
							</button>
						</div>
					</section>

					<section>
						<div className="mb-3 flex items-center justify-between">
							<span className="text-base font-bold">Recent memories</span>
							<a
								href="#"
								data-element-id="view-all-timeline"
								className="text-primary text-sm font-semibold"
							>
								View timeline →
							</a>
						</div>
						<div className="flex flex-col gap-3">
							{MEMORIES.map(m => (
								<button
									key={m.id}
									type="button"
									data-element-id={m.id}
									className="border-border bg-card text-card-foreground hover:border-primary/40 hover:bg-card/80 flex flex-col gap-1.5 rounded-2xl border p-5 text-left"
								>
									<div className="flex flex-wrap items-center gap-2">
										<span className="text-muted-foreground text-xs">{m.when}</span>
										{m.tags.map(t => (
											<span
												key={t}
												className="bg-primary/20 text-foreground rounded-full px-2.5 py-0.5 text-[10px] font-semibold"
											>
												{t}
											</span>
										))}
									</div>
									<div className="text-sm font-bold">{m.title}</div>
									<div className="text-muted-foreground text-xs leading-relaxed">{m.summary}</div>
									<div className="text-muted-foreground mt-0.5 text-xs">{m.mood}</div>
								</button>
							))}
						</div>
					</section>
				</div>

				<aside className="flex flex-col gap-3">
					<div className="text-muted-foreground mb-0 text-xs font-bold tracking-widest uppercase">
						Your memory
					</div>
					{STATS.map(s => (
						<div
							key={s.label}
							className="border-border bg-card text-card-foreground flex items-center gap-3 rounded-2xl border p-4"
						>
							<div className="bg-primary/15 flex size-9 shrink-0 items-center justify-center rounded-xl text-base">
								<span aria-hidden>{s.icon}</span>
							</div>
							<div className="flex flex-col">
								<span className="text-lg font-extrabold">{s.value}</span>
								<span className="text-muted-foreground text-xs">{s.label}</span>
							</div>
						</div>
					))}

					<div className="bg-primary/15 border-primary/30 mt-2 flex flex-col gap-3 rounded-2xl border p-5">
						<div className="text-foreground text-xs font-bold">Ask your memories</div>
						<input
							data-element-id="ask-input"
							placeholder="Why was I stressed last week?"
							className="border-primary/30 bg-background text-foreground placeholder:text-muted-foreground rounded-2xl border-2 px-4 py-2.5 text-sm outline-none"
						/>
						<button
							type="button"
							data-element-id="ask-submit"
							className="bg-primary text-primary-foreground rounded-full px-4 py-2.5 text-xs font-bold"
						>
							Ask →
						</button>
					</div>
				</aside>
			</div>
		</div>
	)
}
