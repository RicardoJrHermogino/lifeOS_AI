import "dotenv/config"

import pg from "pg"

const client = new pg.Client({
	connectionString: process.env.DATABASE_URL,
})

await client.connect()

try {
	await client.query("CREATE EXTENSION IF NOT EXISTS vector")
	const result = await client.query(
		"SELECT extname FROM pg_extension WHERE extname = 'vector'"
	)
	process.stdout.write(`${JSON.stringify(result.rows)}\n`)
} catch (error) {
	if (error instanceof Error && error.message.includes('extension "vector" is not available')) {
		process.stderr.write(
			[
				"pgvector is not installed on the configured PostgreSQL server.",
				"Use the Docker Compose pgvector database or install pgvector into your local Postgres distribution.",
				`Original error: ${error.message}`,
				"",
			].join("\n")
		)
		process.exitCode = 1
	} else {
		throw error
	}
} finally {
	await client.end()
}
