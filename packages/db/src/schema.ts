import { defineRelations } from "drizzle-orm"
import { customType, index, primaryKey } from "drizzle-orm/pg-core"

import { createTable } from "./utils/table.js"

// ============================================================================
// CUSTOM TYPES
// ============================================================================

/**
 * pgvector column type for semantic embeddings.
 * Requires the pgvector extension: CREATE EXTENSION IF NOT EXISTS vector;
 */
const vector = customType<{ data: number[]; driverData: string; config: { dimensions: number } }>({
	dataType(config) {
		return `vector(${config?.dimensions ?? 1536})`
	},
	toDriver(value: number[]): string {
		return `[${value.join(",")}]`
	},
	fromDriver(value: string): number[] {
		return value
			.slice(1, -1)
			.split(",")
			.map(v => Number(v))
	},
})

// ============================================================================
// BETTER AUTH TABLES
// ============================================================================

export const users = createTable("users", t => ({
	id: t.text("id").primaryKey(),
	name: t.text("name").notNull(),
	email: t.text("email").notNull().unique(),
	emailVerified: t.boolean("email_verified").default(false).notNull(),
	image: t.text("image"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const sessions = createTable("sessions", t => ({
	id: t.text("id").primaryKey(),
	token: t.text("token").notNull().unique(),
	userId: t
		.text("user_id")
		.notNull()
		.references(() => users.id, { onDelete: "cascade" }),
	expiresAt: t.timestamp("expires_at").notNull(),
	ipAddress: t.text("ip_address"),
	userAgent: t.text("user_agent"),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

export const accounts = createTable(
	"accounts",
	t => ({
		id: t.text("id"),
		accountId: t.text("account_id").notNull(),
		providerId: t.text("provider_id").notNull(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		accessToken: t.text("access_token"),
		refreshToken: t.text("refresh_token"),
		idToken: t.text("id_token"),
		accessTokenExpiresAt: t.timestamp("access_token_expires_at"),
		refreshTokenExpiresAt: t.timestamp("refresh_token_expires_at"),
		scope: t.text("scope"),
		password: t.text("password"), // For email/password auth
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		// Composite primary key on provider and account
		primaryKey({ columns: [t.providerId, t.accountId] }),
		index("account_user_id_idx").on(t.userId),
	]
)

export const verifications = createTable(
	"verifications",
	t => ({
		id: t.text("id"),
		identifier: t.text("identifier").notNull(),
		value: t.text("value").notNull(),
		expiresAt: t.timestamp("expires_at").notNull(),
		createdAt: t.timestamp("created_at").defaultNow(),
		updatedAt: t.timestamp("updated_at").defaultNow(),
	}),
	t => [
		// Composite primary key on identifier and value
		primaryKey({ columns: [t.identifier, t.value] }),
	]
)

// ============================================================================
// TODOs
// ============================================================================

export const todos = createTable("todos", t => ({
	id: t.serial("id").primaryKey(),
	title: t.text("title").notNull(),
	completed: t.boolean("completed").notNull().default(false),
	authorId: t
		.text("author_id")
		.notNull()
		.references(() => users.id, { onDelete: "cascade" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// TICKETS
// ============================================================================

export const tickets = createTable("tickets", t => ({
	id: t.serial("id").primaryKey(),
	name: t.text("name").notNull(),
	email: t.text("email").notNull(),
	subject: t.text("subject").notNull(),
	priority: t
		.text("priority")
		.notNull()
		.default("medium")
		.$type<"low" | "medium" | "high" | "urgent">(),
	concern: t.text("concern").notNull(),
	status: t
		.text("status")
		.notNull()
		.default("received")
		.$type<"received" | "in_progress" | "resolved" | "closed">(),
	authorId: t.text("author_id").references(() => users.id, { onDelete: "set null" }),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// LIFEOS — RAW CAPTURES
// ============================================================================

export const rawCaptures = createTable(
	"raw_captures",
	t => ({
		id: t.uuid("id").primaryKey().defaultRandom(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		type: t.text("type").notNull().$type<"voice" | "text">(),
		body: t.text("body"),
		audioUrl: t.text("audio_url"),
		transcript: t.text("transcript"),
		transcriptCorrected: t.boolean("transcript_corrected").notNull().default(false),
		mood: t.text("mood"),
		status: t
			.text("status")
			.notNull()
			.default("pending")
			.$type<"pending" | "transcribing" | "extracting" | "done" | "failed">(),
		syncId: t.text("sync_id"),
		capturedAt: t.timestamp("captured_at").notNull().defaultNow(),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		index("raw_captures_user_id_idx").on(t.userId),
		index("raw_captures_status_idx").on(t.status),
		index("raw_captures_sync_id_idx").on(t.syncId),
	]
)

// ============================================================================
// LIFEOS — MEMORIES
// ============================================================================

export const memories = createTable(
	"memories",
	t => ({
		id: t.uuid("id").primaryKey().defaultRandom(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		rawCaptureId: t.uuid("raw_capture_id").references(() => rawCaptures.id, {
			onDelete: "set null",
		}),
		title: t.text("title").notNull(),
		summary: t.text("summary").notNull(),
		eventDate: t.timestamp("event_date").notNull(),
		emotions: t.jsonb("emotions").$type<string[]>().notNull().default([]),
		people: t.jsonb("people").$type<string[]>().notNull().default([]),
		places: t.jsonb("places").$type<string[]>().notNull().default([]),
		topics: t.jsonb("topics").$type<string[]>().notNull().default([]),
		goals: t.jsonb("goals").$type<string[]>().notNull().default([]),
		decisions: t.jsonb("decisions").$type<string[]>().notNull().default([]),
		actions: t.jsonb("actions").$type<string[]>().notNull().default([]),
		sensitivity: t.text("sensitivity"),
		confidence: t.jsonb("confidence").$type<Record<string, number>>().notNull().default({}),
		status: t
			.text("status")
			.notNull()
			.default("candidate")
			.$type<"candidate" | "saved" | "archived" | "deleted">(),
		isUserCorrected: t.boolean("is_user_corrected").notNull().default(false),
		embedding: vector("embedding", { dimensions: 1536 }),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		index("memories_user_id_idx").on(t.userId),
		index("memories_status_idx").on(t.status),
		index("memories_event_date_idx").on(t.eventDate),
		index("memories_raw_capture_id_idx").on(t.rawCaptureId),
	]
)

// ============================================================================
// LIFEOS — REFLECTIONS
// ============================================================================

export const reflections = createTable(
	"reflections",
	t => ({
		id: t.uuid("id").primaryKey().defaultRandom(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		date: t.date("date").notNull(),
		content: t.text("content").notNull(),
		sourceMemoryIds: t.jsonb("source_memory_ids").$type<string[]>().notNull().default([]),
		isUserEdited: t.boolean("is_user_edited").notNull().default(false),
		feedback: t.text("feedback").$type<"helpful" | "inaccurate" | null>(),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		index("reflections_user_id_idx").on(t.userId),
		index("reflections_user_date_idx").on(t.userId, t.date),
	]
)

// ============================================================================
// LIFEOS — DATA EXPORTS
// ============================================================================

export const dataExports = createTable(
	"data_exports",
	t => ({
		id: t.uuid("id").primaryKey().defaultRandom(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		status: t
			.text("status")
			.notNull()
			.default("pending")
			.$type<"pending" | "ready" | "failed">(),
		downloadUrl: t.text("download_url"),
		expiresAt: t.timestamp("expires_at"),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
	}),
	t => [index("data_exports_user_id_idx").on(t.userId)]
)

// ============================================================================
// LIFEOS — INSIGHTS
// ============================================================================

export const insights = createTable(
	"insights",
	t => ({
		id: t.uuid("id").primaryKey().defaultRandom(),
		userId: t
			.text("user_id")
			.notNull()
			.references(() => users.id, { onDelete: "cascade" }),
		type: t.text("type").notNull(), // e.g. "pattern", "theme", "goal_progress"
		title: t.text("title").notNull(),
		body: t.text("body").notNull(),
		sourceMemoryIds: t.jsonb("source_memory_ids").$type<string[]>().notNull().default([]),
		evidence: t
			.text("evidence")
			.notNull()
			.default("moderate")
			.$type<"weak" | "moderate" | "strong">(),
		status: t
			.text("status")
			.notNull()
			.default("active")
			.$type<"active" | "saved" | "dismissed" | "deleted">(),
		feedback: t.text("feedback").$type<"helpful" | "not_helpful" | "wrong" | null>(),
		createdAt: t.timestamp("created_at").notNull().defaultNow(),
		updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
	}),
	t => [
		index("insights_user_id_idx").on(t.userId),
		index("insights_status_idx").on(t.status),
	]
)

// ============================================================================
// LIFEOS — USER SETTINGS
// ============================================================================

export const userSettings = createTable("user_settings", t => ({
	userId: t
		.text("user_id")
		.primaryKey()
		.references(() => users.id, { onDelete: "cascade" }),
	// Consent + AI behavior
	aiProcessingConsent: t.boolean("ai_processing_consent").notNull().default(true),
	aiPersonalization: t.boolean("ai_personalization").notNull().default(true),
	proactiveInsights: t.boolean("proactive_insights").notNull().default(false),
	reflectionTone: t
		.text("reflection_tone")
		.notNull()
		.default("warm")
		.$type<"neutral" | "warm" | "direct">(),
	sensitiveTopics: t.jsonb("sensitive_topics").$type<string[]>().notNull().default([]),
	// Reminders + security
	dailyReminder: t.boolean("daily_reminder").notNull().default(false),
	reminderTime: t.text("reminder_time"), // HH:MM, 24h
	appLock: t.boolean("app_lock").notNull().default(false),
	createdAt: t.timestamp("created_at").notNull().defaultNow(),
	updatedAt: t.timestamp("updated_at").notNull().defaultNow(),
}))

// ============================================================================
// RELATIONS
// ============================================================================
export const relations = defineRelations(
	{
		users,
		sessions,
		accounts,
		todos,
		tickets,
		rawCaptures,
		memories,
		reflections,
		dataExports,
		userSettings,
		insights,
	},
	r => ({
		users: {
			sessions: r.many.sessions(),
			accounts: r.many.accounts(),
			rawCaptures: r.many.rawCaptures(),
			memories: r.many.memories(),
			reflections: r.many.reflections(),
			dataExports: r.many.dataExports(),
			insights: r.many.insights(),
			settings: r.one.userSettings({
				from: r.users.id,
				to: r.userSettings.userId,
			}),
		},
		sessions: {
			user: r.one.users({
				from: r.sessions.userId,
				to: r.users.id,
			}),
		},
		accounts: {
			user: r.one.users({
				from: r.accounts.userId,
				to: r.users.id,
			}),
		},
		todos: {
			author: r.one.users({
				from: r.todos.authorId,
				to: r.users.id,
			}),
		},
		tickets: {
			author: r.one.users({
				from: r.tickets.authorId,
				to: r.users.id,
			}),
		},
		rawCaptures: {
			user: r.one.users({
				from: r.rawCaptures.userId,
				to: r.users.id,
			}),
			memories: r.many.memories(),
		},
		memories: {
			user: r.one.users({
				from: r.memories.userId,
				to: r.users.id,
			}),
			rawCapture: r.one.rawCaptures({
				from: r.memories.rawCaptureId,
				to: r.rawCaptures.id,
			}),
		},
		reflections: {
			user: r.one.users({
				from: r.reflections.userId,
				to: r.users.id,
			}),
		},
		dataExports: {
			user: r.one.users({
				from: r.dataExports.userId,
				to: r.users.id,
			}),
		},
		userSettings: {
			user: r.one.users({
				from: r.userSettings.userId,
				to: r.users.id,
			}),
		},
		insights: {
			user: r.one.users({
				from: r.insights.userId,
				to: r.users.id,
			}),
		},
	})
)

// ============================================================================
// SCHEMA
// ============================================================================
export const schema = Object.assign(
	{
		users,
		sessions,
		accounts,
		verifications,
		todos,
		tickets,
		rawCaptures,
		memories,
		reflections,
		dataExports,
		userSettings,
		insights,
	},
	relations
)
