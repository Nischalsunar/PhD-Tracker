# PhD Navigator

Phase 1 implementation: a Next.js App Router / TypeScript / Tailwind dashboard for a professor-first research journey. Professors, communication events, follow-up tasks, and applications are separate linked records. No messages are sent and no Google Sheets access occurs.

## Run

Node 22+ recommended (validated with Node 24). Run `npm ci`, `npm run dev`, then open port 3000 locally. `npm test`, `npm run typecheck`, and `npm run build` validate logic, TypeScript, and production compilation. No secrets are required for demo mode.

Without Supabase variables the app explicitly runs in DEMO mode. Data lives in browser localStorage; it is not a secure or durable database. Start empty or use Settings to add a fictional professor. Never enter real private data in demo mode. Each browser has separate data; clearing browser storage loses it.

## Hosted authentication and storage

Create a Supabase project and apply `supabase/migrations/001_navigator.sql` in its SQL editor. Copy `.env.example` to `.env.local` and configure the project URL and public anon key. Never use a service-role key. Restart Next.js. Sign up, confirm email, and sign in. Configure Supabase Auth site URL and redirects for your deployment.

The repository interface in `lib/storage.ts` supports browser-demo and Supabase adapters. Hosted requests use the user's JWT. PostgreSQL RLS requires ownership on reads and writes; a database trigger checks identity and rejects cross-owner links. Each record has a UUID, owner, timestamps, and a typed payload. This initial document schema is a deliberate simpler alternative to separate tables for every optional field. Universities are text fields; application records contain program fields and optional funding notes. Future normalization can preserve record IDs.

Hosted auth and cross-user database policies must be integration-tested against your configured Supabase project before using real data. They have not been validated against a live project in this environment. Client validation is not a substitute for database constraints. Do not deploy the demo as a private authenticated service.

## Workflows

Add a professor and record sources/research notes. Open the professor to log communications or add a linked follow-up task. Communications do not automatically change outreach stage; update the current stage explicitly. Add applications, link professors, and update requirement states. A deadline is treated as verified only with a date, source URL, verification date, and checked verification flag. Calendar dates are preserved as entered; relative days use Settings' time zone.

For Google Sheets, download each desired tab via File → Download → CSV. In Import choose record type, upload, map name/university/source/notes, validate, review rejected duplicates, then explicitly confirm. Imported statuses and dates intentionally start unverified. Export downloads the selected record type; export currently includes summary fields, not a full backup of timelines or checklist details. No spreadsheet is modified.

## Deployment

Use a private repository and a Vercel Next.js project (or `npm run build && npm start`). Set both Supabase environment variables, apply the migration, configure authentication redirects, and test two-user isolation before storing real data. No deployment or remote push is performed by this implementation.

## Scope and remaining validation

Implemented Phase 1 manual dashboard, CRUD with archive, timelines, tasks, linked applications, checklist states, verified deadlines, CSV review/export, settings, and auth adapter. No Phase 2/3 integrations. Automated core tests cover counts, duplicate detection, unsafe links and dates. Five core tests, TypeScript checking, production build, and production HTTP rendering passed. A Playwright workflow test is included (`npm run test:e2e`); browser execution was blocked because the environment forbids downloads from cdn.playwright.dev. Run `npx playwright install chromium` in an allowed environment first. Hosted RLS integration checks are still required. Dialogs support labeled controls but do not yet implement full focus trapping. CSV export is a summary export. Backend payload validation needs hardening before production.
