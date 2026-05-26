"use client"

import { useRouter } from "next/navigation"
import { useState } from "react"

import {
	useDeleteAccount,
	useExport,
	useRequestExport,
	type DataExport,
} from "@/features/exports/api/exports.hooks"
import { authClient } from "@/services/better-auth/auth-client"

export default function SettingsPage() {
	const router = useRouter()
	const requestExport = useRequestExport()
	const [exportId, setExportId] = useState<string | null>(null)
	const exportStatus = useExport(exportId)
	const del = useDeleteAccount()
	const [confirming, setConfirming] = useState(false)
	const [confirmText, setConfirmText] = useState("")

	const triggerExport = async () => {
		const result = await requestExport.mutateAsync()
		setExportId(result.id)
	}

	const triggerDelete = async () => {
		await del.mutateAsync()
		await authClient.signOut()
		router.push("/login")
		router.refresh()
	}

	const data: DataExport | undefined = exportStatus.data

	return (
		<div className="flex flex-col gap-6 p-6 md:p-10">
			<header>
				<h2 className="text-2xl font-extrabold tracking-tight md:text-3xl">Settings</h2>
				<p className="text-muted-foreground mt-1 text-sm">
					Manage your privacy, exports, and account.
				</p>
			</header>

			<section className="border-border bg-card flex flex-col gap-3 rounded-2xl border p-5">
				<h3 className="text-base font-bold">Export your data</h3>
				<p className="text-muted-foreground text-sm">
					Download a JSON archive of your account, captures, memories, and reflections.
				</p>
				<div>
					<button
						type="button"
						onClick={triggerExport}
						disabled={requestExport.isPending}
						className="bg-primary text-primary-foreground rounded-full px-4 py-2 text-xs font-bold disabled:opacity-50"
					>
						{requestExport.isPending ? "Requesting…" : "Request export"}
					</button>
				</div>
				{data && (
					<div className="border-border rounded-xl border p-3 text-sm">
						<div>Status: {data.status}</div>
						{data.status === "ready" && data.downloadUrl && (
							<a
								href={data.downloadUrl}
								download="lifeos-export.json"
								className="text-primary font-semibold underline"
							>
								Download
							</a>
						)}
						{data.status === "failed" && (
							<div className="text-destructive">Export failed. Please try again.</div>
						)}
					</div>
				)}
			</section>

			<section className="border-destructive/30 bg-destructive/5 flex flex-col gap-3 rounded-2xl border p-5">
				<h3 className="text-base font-bold">Delete account</h3>
				<p className="text-muted-foreground text-sm">
					Permanently deletes your account and all captures, memories, reflections, and exports. This
					cannot be undone.
				</p>
				{!confirming ? (
					<div>
						<button
							type="button"
							onClick={() => setConfirming(true)}
							className="text-destructive border-destructive/40 rounded-full border px-4 py-2 text-xs font-semibold"
						>
							Delete my account
						</button>
					</div>
				) : (
					<div className="flex flex-col gap-3">
						<label className="text-sm">
							Type <strong>DELETE</strong> to confirm:
						</label>
						<input
							value={confirmText}
							onChange={e => setConfirmText(e.target.value)}
							className="border-border rounded-lg border px-3 py-2 text-sm"
						/>
						<div className="flex gap-2">
							<button
								type="button"
								onClick={triggerDelete}
								disabled={confirmText !== "DELETE" || del.isPending}
								className="bg-destructive text-destructive-foreground rounded-full px-4 py-2 text-xs font-bold disabled:opacity-50"
							>
								{del.isPending ? "Deleting…" : "Confirm delete"}
							</button>
							<button
								type="button"
								onClick={() => {
									setConfirming(false)
									setConfirmText("")
								}}
								className="border-border rounded-full border px-4 py-2 text-xs font-semibold"
							>
								Cancel
							</button>
						</div>
					</div>
				)}
			</section>
		</div>
	)
}
