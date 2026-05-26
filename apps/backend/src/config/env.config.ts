import { createEnv } from "@t3-oss/env-core"
import { z } from "zod"

/**
 * Type-safe environment variable validation for Backend API
 *
 * Validates at module load time (fail-fast). Access all env vars through this object.
 */
export const env = createEnv({
	server: {
		// Server
		NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
		PORT: z.coerce.number().int().positive().default(3000),
		HOST: z.string().default("0.0.0.0"),
		CORS_ORIGINS: z.string(),

		// Database
		DATABASE_URL: z.string(),

		// Authentication
		BETTER_AUTH_SECRET: z.string(),
		BETTER_AUTH_TRUSTED_ORIGINS: z.string(),

		// OAuth (optional)
		GOOGLE_CLIENT_ID: z.string().optional(),
		GOOGLE_CLIENT_SECRET: z.string().optional(),

		// AI Provider (OpenAI / compatible)
		OPENAI_API_KEY: z.string().optional(),
		OPENAI_MODEL: z.string().default("gpt-4o"),
		OPENAI_EMBEDDING_MODEL: z.string().default("text-embedding-3-small"),

		// Job Queue (BullMQ via Redis)
		REDIS_URL: z.string().optional(),

		// Object Storage (S3-compatible) — audio + exports
		STORAGE_BUCKET: z.string().optional(),
		STORAGE_ENDPOINT: z.string().optional(),
		STORAGE_ACCESS_KEY: z.string().optional(),
		STORAGE_SECRET_KEY: z.string().optional(),
		STORAGE_REGION: z.string().default("auto"),
	},
	runtimeEnv: process.env,
	skipValidation: !!process.env.CI || process.env.npm_lifecycle_event === "lint",
})

export type Env = typeof env
