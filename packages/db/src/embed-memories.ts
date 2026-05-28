import "dotenv/config"

import pg from "pg"

/**
 * Backfills embeddings for saved/candidate memories that have none (e.g. seed
 * data). Calls the OpenAI embeddings API directly and writes the pgvector
 * column. Run once after seeding so Search/Ask can find seeded memories.
 */
const apiKey = process.env.OPENAI_API_KEY
const model = process.env.OPENAI_EMBEDDING_MODEL ?? "text-embedding-3-small"

if (!apiKey) {
	process.stderr.write("OPENAI_API_KEY is not set in packages/db/.env\n")
	process.exitCode = 1
} else {
	const client = new pg.Client({ connectionString: process.env.DATABASE_URL })
	await client.connect()

	try {
		const { rows } = await client.query<{ id: string; title: string; summary: string }>(
			`SELECT id, title, summary FROM memories
			 WHERE status IN ('saved', 'candidate') AND embedding IS NULL`
		)

		if (rows.length === 0) {
			process.stdout.write("No memories need embedding.\n")
		}

		for (const row of rows) {
			const response = await fetch("https://api.openai.com/v1/embeddings", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Authorization: `Bearer ${apiKey}`,
				},
				body: JSON.stringify({ model, input: `${row.title}\n${row.summary}` }),
			})

			if (!response.ok) {
				throw new Error(`OpenAI ${response.status}: ${await response.text()}`)
			}

			const json = (await response.json()) as {
				data: Array<{ embedding: number[] }>
			}
			const vector = json.data[0]?.embedding
			if (!vector) throw new Error(`No embedding returned for ${row.id}`)

			await client.query(
				`UPDATE memories SET embedding = $1::vector, updated_at = now() WHERE id = $2`,
				[`[${vector.join(",")}]`, row.id]
			)
			process.stdout.write(`Embedded ${row.id} (${vector.length} dims)\n`)
		}

		process.stdout.write(`Done. Embedded ${rows.length} memories.\n`)
	} finally {
		await client.end()
	}
}
