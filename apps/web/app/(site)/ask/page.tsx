"use client"

import { useSearchParams } from "next/navigation"
import { useEffect, useState } from "react"

import { useAsk } from "@/features/ask/api/ask.hooks"

export default function AskPage() {
	const params = useSearchParams()
	const initialQ = params.get("q") ?? ""
	const [question, setQuestion] = useState(initialQ)
	const ask = useAsk()

	useEffect(() => {
		if (initialQ) {
			ask.mutate(initialQ)
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [])

	const submit = () => {
		const q = question.trim()
		if (!q) return
		ask.mutate(q)
	}

	return (
		<div className="flex flex-col gap-6 p-6 md:p-10">
			<header>
				<h2 className="text-2xl font-extrabold tracking-tight md:text-3xl">Ask your memories</h2>
				<p className="text-muted-foreground mt-1 text-sm">
					Answers are grounded in your saved memories and cite their sources.
				</p>
			</header>

			<section className="border-border bg-card flex gap-2 rounded-2xl border p-3">
				<input
					value={question}
					onChange={e => setQuestion(e.target.value)}
					placeholder="Why was I stressed last week?"
					className="flex-1 bg-transparent px-2 text-sm outline-none"
					onKeyDown={e => {
						if (e.key === "Enter") {
							e.preventDefault()
							submit()
						}
					}}
				/>
				<button
					type="button"
					onClick={submit}
					disabled={ask.isPending || !question.trim()}
					className="bg-primary text-primary-foreground rounded-full px-4 py-2 text-xs font-bold disabled:opacity-50"
				>
					{ask.isPending ? "Thinking…" : "Ask"}
				</button>
			</section>

			{ask.isError && (
				<div className="bg-destructive/10 text-destructive rounded-2xl p-4 text-sm">
					{(ask.error as Error).message}
				</div>
			)}

			{ask.data && (
				<section className="border-border bg-card rounded-2xl border p-6">
					<div className="text-foreground/90 leading-relaxed whitespace-pre-line">
						{ask.data.answer}
					</div>
					{ask.data.citations.length > 0 && (
						<div className="mt-4 flex flex-col gap-2">
							<div className="text-muted-foreground text-xs font-bold tracking-wider uppercase">
								Sources
							</div>
							<div className="flex flex-wrap gap-2">
								{ask.data.citations.map(c => (
									<span
										key={c.memoryId}
										className="bg-primary/15 text-foreground rounded-full px-3 py-1 text-xs"
									>
										{c.title}
									</span>
								))}
							</div>
						</div>
					)}
				</section>
			)}
		</div>
	)
}
