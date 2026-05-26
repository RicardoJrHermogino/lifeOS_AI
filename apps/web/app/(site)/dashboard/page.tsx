"use client"

import Link from "next/link"
import { useRouter } from "next/navigation"
import { useState } from "react"

import { useAsk } from "@/features/ask/api/ask.hooks"
import { useCapture, useCreateCapture } from "@/features/captures/api/captures.hooks"
import { useMemoryCandidates } from "@/features/memories/api/memories.hooks"
import { useReflection, useReflectionFeedback } from "@/features/reflections/api/reflections.hooks"
import { useTimeline } from "@/features/timeline/api/timeline.hooks"

function formatGreetingDate() {
	return new Date().toLocaleDateString("en-US", {
		weekday: "long",
		year: "numeric",
		month: "long",
		day: "numeric",
	})
}

function todayIso(): string {
	return new Date().toISOString().slice(0, 10)
}

export default function DashboardPage() {
	const router = useRouter()
	const [text, setText] = useState("")
	const [askText, setAskText] = useState("")
	const [pollId, setPollId] = useState<string | null>(null)

	const createCapture = useCreateCapture()
	const captureStatus = useCapture(pollId, {
		refetchInterval: pollId ? 2000 : undefined,
	})
	const candidates = useMemoryCandidates()
	const timeline = useTimeline({ limit: 3 })
	const reflection = useReflection(todayIso())
	const feedback = useReflectionFeedback()
	const ask = useAsk()

	const recent = (timeline.data?.groups ?? []).flatMap(g => g.memories).slice(0, 3)
	const pendingCount = candidates.data?.items.length ?? 0

	const handleSave = async () => {
		const body = text.trim()
		if (!body) return
		const result = await createCapture.mutateAsync({ type: "text", body })
		setPollId(result.id)
		setText("")
	}

	const handleAsk = async () => {
		const q = askText.trim()
		if (!q) return
		router.push(`/ask?q=${encodeURIComponent(q)}`)
	}

	const processingState =
		captureStatus.data?.status &&
		captureStatus.data.status !== "done" &&
		captureStatus.data.status !== "failed"

	return (
		<div className="flex flex-col gap-8 p-6 md:p-10">
			<header className="flex flex-wrap items-start justify-between gap-4">
				<div>
					<h2 className="text-2xl font-extrabold tracking-tight md:text-3xl">
						Welcome back 👋
					</h2>
					<p className="text-muted-foreground mt-1 text-sm">
						{formatGreetingDate()} · {recent.length} recent memories
					</p>
				</div>
				<Link
					href="/review"
					data-element-id="quick-capture-btn"
					className="bg-primary text-primary-foreground inline-flex items-center gap-2 rounded-full px-5 py-2.5 text-sm font-bold"
				>
					🎙️ Review queue ({pendingCount})
				</Link>
			</header>

			<section className="border-border bg-card text-card-foreground flex flex-wrap items-center gap-4 rounded-3xl border p-5">
				<input
					data-element-id="quick-text-input"
					className="placeholder:text-muted-foreground flex-1 border-none bg-transparent text-base outline-none"
					placeholder="What's on your mind? Type a quick thought..."
					value={text}
					onChange={e => setText(e.target.value)}
					onKeyDown={e => {
						if (e.key === "Enter" && !e.shiftKey) {
							e.preventDefault()
							void handleSave()
						}
					}}
					disabled={createCapture.isPending}
				/>
				<div className="flex gap-2">
					<button
						type="button"
						data-element-id="text-save-btn"
						onClick={handleSave}
						disabled={createCapture.isPending || !text.trim()}
						className="bg-primary text-primary-foreground rounded-full px-4 py-2 text-xs font-semibold disabled:opacity-50"
					>
						{createCapture.isPending ? "Saving..." : "Save"}
					</button>
				</div>
			</section>

			{pollId && (
				<div className="border-primary/30 bg-primary/10 text-foreground rounded-2xl border px-4 py-3 text-sm">
					{processingState ? (
						<>Processing capture ({captureStatus.data?.status})…</>
					) : captureStatus.data?.status === "done" ? (
						<>
							Capture ready.{" "}
							<Link href="/review" className="text-primary font-semibold">
								Review memory →
							</Link>
						</>
					) : captureStatus.data?.status === "failed" ? (
						<>Capture failed. Please try again.</>
					) : (
						<>Saved.</>
					)}
				</div>
			)}

			{createCapture.isError && (
				<div className="bg-destructive/10 text-destructive rounded-2xl p-3 text-sm">
					{(createCapture.error as Error)?.message ?? "Failed to save capture"}
				</div>
			)}

			<div className="grid grid-cols-1 gap-6 lg:grid-cols-[1fr_340px]">
				<div className="flex flex-col gap-6">
					<section className="bg-foreground text-background flex flex-col gap-4 rounded-[1.75rem] p-7">
						<div className="text-primary text-xs font-bold tracking-widest uppercase">
							Today&apos;s reflection
						</div>
						{reflection.isLoading ? (
							<div className="text-background/70 text-sm">Loading reflection…</div>
						) : reflection.isError ? (
							<div className="text-background/70 text-sm">
								Couldn&apos;t load today&apos;s reflection.
							</div>
						) : reflection.data ? (
							<>
								<div className="text-background/85 text-sm leading-relaxed whitespace-pre-line">
									{reflection.data.content}
								</div>
								<div className="mt-2 flex flex-wrap gap-2">
									<button
										type="button"
										data-element-id="reflection-helpful"
										onClick={() =>
											feedback.mutate({ id: reflection.data!.id, feedback: "helpful" })
										}
										className="bg-primary text-primary-foreground rounded-full px-4 py-1.5 text-xs font-semibold"
									>
										👍 Helpful
									</button>
									<button
										type="button"
										data-element-id="reflection-inaccurate"
										onClick={() =>
											feedback.mutate({ id: reflection.data!.id, feedback: "inaccurate" })
										}
										className="border-background/15 bg-background/5 text-background/70 rounded-full border px-4 py-1.5 text-xs font-semibold"
									>
										Not accurate
									</button>
								</div>
							</>
						) : (
							<div className="text-background/70 text-sm">
								No reflection yet. Capture a few memories today to generate one.
							</div>
						)}
					</section>

					<section>
						<div className="mb-3 flex items-center justify-between">
							<span className="text-base font-bold">Recent memories</span>
							<Link
								href="/timeline"
								data-element-id="view-all-timeline"
								className="text-primary text-sm font-semibold"
							>
								View timeline →
							</Link>
						</div>
						<div className="flex flex-col gap-3">
							{timeline.isLoading && (
								<div className="text-muted-foreground text-sm">Loading…</div>
							)}
							{!timeline.isLoading && recent.length === 0 && (
								<div className="text-muted-foreground text-sm">
									No saved memories yet. Capture a thought above to get started.
								</div>
							)}
							{recent.map(m => (
								<div
									key={m.id}
									data-element-id={`memory-${m.id}`}
									className="border-border bg-card text-card-foreground hover:border-primary/40 flex flex-col gap-1.5 rounded-2xl border p-5"
								>
									<div className="flex flex-wrap items-center gap-2">
										<span className="text-muted-foreground text-xs">
											{new Date(m.eventDate).toLocaleString()}
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
									<div className="text-sm font-bold">{m.title}</div>
									<div className="text-muted-foreground text-xs leading-relaxed">{m.summary}</div>
								</div>
							))}
						</div>
					</section>
				</div>

				<aside className="flex flex-col gap-3">
					<div className="text-muted-foreground mb-0 text-xs font-bold tracking-widest uppercase">
						Your memory
					</div>
					<StatCard icon="🧠" value={String(recent.length)} label="Recent memories" />
					<StatCard icon="⏳" value={String(pendingCount)} label="Pending review" />

					<div className="bg-primary/15 border-primary/30 mt-2 flex flex-col gap-3 rounded-2xl border p-5">
						<div className="text-foreground text-xs font-bold">Ask your memories</div>
						<input
							data-element-id="ask-input"
							value={askText}
							onChange={e => setAskText(e.target.value)}
							placeholder="Why was I stressed last week?"
							className="border-primary/30 bg-background text-foreground placeholder:text-muted-foreground rounded-2xl border-2 px-4 py-2.5 text-sm outline-none"
							onKeyDown={e => {
								if (e.key === "Enter") {
									e.preventDefault()
									void handleAsk()
								}
							}}
						/>
						<button
							type="button"
							data-element-id="ask-submit"
							onClick={handleAsk}
							disabled={ask.isPending || !askText.trim()}
							className="bg-primary text-primary-foreground rounded-full px-4 py-2.5 text-xs font-bold disabled:opacity-50"
						>
							Ask →
						</button>
					</div>
				</aside>
			</div>
		</div>
	)
}

function StatCard({ icon, value, label }: { icon: string; value: string; label: string }) {
	return (
		<div className="border-border bg-card text-card-foreground flex items-center gap-3 rounded-2xl border p-4">
			<div className="bg-primary/15 flex size-9 shrink-0 items-center justify-center rounded-xl text-base">
				<span aria-hidden>{icon}</span>
			</div>
			<div className="flex flex-col">
				<span className="text-lg font-extrabold">{value}</span>
				<span className="text-muted-foreground text-xs">{label}</span>
			</div>
		</div>
	)
}
