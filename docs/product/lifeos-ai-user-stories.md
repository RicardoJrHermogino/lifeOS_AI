# LifeOS AI User Stories and Acceptance Criteria

Version: 1.0  
Date: May 22, 2026  
Project: LifeOS AI  
Audience: Product, Design, Engineering, AI, QA

## 1. Purpose

This document defines detailed user stories for LifeOS AI. Each story includes user intent, priority, functional notes, acceptance criteria, edge cases, and example scenarios.

The stories are written to support backlog creation, sprint planning, wireframing, test planning, and engineering estimation.

## 2. Priority Definitions

| Priority | Meaning |
|---|---|
| P0 | Required for MVP launch |
| P1 | Strongly recommended for MVP or immediate post-MVP |
| P2 | Future version or enhancement |

## 3. Epic Overview

| Epic ID | Epic | MVP Priority |
|---|---|---|
| E01 | Onboarding and Account Setup | P0 |
| E02 | Voice Thought Capture | P0 |
| E03 | Quick Text Capture | P0 |
| E04 | AI Memory Extraction and Review | P0 |
| E05 | Memory Management | P0 |
| E06 | Life Timeline | P0 |
| E07 | Semantic Search and Conversational Retrieval | P0 |
| E08 | Daily Reflection | P0 |
| E09 | Insight Engine | P1 |
| E10 | Personal Knowledge Graph | P1 |
| E11 | Privacy, Security, and Data Control | P0 |
| E12 | Offline and Sync | P1 |
| E13 | Notifications and Reminders | P1 |
| E14 | Settings and Personalization | P1 |
| E15 | Operations, Support, and Maintenance | P1 |

## 4. E01: Onboarding and Account Setup

### US-001: Create Account

As a new user, I want to create a secure account so that my personal memories are stored privately and can be accessed across my devices.

Priority: P0  
Primary user: New user  
Dependencies: Authentication service, privacy policy links

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I am on the welcome screen | I tap Get Started | I see available sign-up methods |
| I choose a valid sign-up method | I complete verification | My account is created and I am signed in |
| I enter invalid credentials | I submit the form | I see a clear error without losing entered data |
| I already have an account | I choose sign in | I can access the existing account flow |

Functional notes:

1. Authentication options may include email, phone, SSO, or passkey.
2. The app must not show an empty dashboard before onboarding is complete.
3. Account creation must direct users into privacy and first capture setup.

Edge cases:

| Edge Case | Expected Behavior |
|---|---|
| Verification email not received | Offer resend and change email |
| Account already exists | Route user to sign in |
| Network error | Preserve input and allow retry |

### US-002: Understand Product Promise

As a new user, I want to understand what LifeOS AI does before sharing personal data so that I can decide whether I trust the app.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open onboarding | I view the product explanation | I understand that the app captures life fragments and turns them into memories |
| I review privacy information | I continue | I understand that I can edit, delete, and export my data |
| I see AI feature descriptions | I read them | They do not claim therapy, diagnosis, or guaranteed accuracy |

Functional notes:

1. The explanation should be short and plain.
2. The app should communicate that AI-generated memory can be wrong and editable.
3. The app should clarify that LifeOS AI is not a generic chatbot.

### US-003: Set Consent Preferences

As a user, I want to choose what AI features are enabled so that I control how my life data is processed.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I am in onboarding | I reach consent setup | I see required and optional consent choices |
| I accept required processing | I continue | I can use core memory features |
| I disable optional insights | I continue | The app still works without proactive insights |
| I change my mind later | I open privacy settings | I can update optional consent settings |

Functional notes:

1. Required consent must be separated from optional AI personalization.
2. Changes must affect future processing.
3. The app should explain if disabling a feature reduces functionality.

## 5. E02: Voice Thought Capture

### US-004: Start Voice Recording Quickly

As a user, I want to start recording a thought quickly so that I can capture life moments before I forget them.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I am signed in | I open the Capture tab | I see a clear microphone action |
| I tap the microphone | Microphone permission is granted | Recording starts immediately |
| Microphone permission is not granted | I tap the microphone | I see a permission request |
| I deny permission | I return to Capture | I can use text capture instead |

Functional notes:

1. Starting a recording should require one primary tap from the capture screen.
2. The recording screen must show elapsed time.
3. The user must be able to pause, resume, stop, or cancel.

### US-005: Save Voice Recording

As a user, I want my voice recording to be saved reliably so that I do not lose an important thought.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I am recording | I tap stop | The app saves the audio as a raw capture |
| The network is unavailable | I stop recording | The app saves the audio locally for later sync |
| The app closes during recording | I reopen it | I see the most recent recoverable recording state where possible |
| Storage is unavailable | I attempt to save | I see an error and guidance |

Functional notes:

1. Raw capture should be preserved before AI processing starts.
2. The app should avoid losing data because transcription fails.
3. Voice capture metadata should include timestamp, duration, source, and sync status.

### US-006: Transcribe Voice Capture

As a user, I want my voice thought transcribed so that I can review and correct what the system heard.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I save a voice recording | Processing begins | The app creates a transcript |
| Transcription completes | I view the result | I can read the transcript |
| The transcript contains an error | I tap edit | I can correct the transcript |
| Transcription fails | I open the capture | I can retry or keep the raw audio |

Functional notes:

1. Transcript should remain linked to original audio if retained by user settings.
2. Transcript edits should be treated as user-corrected source text.
3. Downstream AI extraction should use the corrected transcript when available.

## 6. E03: Quick Text Capture

### US-007: Create Text Capture

As a user, I want to quickly type a thought so that I can capture experiences when voice is not appropriate.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open Capture | I tap text input | A text composer opens |
| I type a thought | I tap save | The app creates a raw text capture |
| I leave before saving | I return later | My draft is available |
| I save an empty capture | I tap save | The app asks me to enter text first |

Functional notes:

1. Text body is the only required field.
2. Optional metadata includes mood, tags, date override, and people.
3. Text capture should trigger AI extraction after save.

### US-008: Add Optional Mood to Capture

As a user, I want to add my mood to a capture so that the system can reflect my emotional context more accurately.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I am composing text | I tap mood | I can select or type a mood |
| I select a mood | I save capture | The mood is stored with the raw capture |
| AI detects a different mood | I review memory | Both AI-inferred and user-provided mood are distinguishable |

Functional notes:

1. User-provided mood has higher authority than AI-inferred mood.
2. Mood selection should be optional and not slow down capture.

## 7. E04: AI Memory Extraction and Review

### US-009: Generate Structured Memory From Capture

As a user, I want LifeOS AI to turn my raw input into a structured memory so that my life data becomes searchable and meaningful.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I save a voice or text capture | AI processing completes | A memory candidate is created |
| The capture mentions people | Extraction runs | People are listed as entities when confidence is sufficient |
| The capture includes a decision | Extraction runs | The decision is captured as a structured field |
| The capture includes an action item | Extraction runs | The action is extracted separately |
| AI confidence is low | I review the memory | Low-confidence fields are highlighted |

Functional notes:

Memory extraction should attempt to identify:

| Field | Description |
|---|---|
| Title | Short human-readable memory name |
| Summary | Concise description of the experience |
| Event date | When the event happened or was captured |
| Emotions | Inferred emotional signals |
| People | People mentioned |
| Places | Physical or virtual locations |
| Topics | Themes such as work, health, family, learning |
| Goals | Goals referenced or implied |
| Decisions | Decisions made or considered |
| Actions | Follow-up actions or commitments |
| Sensitivity | Sensitive content category if detected |
| Confidence | Field-level confidence scores |

### US-010: Review Memory Candidate

As a user, I want to review what the AI understood so that my long-term memory remains accurate.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| A memory candidate is ready | I open it | I see title, summary, original source, and extracted fields |
| I agree with the memory | I tap save | The memory is stored in my timeline |
| I disagree with a field | I edit it | The corrected value replaces the AI value |
| I do not want the memory | I tap delete | The candidate is discarded |
| The memory is sensitive | I view it | The app applies sensitive display and privacy rules |

Functional notes:

1. Original source must remain visible unless deleted by user.
2. Field-level edits must be tracked as user corrections.
3. Saved memories must update timeline, semantic index, and knowledge graph.

### US-011: Auto-Save Trusted Memory

As a frequent user, I want high-confidence memories to save automatically so that I do not need to review every capture.

Priority: P2

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I enable auto-save | A high-confidence memory is extracted | The memory is saved automatically |
| A memory has low confidence | Extraction completes | It still goes to review |
| A memory is sensitive | Extraction completes | It follows my sensitive memory review setting |
| I disable auto-save | I create a capture | New memory candidates require review |

Functional notes:

1. Auto-save must be opt-in.
2. Sensitive content should default to review unless explicitly configured.
3. Auto-saved memories should be easy to find and correct later.

## 8. E05: Memory Management

### US-012: View Memory Detail

As a user, I want to open a memory and see its full context so that I can understand what was stored.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I tap a memory in timeline | Memory opens | I see summary, date, source, tags, emotions, entities, and related memories |
| The memory came from voice | I open source | I can view transcript and audio if retained |
| The memory has related items | I scroll detail | I see links to related memories or entities |

Functional notes:

1. Memory detail must show whether content was AI-generated or user-corrected.
2. Related memories should be explainable.

### US-013: Edit Saved Memory

As a user, I want to edit a saved memory so that the system reflects my life accurately.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open a saved memory | I tap edit | Editable fields become available |
| I update the summary | I save | The memory shows the updated summary |
| I remove an incorrect person | I save | The knowledge graph link is removed |
| I edit date or mood | I save | Timeline and filters update accordingly |

Functional notes:

1. User edits are source of truth.
2. Editing a memory should trigger reindexing.
3. Version history may be P2, but the MVP should at least track updated timestamp.

### US-014: Delete Saved Memory

As a user, I want to delete a memory so that I control what LifeOS AI remembers.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open a memory | I tap delete | I see a confirmation prompt |
| I confirm deletion | Deletion completes | The memory is removed from timeline |
| Deletion completes | I search related terms | The deleted memory does not appear |
| Deletion completes | I ask about related topic | The deleted memory is not used as evidence |

Functional notes:

1. Delete must remove memory from primary store, semantic index, and knowledge graph.
2. Generated insights should no longer cite deleted memories.
3. If hard deletion is delayed, the UI must not continue to show the memory as active.

### US-015: Archive Memory

As a user, I want to archive a memory so that it is hidden from main views without being deleted.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open a memory | I tap archive | The memory is hidden from default timeline |
| I enable archived filter | I view timeline | Archived memories are visible |
| I unarchive memory | I save | It returns to normal timeline views |

Functional notes:

1. Archived memories may still be searchable depending on user setting.
2. The default should be excluded from proactive insights.

## 9. E06: Life Timeline

### US-016: Browse Chronological Timeline

As a user, I want to browse my memories chronologically so that I can review my life over time.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open Timeline | Memories exist | I see memories grouped by date |
| I scroll down | More memories exist | Older memories load |
| I have no memories | I open Timeline | I see an empty state that encourages capture |
| A memory date is edited | I return to Timeline | The memory appears in the correct date group |

Functional notes:

1. Timeline should group by day in MVP.
2. Weekly and monthly summaries can be added later.
3. Timeline items should show title, short summary, time, mood, and source type.

### US-017: Filter Timeline

As a user, I want to filter my timeline by mood, person, topic, or date so that I can find relevant memories.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open filters | I select mood | Timeline shows memories with that mood |
| I select a person | Filter applies | Timeline shows memories connected to that person |
| I select a date range | Filter applies | Timeline shows memories within that range |
| No results match | Filter applies | I see a useful no-results state |

Functional notes:

1. Multiple filters should be supported when technically feasible.
2. Active filters must be visible and removable.
3. Filters should use structured metadata from memories.

## 10. E07: Semantic Search and Conversational Retrieval

### US-018: Search Memories by Meaning

As a user, I want to search using natural language so that I can find memories even when I do not remember exact words.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I search "times I felt proud" | Matching memories exist | I see memories semantically related to pride |
| I search using a person's name | Matching memories exist | I see memories involving that person |
| I search a topic with no results | No matches exist | I see a no-results response |
| Results appear | I tap a result | The memory detail opens |

Functional notes:

1. Search should combine semantic similarity and metadata filtering.
2. Results should be ranked by relevance and recency.
3. Deleted memories must never appear.

### US-019: Ask Question About Past Memories

As a user, I want to ask questions about my life history so that I can understand past goals, emotions, and decisions.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I ask "What did I say about my career goals?" | Relevant memories exist | I receive a summarized answer with memory references |
| I ask "Why was I stressed last month?" | Evidence exists | The answer cites relevant memories and uses cautious language |
| I ask a question with limited evidence | Few memories exist | The answer states that evidence is limited |
| I ask about deleted memory content | Memory was deleted | The deleted memory is not used |

Functional notes:

1. Answers must include source references.
2. The system should not invent facts not present in memory.
3. The user should be able to open supporting memories.

### US-020: Correct an AI Answer

As a user, I want to correct an AI answer so that retrieval improves and false interpretations do not persist.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I receive an answer | I tap "Not accurate" | I can provide feedback |
| I identify a wrong source memory | I open it | I can edit or delete the memory |
| I submit feedback | Feedback is saved | The app acknowledges the correction |

Functional notes:

1. Feedback should be tied to the answer and source memories.
2. The system may use feedback for ranking improvement if user consent permits.

## 11. E08: Daily Reflection

### US-021: Generate Daily Summary

As a user, I want LifeOS AI to summarize my day so that I can reflect without manually journaling everything.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I have memories for today | Daily reflection runs | A summary is generated |
| I open Insights | Today's reflection exists | I can read it |
| The day has few memories | Reflection runs | The summary states that it is based on limited captures |
| I delete a source memory | Reflection is refreshed | The deleted memory is no longer cited |

Functional notes:

1. Daily reflection should include day summary, key events, emotional trend, decisions, and actions when available.
2. Reflection should cite or link to source memories.
3. Reflection should avoid overclaiming.

### US-022: Provide Feedback on Reflection

As a user, I want to mark a reflection as helpful or inaccurate so that the system learns what kind of reflection I value.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open a daily reflection | I tap helpful | Feedback is saved |
| I tap inaccurate | I can select what was wrong |
| I edit the reflection | I save | My edited version is retained |

Functional notes:

1. User-edited reflections should be distinguishable from AI-generated reflections.
2. Feedback should not require a long form.

## 12. E09: Insight Engine

### US-023: View Personal Pattern Insight

As a user, I want to see patterns in my behavior and emotions so that I can understand what affects my life over time.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| Enough related memories exist | Insight generation runs | A pattern insight is created |
| I open the insight | I view details | I see supporting memories |
| Evidence is weak | Insight is generated | The insight is labeled tentative |
| I dismiss the insight | I confirm | It is hidden from active insights |

Functional notes:

1. Insights should be based on multiple memories.
2. Insights must not diagnose or make clinical claims.
3. User can hide similar insights.

### US-024: Save Insight

As a user, I want to save a meaningful insight so that I can return to it later.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open an insight | I tap save | The insight is added to saved insights |
| I open saved insights | Saved insights exist | I see the saved item |
| I unsave insight | I confirm | It is removed from saved insights |

## 13. E10: Personal Knowledge Graph

### US-025: Link Entities Across Memories

As a user, I want the app to connect people, goals, events, and topics across memories so that I can see relationships in my life.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| Multiple memories mention the same person | Graph linking runs | The memories are connected to one entity |
| An entity is incorrectly merged | I edit it | I can split or correct the entity |
| I open a person or topic | Related memories exist | I see connected memories |

Functional notes:

1. Entity merging must be conservative.
2. User corrections should override AI links.
3. Graph links should explain why items are connected.

### US-026: View Related Memories

As a user, I want to see memories related to the one I am viewing so that I can understand context.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open memory detail | Related memories exist | I see a related memories section |
| I tap a related memory | It opens | I can move between related memories |
| No related memories exist | I open detail | The section is hidden or shows none |

## 14. E11: Privacy, Security, and Data Control

### US-027: Export My Data

As a user, I want to export my data so that I can keep a copy outside LifeOS AI.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open privacy settings | I tap export data | I can request an export |
| Export is ready | I open notification | I can download or access the export |
| Export fails | I check status | I see failure reason and retry option |

Functional notes:

1. Export should include readable memories and metadata.
2. Voice/audio inclusion should follow user settings and storage availability.
3. Export should require authentication.

### US-028: Delete Account and Data

As a user, I want to delete my account and data so that I can fully leave the product.

Priority: P0

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open privacy settings | I request account deletion | I see a serious confirmation flow |
| I confirm deletion | Deletion begins | My account is disabled or removed according to policy |
| Deletion completes | I try to sign in | I cannot access deleted data |
| Deletion completes | Retrieval runs | Deleted data is not searchable or cited |

Functional notes:

1. Deletion must include raw captures, memories, embeddings, graph links, insights, and account data except minimal legally required records.
2. The app must explain if deletion takes time to complete.
3. The system must prevent reprocessing of deleted queued data.

### US-029: Lock App With Biometric or Passcode

As a user, I want to protect app access with device security so that my memories are not visible to someone holding my phone.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I enable app lock | I reopen app | The app requires biometric or passcode unlock |
| Unlock fails | I retry | The app remains locked |
| I disable app lock | I authenticate | Lock is turned off |

Functional notes:

1. App lock should use platform-native secure mechanisms.
2. Sensitive screens may require reauthentication.

## 15. E12: Offline and Sync

### US-030: Capture While Offline

As a user, I want to capture thoughts offline so that I can use LifeOS AI anywhere.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| My device is offline | I create text capture | The capture is saved locally |
| My device is offline | I record voice | The recording is saved locally if storage allows |
| I reconnect | Sync starts | Offline captures upload and process |
| Sync fails | I open sync status | I can retry |

Functional notes:

1. Offline local data should be encrypted where possible.
2. Sync must be idempotent to avoid duplicates.

## 16. E13: Notifications and Reminders

### US-031: Receive Daily Reflection Notification

As a user, I want a gentle notification when my daily reflection is ready so that I remember to review it.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| Notifications are enabled | Reflection is ready | I receive a notification |
| I tap notification | App opens | I land on the reflection |
| Notifications are disabled | Reflection is ready | No notification is sent |

Functional notes:

1. Notification copy should be calm and non-invasive.
2. Users must control notification timing.

### US-032: Capture Reminder

As a user, I want optional reminders to capture my thoughts so that I can build a reflection habit.

Priority: P2

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I enable reminders | Scheduled time arrives | I receive a reminder |
| I change reminder time | Next reminder occurs | It follows the new schedule |
| I disable reminders | Time arrives | No reminder is sent |

## 17. E14: Settings and Personalization

### US-033: Set Reflection Tone

As a user, I want to choose the tone of AI reflections so that the app feels supportive and aligned with my preference.

Priority: P2

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open personalization settings | I select a tone | Future reflections use that tone |
| I change tone | New reflection generates | It follows the new setting |
| I reset preferences | I confirm | Default tone is restored |

Functional notes:

1. Tone options should remain emotionally safe.
2. Tone must not change factual grounding.

### US-034: Manage Sensitive Topic Preferences

As a user, I want to control how sensitive topics are handled so that the app does not surface reflections I am not ready to see.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I open sensitive topic settings | I disable proactive insights for a category | Future insights avoid that category |
| A sensitive memory is captured | Settings require review | The memory goes to review |
| I change settings | Future processing runs | New preferences are respected |

## 18. E15: Operations, Support, and Maintenance

### US-035: Report a Problem With AI Output

As a user, I want to report a problem with an AI summary, insight, or answer so that the product can improve and I can protect my memory accuracy.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I view AI output | I tap report | I can choose issue type |
| I submit report | Submission succeeds | I see confirmation |
| The report includes personal data | I submit | The app follows privacy-safe reporting rules |

Functional notes:

1. Issue types may include inaccurate, harmful, too personal, missing context, wrong source.
2. User should control whether supporting content is included in the report.

### US-036: View Processing Status

As a user, I want to see whether captures are processed, pending, or failed so that I know what is happening to my data.

Priority: P1

Acceptance criteria:

| Given | When | Then |
|---|---|---|
| I create a capture | Processing begins | I see pending status |
| Processing succeeds | I open the item | I see memory ready status |
| Processing fails | I open the item | I see retry option |

Functional notes:

1. Status must exist for transcription, extraction, indexing, and sync.
2. The app should avoid technical jargon in user-facing status.

## 19. MVP Story Checklist

The following stories are required for MVP:

| Story ID | Story |
|---|---|
| US-001 | Create Account |
| US-002 | Understand Product Promise |
| US-003 | Set Consent Preferences |
| US-004 | Start Voice Recording Quickly |
| US-005 | Save Voice Recording |
| US-006 | Transcribe Voice Capture |
| US-007 | Create Text Capture |
| US-009 | Generate Structured Memory From Capture |
| US-010 | Review Memory Candidate |
| US-012 | View Memory Detail |
| US-013 | Edit Saved Memory |
| US-014 | Delete Saved Memory |
| US-016 | Browse Chronological Timeline |
| US-017 | Filter Timeline |
| US-018 | Search Memories by Meaning |
| US-019 | Ask Question About Past Memories |
| US-021 | Generate Daily Summary |
| US-027 | Export My Data |
| US-028 | Delete Account and Data |

## 20. Cross-Cutting Acceptance Rules

These rules apply to all relevant stories:

1. User-created or user-corrected data takes priority over AI-generated data.
2. Deleted memories must not appear in search, retrieval, timeline, insights, graph links, or future summaries.
3. AI-generated answers must be grounded in stored memories.
4. Low-confidence AI fields must be reviewable.
5. Sensitive content must follow privacy and consent settings.
6. Raw user input should be preserved until the user deletes it or retention settings remove it.
7. Offline-created data must sync without duplication.
8. All major data actions must have clear success and failure states.
9. The user must be able to access privacy controls from settings.
10. The product must avoid medical, diagnostic, or therapeutic claims.

## 21. Example End-to-End Scenario

Scenario: User captures a stressful workday and later asks why they felt stressed.

1. User opens Capture and records: "Today was rough. The investor call went longer than expected, and I felt like I had not prepared enough. I need to tighten the deck before Monday."
2. The app transcribes the audio.
3. AI extracts:

| Field | Value |
|---|---|
| Title | "Stress after investor call" |
| Mood | Stressed, pressured |
| Event | Investor call |
| Goal | Tighten pitch deck |
| Action | Revise deck before Monday |
| Topic | Fundraising |

4. User reviews and corrects "investor call" to "partner call."
5. Memory is saved to timeline.
6. Daily reflection notes that the day included fundraising pressure and a follow-up action.
7. One week later, user asks: "Why was I stressed last Friday?"
8. The system retrieves the corrected memory and answers using the partner call evidence.
9. The answer cites the memory and avoids claiming more than the stored data supports.

Success outcome: The user trusts the system because it remembered the corrected version and grounded the answer in real memories.
