import "dotenv/config"

import { inArray, or } from "drizzle-orm"
import { drizzle } from "drizzle-orm/node-postgres"
import { randomBytes, randomUUID, scryptSync } from "node:crypto"
import { Pool } from "pg"

import {
	accounts,
	insights,
	memories,
	rawCaptures,
	reflections,
	schema,
	tickets,
	todos,
	users,
} from "./schema.js"

async function hashPassword(password: string): Promise<string> {
	const saltHex = randomBytes(16).toString("hex")
	const key = scryptSync(password.normalize("NFKC"), saltHex, 64, {
		N: 16384,
		r: 16,
		p: 1,
		maxmem: 128 * 16384 * 16 * 2,
	})

	return `${saltHex}:${key.toString("hex")}`
}

async function seedDatabase() {
	const connectionString = process.env.DATABASE_URL

	if (!connectionString) {
		throw new Error("DATABASE_URL environment variable is not set")
	}

	const pool = new Pool({ connectionString })
	const db = drizzle({ client: pool, schema })
	const now = new Date()
	const seedPassword = "password123"
	const hashedSeedPassword = await hashPassword(seedPassword)

	const seedUsers: Array<typeof users.$inferInsert> = [
		{
			id: "seed-user-admin",
			name: "Admin User",
			email: "admin@turbo-template.local",
			emailVerified: true,
			image: null,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-alex",
			name: "Alex Johnson",
			email: "alex@turbo-template.local",
			emailVerified: true,
			image: null,
			createdAt: now,
			updatedAt: now,
		},
		{
			id: "seed-user-sam",
			name: "Sam Rivera",
			email: "sam@turbo-template.local",
			emailVerified: false,
			image: null,
			createdAt: now,
			updatedAt: now,
		},
	]

	const seedTodos: Array<typeof todos.$inferInsert> = [
		{
			title: "Review onboarding checklist",
			completed: true,
			authorId: "seed-user-admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			title: "Verify backend health endpoint",
			completed: false,
			authorId: "seed-user-admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			title: "Connect mobile app to local API",
			completed: false,
			authorId: "seed-user-alex",
			createdAt: now,
			updatedAt: now,
		},
		{
			title: "Draft release notes for staging",
			completed: false,
			authorId: "seed-user-sam",
			createdAt: now,
			updatedAt: now,
		},
	]

	const seedTickets: Array<typeof tickets.$inferInsert> = [
		{
			name: "Admin User",
			email: "admin@turbo-template.local",
			subject: "Initial admin setup check",
			priority: "high" as const,
			concern: "Please verify seeded admin data appears correctly across the dashboard.",
			status: "in_progress" as const,
			authorId: "seed-user-admin",
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "Alex Johnson",
			email: "alex@turbo-template.local",
			subject: "Mobile API connectivity",
			priority: "medium" as const,
			concern: "Android emulator needs a stable local API URL during development.",
			status: "received" as const,
			authorId: "seed-user-alex",
			createdAt: now,
			updatedAt: now,
		},
		{
			name: "Guest Reporter",
			email: "guest@turbo-template.local",
			subject: "Public feedback sample",
			priority: "low" as const,
			concern: "This anonymous ticket exists to test support workflows without a linked account.",
			status: "received" as const,
			authorId: null,
			createdAt: now,
			updatedAt: now,
		},
	]

	// ── LifeOS sample data (attached to the "alex" demo user) ─────────────────
	const lifeosUserId = "seed-user-alex"
	const dayMs = 24 * 60 * 60 * 1000
	const todayDate = new Date(now)
	const yesterday = new Date(now.getTime() - dayMs)
	const twoDaysAgo = new Date(now.getTime() - 2 * dayMs)
	const todayStr = now.toISOString().slice(0, 10)

	const cap1Id = randomUUID()
	const cap2Id = randomUUID()
	const mem1Id = randomUUID()
	const mem2Id = randomUUID()
	const mem3Id = randomUUID()
	const candidateMemId = randomUUID()

	const seedCaptures: Array<typeof rawCaptures.$inferInsert> = [
		{
			id: cap1Id,
			userId: lifeosUserId,
			type: "text",
			body: "Clarified the MVP direction with the team. Decided to ship mobile-first and keep web minimal.",
			mood: "Focused",
			status: "done",
			capturedAt: twoDaysAgo,
			createdAt: twoDaysAgo,
			updatedAt: twoDaysAgo,
		},
		{
			id: cap2Id,
			userId: lifeosUserId,
			type: "text",
			body: "Felt some pressure about launch scope. Talked it through with Sam and set a clear cut line.",
			mood: "Stressed",
			status: "done",
			capturedAt: yesterday,
			createdAt: yesterday,
			updatedAt: yesterday,
		},
	]

	const seedMemories: Array<typeof memories.$inferInsert> = [
		{
			id: mem1Id,
			userId: lifeosUserId,
			rawCaptureId: cap1Id,
			title: "Clarified MVP direction",
			summary:
				"Aligned the team on a mobile-first MVP; web stays minimal until mobile is stable.",
			eventDate: twoDaysAgo,
			emotions: ["focused", "relieved"],
			people: ["Sam"],
			places: [],
			topics: ["product", "mvp", "strategy"],
			goals: ["ship mobile MVP"],
			decisions: ["mobile-first", "keep web minimal"],
			actions: ["draft mobile scope"],
			confidence: { title: 0.9, summary: 0.85 },
			status: "saved",
		},
		{
			id: mem2Id,
			userId: lifeosUserId,
			rawCaptureId: cap2Id,
			title: "Pressure around launch scope",
			summary:
				"Noticed launch-scope stress; agreed a cut line with Sam to protect the timeline.",
			eventDate: yesterday,
			emotions: ["stressed", "calmer"],
			people: ["Sam"],
			places: [],
			topics: ["launch", "scope", "wellbeing"],
			goals: ["protect timeline"],
			decisions: ["set scope cut line"],
			actions: ["communicate cut line"],
			confidence: { title: 0.8 },
			status: "saved",
		},
		{
			id: mem3Id,
			userId: lifeosUserId,
			title: "Morning focus block",
			summary:
				"Deep work session on the timeline feature; felt productive and clear.",
			eventDate: todayDate,
			emotions: ["focused", "productive"],
			people: [],
			places: ["home office"],
			topics: ["focus", "productivity", "timeline"],
			confidence: {},
			status: "saved",
		},
		{
			id: candidateMemId,
			userId: lifeosUserId,
			title: "Idea: weekly review ritual",
			summary:
				"Thinking about a weekly review ritual to reflect on captured memories.",
			eventDate: todayDate,
			emotions: ["curious"],
			topics: ["habits", "reflection"],
			goals: ["build weekly review habit"],
			confidence: { title: 0.55 },
			status: "candidate",
		},
	]

	const seedReflections: Array<typeof reflections.$inferInsert> = [
		{
			userId: lifeosUserId,
			date: todayStr,
			content:
				"Today blended focus and forward motion: a productive morning deep-work block on the timeline, building on this week's clearer MVP direction. The earlier launch-scope pressure has eased after setting a cut line with Sam.",
			sourceMemoryIds: [mem3Id, mem1Id],
		},
	]

	const seedInsights: Array<typeof insights.$inferInsert> = [
		{
			userId: lifeosUserId,
			type: "pattern",
			title: "Focus follows clarity",
			body: "Your most focused moments tend to follow a clear decision — settling the MVP direction and the scope cut line both preceded productive, focused work.",
			sourceMemoryIds: [mem1Id, mem2Id, mem3Id],
			evidence: "moderate",
			status: "active",
		},
	]

	const seededUserIds = seedUsers.map(user => user.id)
	const seededTicketEmails = seedTickets.map(ticket => ticket.email)
	const seedCredentialAccounts: Array<typeof accounts.$inferInsert> = seedUsers.map(user => ({
		providerId: "credential",
		accountId: user.id,
		userId: user.id,
		password: hashedSeedPassword,
		createdAt: now,
		updatedAt: now,
	}))

	try {
		await db.transaction(async tx => {
			for (const user of seedUsers) {
				await tx
					.insert(users)
					.values(user)
					.onConflictDoUpdate({
						target: users.id,
						set: {
							name: user.name,
							email: user.email,
							emailVerified: user.emailVerified,
							image: user.image,
							updatedAt: now,
						},
					})
			}

			for (const account of seedCredentialAccounts) {
				await tx
					.insert(accounts)
					.values(account)
					.onConflictDoUpdate({
						target: [accounts.providerId, accounts.accountId],
						set: {
							userId: account.userId,
							password: account.password,
							updatedAt: now,
						},
					})
			}

			await tx.delete(todos).where(inArray(todos.authorId, seededUserIds))

			await tx
				.delete(tickets)
				.where(
					or(inArray(tickets.email, seededTicketEmails), inArray(tickets.authorId, seededUserIds))
				)

			// LifeOS data: delete children first to respect FKs, then reinsert.
			await tx.delete(reflections).where(inArray(reflections.userId, seededUserIds))
			await tx.delete(insights).where(inArray(insights.userId, seededUserIds))
			await tx.delete(memories).where(inArray(memories.userId, seededUserIds))
			await tx.delete(rawCaptures).where(inArray(rawCaptures.userId, seededUserIds))

			await tx.insert(todos).values(seedTodos)
			await tx.insert(tickets).values(seedTickets)
			await tx.insert(rawCaptures).values(seedCaptures)
			await tx.insert(memories).values(seedMemories)
			await tx.insert(reflections).values(seedReflections)
			await tx.insert(insights).values(seedInsights)
		})

		// eslint-disable-next-line no-console
		console.log(
			`Seeded ${seedUsers.length} users, ${seedCredentialAccounts.length} credential accounts, ${seedTodos.length} todos, ${seedTickets.length} tickets, ${seedCaptures.length} captures, ${seedMemories.length} memories, ${seedReflections.length} reflection, and ${seedInsights.length} insight. Default password: ${seedPassword}`
		)
	} finally {
		await pool.end()
	}
}

void seedDatabase().catch(error => {
	// eslint-disable-next-line no-console
	console.error("Database seeding failed.")
	// eslint-disable-next-line no-console
	console.error(error)
	process.exitCode = 1
})
