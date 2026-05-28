import { z } from "zod"

const dateField = z
	.union([z.date(), z.string()])
	.transform(val => (typeof val === "string" ? new Date(val) : val))

export const ReflectionToneSchema = z.enum(["neutral", "warm", "direct"])

const reminderTimeField = z
	.string()
	.regex(/^([01]\d|2[0-3]):[0-5]\d$/, "reminderTime must be HH:MM (24h)")

export const SettingsSchema = z.object({
	userId: z.string(),
	aiProcessingConsent: z.boolean(),
	aiPersonalization: z.boolean(),
	proactiveInsights: z.boolean(),
	reflectionTone: ReflectionToneSchema,
	sensitiveTopics: z.array(z.string()),
	dailyReminder: z.boolean(),
	reminderTime: reminderTimeField.nullable(),
	appLock: z.boolean(),
	createdAt: dateField,
	updatedAt: dateField,
})

export const UpdateSettingsSchema = z.object({
	aiProcessingConsent: z.boolean().optional(),
	aiPersonalization: z.boolean().optional(),
	proactiveInsights: z.boolean().optional(),
	reflectionTone: ReflectionToneSchema.optional(),
	sensitiveTopics: z.array(z.string().min(1).max(100)).max(50).optional(),
	dailyReminder: z.boolean().optional(),
	reminderTime: reminderTimeField.nullable().optional(),
	appLock: z.boolean().optional(),
})

export type Settings = z.infer<typeof SettingsSchema>
export type UpdateSettings = z.infer<typeof UpdateSettingsSchema>
