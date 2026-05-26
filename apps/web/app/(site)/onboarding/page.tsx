"use client"

import { useRouter } from "next/navigation"
import { useState } from "react"

import { Button } from "@/core/components/ui/button"

const STEPS = [
	{
		title: "Your memories, your story",
		body: "LifeOS AI is a private, AI-powered memory layer. Capture thoughts, decisions, people, and feelings — by voice or text — and the AI organizes them into searchable memories you control.",
	},
	{
		title: "Your data is yours",
		body: "Every memory is private to your account. You can edit, archive, delete, or export everything at any time. AI processing happens on your captures only, never for training.",
	},
	{
		title: "Make your first capture",
		body: "Try it now: write a short note about something from your day. We'll turn it into a memory you can review and save.",
	},
]

export default function OnboardingPage() {
	const router = useRouter()
	const [step, setStep] = useState(0)
	const current = STEPS[step]
	const isLast = step === STEPS.length - 1

	if (!current) return null

	return (
		<div className="mx-auto flex min-h-screen max-w-xl flex-col justify-center p-8">
			<div className="bg-card rounded-3xl border p-8 shadow-xl">
				<div className="text-muted-foreground text-xs font-bold tracking-wider uppercase">
					Step {step + 1} of {STEPS.length}
				</div>
				<h1 className="mt-2 text-2xl font-extrabold tracking-tight">{current.title}</h1>
				<p className="text-foreground/80 mt-4 leading-relaxed">{current.body}</p>

				<div className="mt-8 flex items-center justify-between gap-3">
					<Button
						variant="ghost"
						disabled={step === 0}
						onClick={() => setStep(s => Math.max(0, s - 1))}
					>
						Back
					</Button>
					<Button
						onClick={() => {
							if (isLast) {
								router.push("/dashboard")
							} else {
								setStep(s => s + 1)
							}
						}}
					>
						{isLast ? "Make my first capture" : "Continue"}
					</Button>
				</div>
			</div>
		</div>
	)
}
