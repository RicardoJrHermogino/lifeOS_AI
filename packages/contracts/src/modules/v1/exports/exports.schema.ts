import { z } from "zod"

const dateField = z
	.union([z.date(), z.string()])
	.transform(val => (typeof val === "string" ? new Date(val) : val))

export const ExportStatusSchema = z.enum(["pending", "ready", "failed"])

export const DataExportSchema = z.object({
	id: z.string().uuid(),
	userId: z.string(),
	status: ExportStatusSchema,
	downloadUrl: z.string().nullable(),
	expiresAt: dateField.nullable(),
	createdAt: dateField,
})

export const ExportIdSchema = z.object({
	id: z.string().uuid(),
})

export type DataExport = z.infer<typeof DataExportSchema>
