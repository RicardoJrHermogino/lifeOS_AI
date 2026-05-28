import { Module } from "@nestjs/common"

import { CapturesModule } from "./captures/captures.module"
import { ExamplesModule } from "./examples/examples.module"
import { ExportsModule } from "./exports/exports.module"
import { HealthModule } from "./health/health.module"
import { MemoriesModule } from "./memories/memories.module"
import { ReflectionsModule } from "./reflections/reflections.module"
import { SearchModule } from "./search/search.module"
import { SettingsModule } from "./settings/settings.module"
import { TicketsModule } from "./tickets/tickets.module"
import { TimelineModule } from "./timeline/timeline.module"

@Module({
	imports: [
		ExamplesModule,
		HealthModule,
		TicketsModule,
		CapturesModule,
		MemoriesModule,
		TimelineModule,
		SearchModule,
		ReflectionsModule,
		ExportsModule,
		SettingsModule,
	],
})
export class V1Module {}
