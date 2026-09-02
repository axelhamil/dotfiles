---
name: solo-sprint
description: Use when starting or running a client project as a solo developer augmented by Claude Code. Trigger on "nouveau projet client", "sprint", "planning", "story", "DoD", "point client", "ship", "rétro jalon", or when setting up project management or a dev workflow for a freelance mission.
---

# Solo Sprint

Scrum adapted for one developer + Claude Code. Replaces team-coordination rituals with context rituals: the bottleneck is not human sync, it is reloading context between sessions and keeping the client in the loop.

## Roles

- **User = Product Owner**: prioritizes, accepts stories, owns client communication.
- **Claude = Dev team**: executes stories, updates Linear, never invents scope.
- Nobody is scrum master. The process is enforced by tooling (Linear + skills + this checklist), not ceremony.

## Setup (once per mission)

1. Paid framing phase produces `docs/PRD.md` in the repo: personas, user flows, scope per billing milestone, acceptance criteria. Short, versioned, client-approved. This is the contract artifact.
   Start with an **event-storming pass**: list the domain events first — they ARE the business. Events define the aggregates, slice the stories, and seed the event catalog (`@packages/events`).
2. Linear project with one epic per billing milestone. Stories carry acceptance criteria + the DoD checklist (template below).
3. Sprint = 1 week, aligned with the weekly client update promised in the quote. The Friday client email IS the sprint review.

## Weekly cycle

**Monday - planning (30 min)**: PO picks the week's stories. Split anything estimated over ~1 dev-day. Estimate in days (billing unit), never story points.

**Per story**: one story = one branch = one Claude Code session. Flow:
1. Read the story in Linear (Claude has Linear MCP access), move it to In Progress.
2. Brainstorm if requirements are fuzzy, write a short implementation plan if multi-step (use existing skills).
3. TDD, implement, commit at each green step (conventional commits), then run the DoD checklist. On a clean-stack clone, execution goes through the repo's `feature-slice` skill (multi-agent pipeline, plan gate + manual review gate).
4. PR into the integration branch, merge, move story to Done with a closing comment (what shipped, decisions made).

Session state lives in the Linear story comments and ICM memory, never only in the conversation.

**Friday - review + ship**: ship the week's batch (release flow below for clean-stack), then send the client update (shipped / next / blockers) — the generated changelog is the raw material.

**End of milestone - retro**: compare quoted days vs actual per lot. Store deviations and their causes in ICM (`icm store -t decisions-<project>`) so the next quote is sharper. This is the only retro that matters solo.

## Definition of Done (checklist per story)

- [ ] Acceptance criteria of the story verified
- [ ] Tests green (new code covered)
- [ ] Build + type-check + linter green
- [ ] /code-review passed on the diff
- [ ] Demo-able (deployed env if the mission has one, else local run)
- [ ] Linear story updated with closing comment

A story that fails any item does not move. No exceptions for "small" stories.

## Clean-stack projects

When the mission runs on a clean-stack clone, the DoD resolves to the repo's actual gates and the release flow gives the client checkpoint for free.

**Branches & shipping (two-branch model):**
- Story branches PR into `dev` (integration). Pushing `dev` never releases.
- Client checkpoint = PR `dev`→`main` merged as a **merge commit** (never squash) → semantic-release bumps the version and writes the CHANGELOG. The Friday ship and the client email are the same event; the changelog drafts the email.
- Pick the commit type for the release impact you want: `feat`→minor, `fix`/`perf`/`refactor`→patch, `chore`/`test`/`docs`→none. Lower-case subject (commitlint enforces).
- Don't ship `dev`→`main` per story — the weekly batch is the release unit.

**DoD gates** — the husky pre-push hook runs the full chain; a push that passes hooks = gates green:

```
pnpm ci:check                          # biome only
pnpm turbo run build type-check test
pnpm check:duplication                 # jscpd
pnpm check:unused                      # knip
```

Schema change: `pnpm db:push` (dev) or `db:generate && db:migrate` (prod-style, migration committed with the story).

**Story slicing = vertical slice.** Command: Hono route → use case → aggregate → repository (+ domain event). Query: route → ORM direct, no use case. Front: `features/<name>/` — query/mutation factory in `features/<name>/api/` (promote to `shared/api/{queries,mutations}/` only when cross-feature) → hooks → components → 2-file route (`<name>.route.tsx` + `<name>.page.tsx`). An endpoint and its factory ship in the same story. A story that only does one layer of a user-facing feature is mis-split.

**Architecture rules that constrain stories:**
- DDD strictly for core business domain. Billing, plans, feature/quota gating, entitlements = pragmatic infra (typed config + `requireFeature()` middleware + `useEntitlements()` hook), never aggregates. If the rule fits in `array.includes()` or a config lookup, it is infra.
- No `throw` in domain/application — `Result<T, E>`; absence is `Option<T>`, never null/undefined.
- Owned aggregates (`userId`/`organizationId`) go through `ScopedRepository<T, TScope>`; wrong owner = `Option.none()`/`NOT_FOUND`, never 403.
- Every state change emits a typed event (`@packages/events`): `aggregate.addEvent()` inside `uow.run()`, or `emitEvent(outbox, ...)` outside aggregates. Payload identifies the actor (`actorUserId` when actor ≠ subject). No event = story not done.
- New repo or external-I/O service takes `IInstrumentation` via constructor; every public I/O method wrapped in a span, every catch calls `capture`.
- Front: no barrel `index.ts`, component props as `interface`, `void navigate(...)` in mutation callbacks.
- Code-adjacent artifacts in English (UI strings, errors, logs); the PRD may stay in the client's language since the client signs it.

## Golden rules

- Nothing gets coded without a story with acceptance criteria.
- Scope is frozen per milestone: new client requests become new stories in a "next milestone" epic, quoted before integration (avenant).
- A story over 1 day gets split before starting, not during.
- Claude updates Linear as work progresses; the PO should be able to read project state without asking.
