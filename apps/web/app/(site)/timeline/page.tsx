"use client"

import { useState } from "react"

import { useTimeline, type TimelineFilters } from "@/features/timeline/api/timeline.hooks"

export default function TimelinePage() {
	const [filters, setFilters] = useState<TimelineFilters>({})
	const { data, isLoading, isError, error } = useTimeline(filters)

	const setFilter = (k: keyof TimelineFilters, v: string) =>
		setFilters(prev => ({ ...prev, [k]: v || undefined }))

	const clearFilters = () => setFilters({})

	return (
		<div className="flex flex-col gap-6 p-6 md:p-10">
			<header>
				<h2 className="text-2xl font-extrabold tracking-tight md:text-3xl">Timeline</h2>
				<p className="text-muted-foreground mt-1 text-sm">Browse your saved memories chronologically.</p>
			</header>

			<section className="border-border bg-card grid grid-cols-2 gap-3 rounded-2xl border p-4 md:grid-cols-5">
				<FilterField
					label="Mood"
					value={filters.mood ?? ""}
					onChange={v => setFilter("mood", v)}
				/>
				<FilterField
					label="Person"
					value={filters.person ?? ""}
					onChange={v => setFilter("person", v)}
				/>
				<FilterField
					label="Topic"
					value={filters.topic ?? ""}
					onChange={v => setFilter("topic", v)}
				/>
				<FilterField
					label="From"
					type="date"
					value={filters.from ?? ""}
					onChange={v => setFilter("from", v)}
				/>
				<FilterField
					label="To"
					type="date"
					value={filters.to ?? ""}
					onChange={v => setFilter("to", v)}
				/>
			</section>

			{Object.values(filters).some(v => v) && (
				<div className="flex flex-wrap items-center gap-2">
					{Object.entries(filters).map(([k, v]) =>
						v ? (
							<span
								key={k}
								className="bg-primary/15 text-foreground rounded-full px-3 py-1 text-xs"
							>
								{k}: {v}
							</span>
						) : null
					)}
					<button
						type="button"
						onClick={clearFilters}
						className="text-muted-foreground text-xs underline"
					>
						Clear
					</button>
				</div>
			)}

			{isLoading && <div className="text-muted-foreground text-sm">Loading…</div>}
			{isError && (
				<div className="bg-destructive/10 text-destructive rounded-2xl p-4 text-sm">
					{(error as Error).message}
				</div>
			)}

			{!isLoading && (data?.groups ?? []).length === 0 && (
				<div className="text-muted-foreground rounded-2xl border p-8 text-center text-sm">
					No memories match your filters yet.
				</div>
			)}

			<div className="flex flex-col gap-6">
				{(data?.groups ?? []).map(group => (
					<section key={group.date}>
						<h3 className="text-muted-foreground mb-3 text-sm font-bold tracking-wider uppercase">
							{new Date(group.date).toLocaleDateString(undefined, {
								weekday: "long",
								year: "numeric",
								month: "long",
								day: "numeric",
							})}
						</h3>
						<div className="flex flex-col gap-3">
							{group.memories.map(m => (
								<div
									key={m.id}
									className="border-border bg-card rounded-2xl border p-5"
								>
									<div className="flex flex-wrap items-center gap-2">
										<span className="text-muted-foreground text-xs">
											{new Date(m.eventDate).toLocaleTimeString()}
										</span>
										{m.topics.slice(0, 3).map(t => (
											<span
												key={t}
												className="bg-primary/20 text-foreground rounded-full px-2.5 py-0.5 text-[10px] font-semibold"
											>
												{t}
											</span>
										))}
									</div>
									<div className="mt-1 text-sm font-bold">{m.title}</div>
									<div className="text-muted-foreground mt-1 text-xs leading-relaxed">
										{m.summary}
									</div>
								</div>
							))}
						</div>
					</section>
				))}
			</div>
		</div>
	)
}

function FilterField({
	label,
	value,
	onChange,
	type = "text",
}: {
	label: string
	value: string
	onChange: (v: string) => void
	type?: string
}) {
	return (
		<label className="flex flex-col gap-1">
			<span className="text-muted-foreground text-xs font-semibold">{label}</span>
			<input
				type={type}
				value={value}
				onChange={e => onChange(e.target.value)}
				className="border-border bg-background rounded-lg border px-3 py-2 text-sm"
			/>
		</label>
	)
}
