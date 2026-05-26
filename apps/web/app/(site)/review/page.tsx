"use client"

import { useState } from "react"

import {
	useArchiveMemory,
	useDeleteMemory,
	useMemoryCandidates,
	useUpdateMemory,
	type Memory,
} from "@/features/memories/api/memories.hooks"

export default function ReviewPage() {
	const candidates = useMemoryCandidates()

	if (candidates.isLoading) {
		return <PageShell><div className="text-muted-foreground text-sm">Loading…</div></PageShell>
	}
	if (candidates.isError) {
		return (
			<PageShell>
				<div className="bg-destructive/10 text-destructive rounded-2xl p-4 text-sm">
					Failed to load candidates: {(candidates.error as Error).message}
				</div>
			</PageShell>
		)
	}
	const items = candidates.data?.items ?? []
	if (items.length === 0) {
		return (
			<PageShell>
				<div className="text-muted-foreground rounded-2xl border p-8 text-center text-sm">
					No memory candidates to review. Capture a thought to get started.
				</div>
			</PageShell>
		)
	}
	return (
		<PageShell>
			<div className="flex flex-col gap-4">
				{items.map(m => (
					<CandidateCard key={m.id} memory={m} />
				))}
			</div>
		</PageShell>
	)
}

function PageShell({ children }: { children: React.ReactNode }) {
	return (
		<div className="flex flex-col gap-6 p-6 md:p-10">
			<header>
				<h2 className="text-2xl font-extrabold tracking-tight md:text-3xl">Memory review</h2>
				<p className="text-muted-foreground mt-1 text-sm">
					AI extracted these from your captures. Edit, save, archive, or delete.
				</p>
			</header>
			{children}
		</div>
	)
}

function CandidateCard({ memory }: { memory: Memory }) {
	const update = useUpdateMemory()
	const del = useDeleteMemory()
	const archive = useArchiveMemory()

	const [title, setTitle] = useState(memory.title)
	const [summary, setSummary] = useState(memory.summary)
	const [eventDate, setEventDate] = useState(memory.eventDate.slice(0, 16))
	const [topics, setTopics] = useState(memory.topics.join(", "))
	const [people, setPeople] = useState(memory.people.join(", "))
	const [places, setPlaces] = useState(memory.places.join(", "))
	const [emotions, setEmotions] = useState(memory.emotions.join(", "))

	const lowConfFields = Object.entries(memory.confidence)
		.filter(([, v]) => v < 0.6)
		.map(([k]) => k)

	const splitCsv = (s: string) =>
		s
			.split(",")
			.map(t => t.trim())
			.filter(Boolean)

	const handleSave = () => {
		update.mutate({
			id: memory.id,
			title,
			summary,
			eventDate: new Date(eventDate).toISOString(),
			topics: splitCsv(topics),
			people: splitCsv(people),
			places: splitCsv(places),
			emotions: splitCsv(emotions),
		})
	}

	return (
		<div className="border-border bg-card text-card-foreground flex flex-col gap-3 rounded-2xl border p-5">
			{memory.sensitivity && (
				<div className="bg-amber-500/15 text-amber-700 dark:text-amber-300 inline-block w-fit rounded-full px-3 py-1 text-xs font-semibold">
					Sensitive: {memory.sensitivity}
				</div>
			)}
			{lowConfFields.length > 0 && (
				<div className="text-muted-foreground text-xs">
					Low confidence on: {lowConfFields.join(", ")}
				</div>
			)}
			<label className="flex flex-col gap-1">
				<span className="text-xs font-semibold">Title</span>
				<input
					value={title}
					onChange={e => setTitle(e.target.value)}
					className="border-border rounded-lg border px-3 py-2 text-sm"
				/>
			</label>
			<label className="flex flex-col gap-1">
				<span className="text-xs font-semibold">Summary</span>
				<textarea
					value={summary}
					onChange={e => setSummary(e.target.value)}
					rows={3}
					className="border-border rounded-lg border px-3 py-2 text-sm"
				/>
			</label>
			<label className="flex flex-col gap-1">
				<span className="text-xs font-semibold">When</span>
				<input
					type="datetime-local"
					value={eventDate}
					onChange={e => setEventDate(e.target.value)}
					className="border-border rounded-lg border px-3 py-2 text-sm"
				/>
			</label>
			<div className="grid grid-cols-1 gap-3 md:grid-cols-2">
				<CsvField label="Topics" value={topics} onChange={setTopics} />
				<CsvField label="People" value={people} onChange={setPeople} />
				<CsvField label="Places" value={places} onChange={setPlaces} />
				<CsvField label="Emotions" value={emotions} onChange={setEmotions} />
			</div>
			<div className="flex flex-wrap gap-2 pt-2">
				<button
					type="button"
					onClick={handleSave}
					disabled={update.isPending}
					className="bg-primary text-primary-foreground rounded-full px-4 py-2 text-xs font-bold disabled:opacity-50"
				>
					{update.isPending ? "Saving…" : "Save memory"}
				</button>
				<button
					type="button"
					onClick={() => archive.mutate(memory.id)}
					className="border-border rounded-full border px-4 py-2 text-xs font-semibold"
				>
					Archive
				</button>
				<button
					type="button"
					onClick={() => del.mutate(memory.id)}
					className="text-destructive border-destructive/40 rounded-full border px-4 py-2 text-xs font-semibold"
				>
					Delete
				</button>
			</div>
		</div>
	)
}

function CsvField({
	label,
	value,
	onChange,
}: {
	label: string
	value: string
	onChange: (v: string) => void
}) {
	return (
		<label className="flex flex-col gap-1">
			<span className="text-xs font-semibold">{label}</span>
			<input
				value={value}
				onChange={e => onChange(e.target.value)}
				className="border-border rounded-lg border px-3 py-2 text-sm"
				placeholder="comma-separated"
			/>
		</label>
	)
}
