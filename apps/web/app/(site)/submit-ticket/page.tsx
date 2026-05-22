"use client"

import { useState } from "react"

import { Button } from "@/core/components/ui/button"
import { Field, FieldGroup, FieldLabel } from "@/core/components/ui/field"
import { Input } from "@/core/components/ui/input"
import { Textarea } from "@/core/components/ui/textarea"
import { cn } from "@/core/lib/utils"

type FormState = "idle" | "submitting" | "success" | "error"

type IssueType = {
	id: string
	label: string
	elementId: string
}

const ISSUE_TYPES = [
	{ id: "inaccurate", label: "Inaccurate AI", elementId: "issue-inaccurate" },
	{ id: "harmful", label: "Harmful content", elementId: "issue-harmful" },
	{ id: "personal", label: "Too personal", elementId: "issue-personal" },
	{ id: "missing", label: "Missing context", elementId: "issue-missing" },
	{ id: "wrong-source", label: "Wrong source", elementId: "issue-wrong-source" },
	{ id: "other", label: "Other", elementId: "issue-other" },
] as const satisfies readonly IssueType[]

const DEFAULT_ISSUE = ISSUE_TYPES[0].id

export default function SubmitTicketPage() {
	const [state, setState] = useState<FormState>("idle")
	const [selectedIssue, setSelectedIssue] = useState<string>(DEFAULT_ISSUE)

	return (
		<section className="flex w-full max-w-3xl flex-col gap-8 p-6 md:p-10">
			<header>
				<h1 className="text-2xl font-extrabold tracking-tight md:text-3xl">
					Submit a support ticket
				</h1>
				<p className="text-muted-foreground mt-1 text-sm">
					Report a problem with AI output, a bug, or anything else. We&apos;ll get back to you.
				</p>
			</header>

			<form
				onSubmit={async event => {
					event.preventDefault()
					const formData = new FormData(event.currentTarget)
					setState("submitting")
					try {
						const payload = {
							...Object.fromEntries(formData.entries()),
							issueType: selectedIssue,
						}
						await new Promise(resolve => setTimeout(resolve, 800))
						void payload
						setState("success")
						event.currentTarget.reset()
						setSelectedIssue(DEFAULT_ISSUE)
					} catch {
						setState("error")
					}
				}}
				className="border-border bg-card text-card-foreground rounded-[1.75rem] border p-8"
			>
				<FieldGroup className="gap-5">
					<Field>
						<FieldLabel>Issue type</FieldLabel>
						<div className="grid grid-cols-2 gap-2 md:grid-cols-3">
							{ISSUE_TYPES.map(t => {
								const isSelected = selectedIssue === t.id
								return (
									<button
										key={t.id}
										type="button"
										onClick={() => setSelectedIssue(t.id)}
										data-element-id={t.elementId}
										className={cn(
											"rounded-2xl border-2 px-3 py-2.5 text-xs font-semibold transition-colors",
											isSelected
												? "border-primary bg-primary/15 text-foreground"
												: "border-border bg-background text-muted-foreground hover:border-primary/40"
										)}
									>
										{t.label}
									</button>
								)
							})}
						</div>
					</Field>

					<Field>
						<FieldLabel htmlFor="subject">Subject</FieldLabel>
						<Input
							id="subject"
							name="subject"
							placeholder="Brief description of the issue"
							required
							data-element-id="ticket-subject"
						/>
					</Field>

					<Field>
						<FieldLabel htmlFor="description">Description</FieldLabel>
						<Textarea
							id="description"
							name="description"
							rows={6}
							placeholder="Describe what happened, what you expected, and any relevant context..."
							required
							data-element-id="ticket-description"
						/>
					</Field>

					<Field>
						<FieldLabel htmlFor="memory-ref">Related memory (optional)</FieldLabel>
						<Input
							id="memory-ref"
							name="memoryRef"
							placeholder="Paste a memory title or ID if relevant"
							data-element-id="ticket-memory-ref"
						/>
					</Field>

					<div className="bg-primary/15 border-primary/30 rounded-2xl border p-4 text-xs leading-relaxed">
						<strong className="font-bold">Privacy note:</strong> You control what&apos;s included in
						this report. Personal memory content is not automatically attached. Only share what
						you&apos;re comfortable with.
					</div>

					<Button
						type="submit"
						disabled={state === "submitting"}
						className="h-12 self-start rounded-full px-8 text-sm font-bold"
						data-element-id="ticket-submit"
					>
						{state === "submitting" ? "Submitting..." : "Submit ticket"}
					</Button>

					{state === "success" && (
						<p role="status" className="text-primary text-sm">
							Ticket submitted! Replace the placeholder handler to persist it.
						</p>
					)}
					{state === "error" && (
						<p role="status" className="text-destructive text-sm">
							Something went wrong. Please try again.
						</p>
					)}
				</FieldGroup>
			</form>
		</section>
	)
}
