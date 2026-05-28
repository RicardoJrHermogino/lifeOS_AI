CREATE TABLE "accounts" (
	"id" text,
	"account_id" text,
	"provider_id" text,
	"user_id" text NOT NULL,
	"access_token" text,
	"refresh_token" text,
	"id_token" text,
	"access_token_expires_at" timestamp,
	"refresh_token_expires_at" timestamp,
	"scope" text,
	"password" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "accounts_pkey" PRIMARY KEY("provider_id","account_id")
);
--> statement-breakpoint
CREATE TABLE "data_exports" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"user_id" text NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"download_url" text,
	"expires_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "insights" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"user_id" text NOT NULL,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"body" text NOT NULL,
	"source_memory_ids" jsonb DEFAULT '[]' NOT NULL,
	"evidence" text DEFAULT 'moderate' NOT NULL,
	"status" text DEFAULT 'active' NOT NULL,
	"feedback" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "memories" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"user_id" text NOT NULL,
	"raw_capture_id" uuid,
	"title" text NOT NULL,
	"summary" text NOT NULL,
	"event_date" timestamp NOT NULL,
	"emotions" jsonb DEFAULT '[]' NOT NULL,
	"people" jsonb DEFAULT '[]' NOT NULL,
	"places" jsonb DEFAULT '[]' NOT NULL,
	"topics" jsonb DEFAULT '[]' NOT NULL,
	"goals" jsonb DEFAULT '[]' NOT NULL,
	"decisions" jsonb DEFAULT '[]' NOT NULL,
	"actions" jsonb DEFAULT '[]' NOT NULL,
	"sensitivity" text,
	"confidence" jsonb DEFAULT '{}' NOT NULL,
	"status" text DEFAULT 'candidate' NOT NULL,
	"is_user_corrected" boolean DEFAULT false NOT NULL,
	"embedding" vector(1536),
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "raw_captures" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"user_id" text NOT NULL,
	"type" text NOT NULL,
	"body" text,
	"audio_url" text,
	"transcript" text,
	"transcript_corrected" boolean DEFAULT false NOT NULL,
	"mood" text,
	"status" text DEFAULT 'pending' NOT NULL,
	"sync_id" text,
	"captured_at" timestamp DEFAULT now() NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "reflections" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"user_id" text NOT NULL,
	"date" date NOT NULL,
	"content" text NOT NULL,
	"source_memory_ids" jsonb DEFAULT '[]' NOT NULL,
	"is_user_edited" boolean DEFAULT false NOT NULL,
	"feedback" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"id" text PRIMARY KEY,
	"token" text NOT NULL UNIQUE,
	"user_id" text NOT NULL,
	"expires_at" timestamp NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tickets" (
	"id" serial PRIMARY KEY,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"subject" text NOT NULL,
	"priority" text DEFAULT 'medium' NOT NULL,
	"concern" text NOT NULL,
	"status" text DEFAULT 'received' NOT NULL,
	"author_id" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "todos" (
	"id" serial PRIMARY KEY,
	"title" text NOT NULL,
	"completed" boolean DEFAULT false NOT NULL,
	"author_id" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_settings" (
	"user_id" text PRIMARY KEY,
	"ai_processing_consent" boolean DEFAULT true NOT NULL,
	"ai_personalization" boolean DEFAULT true NOT NULL,
	"proactive_insights" boolean DEFAULT false NOT NULL,
	"reflection_tone" text DEFAULT 'warm' NOT NULL,
	"sensitive_topics" jsonb DEFAULT '[]' NOT NULL,
	"daily_reminder" boolean DEFAULT false NOT NULL,
	"reminder_time" text,
	"app_lock" boolean DEFAULT false NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" text PRIMARY KEY,
	"name" text NOT NULL,
	"email" text NOT NULL UNIQUE,
	"email_verified" boolean DEFAULT false NOT NULL,
	"image" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "verifications" (
	"id" text,
	"identifier" text,
	"value" text,
	"expires_at" timestamp NOT NULL,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now(),
	CONSTRAINT "verifications_pkey" PRIMARY KEY("identifier","value")
);
--> statement-breakpoint
CREATE INDEX "account_user_id_idx" ON "accounts" ("user_id");--> statement-breakpoint
CREATE INDEX "data_exports_user_id_idx" ON "data_exports" ("user_id");--> statement-breakpoint
CREATE INDEX "insights_user_id_idx" ON "insights" ("user_id");--> statement-breakpoint
CREATE INDEX "insights_status_idx" ON "insights" ("status");--> statement-breakpoint
CREATE INDEX "memories_user_id_idx" ON "memories" ("user_id");--> statement-breakpoint
CREATE INDEX "memories_status_idx" ON "memories" ("status");--> statement-breakpoint
CREATE INDEX "memories_event_date_idx" ON "memories" ("event_date");--> statement-breakpoint
CREATE INDEX "memories_raw_capture_id_idx" ON "memories" ("raw_capture_id");--> statement-breakpoint
CREATE INDEX "raw_captures_user_id_idx" ON "raw_captures" ("user_id");--> statement-breakpoint
CREATE INDEX "raw_captures_status_idx" ON "raw_captures" ("status");--> statement-breakpoint
CREATE INDEX "raw_captures_sync_id_idx" ON "raw_captures" ("sync_id");--> statement-breakpoint
CREATE INDEX "reflections_user_id_idx" ON "reflections" ("user_id");--> statement-breakpoint
CREATE INDEX "reflections_user_date_idx" ON "reflections" ("user_id","date");--> statement-breakpoint
ALTER TABLE "accounts" ADD CONSTRAINT "accounts_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "data_exports" ADD CONSTRAINT "data_exports_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "insights" ADD CONSTRAINT "insights_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "memories" ADD CONSTRAINT "memories_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "memories" ADD CONSTRAINT "memories_raw_capture_id_raw_captures_id_fkey" FOREIGN KEY ("raw_capture_id") REFERENCES "raw_captures"("id") ON DELETE SET NULL;--> statement-breakpoint
ALTER TABLE "raw_captures" ADD CONSTRAINT "raw_captures_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "reflections" ADD CONSTRAINT "reflections_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_author_id_users_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE SET NULL;--> statement-breakpoint
ALTER TABLE "todos" ADD CONSTRAINT "todos_author_id_users_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "user_settings" ADD CONSTRAINT "user_settings_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;