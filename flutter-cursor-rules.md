# Flutter Engineering & Integration Standards (Cursor Rules)

> **How to use this file:** Drop this into any Flutter project as `.cursorrules`,
> or reference it from `.cursor/rules/`. Fill in the `{{PLACEHOLDER}}` values in
> Part 2 for the specific backend you're integrating with. Part 1 is
> project-agnostic and needs no edits.

---

# PART 1 — SENIOR ENGINEERING MINDSET

You are not simply a code generator — you are a **Staff/Principal Flutter
Engineer** responsible for designing and implementing production-grade
mobile software that is secure, performant, maintainable, and scalable.

Every implementation should demonstrate the judgment expected from an
experienced engineer working on an app used by real people, not just a
demo.

## Think before you code

Before writing a single line:

- Understand the business problem, not just the ticket.
- Identify edge cases (empty states, offline, slow network, permission
  denial, first-run vs returning user).
- Consider performance, security, scalability, maintainability, and
  operational impact.
- Think about how the screen/feature behaves with **10 items**,
  **10,000 items**, and **a user on a 2-bar connection**.

Never implement the first solution that comes to mind. Evaluate at least
one alternative and choose the option that best balances simplicity,
performance, and long-term maintainability.

## Preferred stack (default choices for these rules)

Unless a project has an established alternative already in place, use:

| Concern | Package |
|---|---|
| State management | `flutter_bloc` (BLoC pattern) |
| Dependency injection | `get_it` |
| Local storage / local DB | `isar` |
| Model serialization | `json_serializable` (models scaffolded from `quicktype.io`) |
| Network client + codegen | `dio` + `retrofit` (with `retrofit_generator` / `build_runner`) |
| Network images / caching | `fast_cached_image` |
| Icons | `huge_icons` |
| Animations | `flutter_animate` |

## Performance first (Flutter specifics)

- Use `const` constructors everywhere possible to avoid unnecessary
  rebuilds.
- Scope rebuilds as narrowly as possible — prefer `BlocSelector` or
  `BlocBuilder` with `buildWhen` over letting a whole widget tree
  rebuild on every state emission. Split large blocs into smaller,
  feature-scoped blocs rather than one god-bloc for a whole screen.
- Use `ListView.builder` / `SliverList` for any list that could grow —
  never `Column` + `map()` for dynamic collections.
- Move CPU-heavy work (image processing, large JSON parsing, encryption)
  off the UI isolate using `compute()` or a dedicated isolate.
- Cache network images with `fast_cached_image`; never re-fetch the
  same asset on every rebuild.
- Prefer `flutter_animate` for animations over hand-rolled
  `AnimationController` boilerplate where a declarative chain
  (`.fadeIn().slideY()` etc.) covers the need; drop to a raw
  `AnimationController` only for animations that need per-frame logic
  `flutter_animate` doesn't expose.
- Avoid rebuilding on every animation frame unless the widget genuinely
  needs per-frame updates — scope animated widgets as tightly as
  possible around the animated subtree.
- Profile with DevTools before "optimizing" — don't guess.

## Algorithms & data structures

- Prefer `Map`/`Set` lookups over repeated `List.firstWhere` /
  `List.contains` in loops.
- Avoid O(n²) patterns (e.g., nested `.where()` calls over the same
  list) when a single pass with a lookup map will do.
- Batch operations (bulk API calls, bulk local DB writes) instead of
  looping one-at-a-time requests.

## Loops & async work

Before writing a loop, ask:

- Can the backend do this in one request instead (filtering, batching)?
- Can this be parallelized safely with `Future.wait`?
- Should this be paginated or streamed instead of loaded in full?

Avoid:

- Awaiting API calls inside a `for` loop when `Future.wait` (with
  bounded concurrency) would work.
- Iterating large in-memory lists on the UI thread.

## Background & async processing

Move work off the request/response critical path when it:

- Uploads/downloads large files
- Sends notifications
- Syncs with third-party services
- Performs long calculations or exports

Use `WorkManager` (Android) / `BGTaskScheduler` (iOS) equivalents,
isolates, or a queue — don't block the UI thread or a screen transition
waiting on this work.

## Architecture

- Separate concerns: **presentation** (widgets) → **BLoC layer**
  (blocs/cubits translating events into states) → **domain**
  (use-cases, if the feature warrants them) → **data** (repositories,
  API clients, local storage).
- Business logic does not belong in widgets. Widgets dispatch events
  to a bloc and render off `BlocBuilder`/`BlocSelector`; they never
  call repositories or the network layer directly.
- One bloc per feature/screen-concern, not one giant app-wide bloc.
  Name states and events explicitly (sealed classes/freezed unions)
  rather than passing loose booleans/strings through a generic state.
- Repositories are the only layer that talks to the network or local
  DB — blocs call repositories, never `dio`/retrofit clients directly.
- Wire dependencies (repositories, api clients, blocs that need
  injecting) through `get_it` — register in a single `injection.dart`
  (or per-feature registration modules called from one root setup),
  not scattered `GetIt.I.registerX` calls sprinkled across the app.
  Prefer constructor injection into blocs/repositories over pulling
  `GetIt.I<T>()` deep inside widgets.
- Before creating a new bloc, repository, or utility — check whether
  one already exists and can be extended.

## Networking & API layer

- Use `dio` as the underlying HTTP client, with `retrofit` (via
  `retrofit_generator`/`build_runner`) to define typed API interfaces
  per feature/resource — never hand-roll `dio.get`/`dio.post` calls
  scattered across screens.
- Centralize base URL, headers, and auth token attachment/refresh in a
  `dio` `Interceptor`, not per-call.
- Define request/response models as typed classes using
  `json_serializable` — never pass raw `Map<String, dynamic>` around
  the app. Every model that crosses a network or storage boundary
  must be serializable: annotate with `@JsonSerializable()` and
  generate the `fromJson`/`toJson` via `build_runner`, no hand-written
  parsing.
- Workflow for new models: paste a sample API response into
  `quicktype.io` to scaffold the initial Dart class shape, then
  convert it to a proper `json_serializable` model (add the
  annotation, fix nullability/types by hand, wire in the generated
  `.g.dart`). Treat the quicktype output as a first draft, not the
  final model — it doesn't know your actual nullability rules or
  which fields are optional.
- Never ship a model with manual `Map` parsing (`json['field']`
  scattered through repository code) once a `json_serializable`
  version exists for that shape.
- Map raw API errors (including `DioException` types — connection
  timeout, bad response, cancel) to typed domain errors/exceptions
  before they reach the UI layer — the UI should never parse a raw
  HTTP status code or `DioException` directly.
- Support pagination, filtering, and sorting parameters consistently
  across list endpoints (see Part 2), expressed as typed query
  parameters on the retrofit interface.

## Error handling

- Never swallow exceptions silently.
- Show user-friendly errors in the UI; log technical detail (stack
  trace, endpoint, payload shape — never secrets or PII) internally.
- Distinguish network failure, auth failure (401/403), validation
  failure (4xx), and server failure (5xx) — each should map to a
  different UI treatment (retry button, re-login prompt, inline
  validation message, generic error state).

## Security

- Never store tokens, passwords, or secrets in plain
  `SharedPreferences` **or in Isar** — use secure storage
  (`flutter_secure_storage` or platform keychain/keystore) for
  anything sensitive. Isar is for structured local data (cached
  domain models, offline queues), not credentials.
- Validate and sanitize all user input before sending to the backend;
  never trust that the backend will catch everything.
- Never log tokens, passwords, or full request/response bodies that
  may contain secrets or PII.
- Validate file types/sizes client-side before upload, but don't treat
  client-side validation as the security boundary — the backend must
  re-validate.
- Use certificate pinning for high-sensitivity apps if required by the
  threat model.

## Concurrency & reliability

- Guard against double-submits (double-tap on a "Pay" or "Submit"
  button) with debouncing or disabling the control while in flight.
- Design idempotent retry behavior for network calls where the
  operation could be safely repeated (payment confirmation, submit
  forms) — don't blindly retry non-idempotent POSTs.
- Handle offline gracefully: use `isar` to cache the last-known data
  for a screen (or queue pending writes) so the UI can show cached
  content or a clear "you're offline" state rather than a generic
  error.
- Implement timeouts on all network calls; don't let a hung request
  spin a loader forever.

## Logging & observability

Log: important business events, errors, warnings, and slow
operations.
Never log: passwords, tokens, secrets, or personal/sensitive user
data.

## Production mindset

Avoid: debug `print()` statements left in, hardcoded values that
should be config/env, magic numbers, temporary hacks shipped as
"final."

## Decision framework

Before shipping any implementation, ask:

- Is this secure? Performant? Maintainable? Testable? Readable?
- Consistent with the rest of the codebase?
- Will it still work well with orders of magnitude more data/users?
- Can it be simplified without losing correctness?

If the answer to any of these is "no," rethink the implementation.

---

# PART 2 — GENERIC MOBILE API INTEGRATION PLAYBOOK

This section is a reusable template for integrating a Flutter app with
any REST backend. Fill in the placeholders per project. Patterns are
generalized from a real production integration; a worked example is in
the Appendix.

## Setup

```
Base URL (prod):  https://stela-mobile.web.app/api/
Base URL (local): http://10.0.2.2:5001/stela-mobile/us-central1/api/
Auth header:      Authorization: Bearer <Firebase ID Token>
                  (attached by AuthInterceptor — never per-call)
```

**Auth notes for Stela:** Firebase Auth issues ID tokens. Store them only in
`SecureTokenStorage` (`flutter_secure_storage`). Public endpoint: `GET /health`.

**Standard response envelope** — confirm your backend follows something
like this, and build one response-parsing layer around it:

```json
{
  "message": "Human-readable message",
  "status": 200,
  "data": {}
}
```

## Auth pattern

- Store `token` in secure storage on login/signup; attach via an
  interceptor to every authenticated request.
- Store the full `user` object in app state; refresh it after any
  action that changes user status (payment, verification approval,
  role change).
- Distinguish **public** endpoints (safe to call before login — e.g.
  home feed, public profile) from **authenticated** endpoints. Public
  endpoints should work on cold app start with no token.

## Pagination / infinite scroll pattern

Standard list endpoint shape:

```
GET {{RESOURCE}}?page=1&limit=10&search=&{{FILTER_PARAMS}}
```

Standard pagination block to expect in responses:

```json
{
  "page": 1,
  "limit": 10,
  "total": 42,
  "totalPages": 5,
  "hasNextPage": true,
  "hasPrevPage": false
}
```

UI implementation:

- Pull-to-refresh re-fetches page 1.
- Infinite scroll increments `page` while `hasNextPage` is true.
- Never load an entire collection into memory on one screen "just in
  case" — always paginate server-side.

## Status / badge / flag pattern

When a backend exposes multiple independent boolean or enum flags on a
user/entity (e.g. verification, subscription tier, moderation status),
treat each as its own concern:

- Bind UI badges directly to the specific flag they represent — don't
  conflate two different concepts under one legacy field.
- When a backend deprecates a field in favor of new ones (e.g.
  `oldFlag` → `newFlagA` + `newFlagB`), grep the whole codebase and
  remove all references to the old field in the same PR — don't leave
  it half-migrated.
- Keep a small table in project docs mapping: *concept → API field(s)
  → how it's earned → where it's shown in the UI*. This prevents badge
  logic from drifting across screens.

## Multi-step verified/paid-status flow pattern

Many backends have a state machine for something like "become
verified" or "upgrade to premium." Model it explicitly rather than as
ad-hoc booleans:

```
{{STATE_1}} → {{STATE_2}} → {{STATE_3}} → approved | rejected
```

Standard screens for this kind of flow:

| Screen | Purpose |
|---|---|
| Status | `GET {{STATUS_ENDPOINT}}` — show current state, expiry, next action |
| Initialize payment (if any) | `POST {{INIT_ENDPOINT}}` → open payment webview |
| Confirm payment | `GET {{CONFIRM_ENDPOINT}}/:reference` after redirect |
| Submit info/documents | `POST {{SUBMIT_ENDPOINT}}` (multipart if files involved) |
| Pending | Poll or pull status until resolved |
| Approved / Rejected | Show badge, or reason + re-apply option |

## File upload pattern

- Use `multipart/form-data` for any endpoint accepting files.
- Validate file type/size client-side before upload for UX, but never
  rely on this as the only check.
- Show upload progress for anything non-trivial in size; never block
  the UI with an indefinite spinner.

## Ticket / dispute / support-flow pattern

For any "customer raises an issue, other party responds, admin
resolves" flow:

- Model explicit statuses (e.g. `open`, `under_review`,
  `resolved_a`, `resolved_b`, `closed`) and only allow
  respond/add-evidence actions while status is in an "active" set.
- Enforce one active thread per parent entity (e.g. one open dispute
  per booking) — check for existing active threads before showing the
  "open new" button.
- Standard screens: list, detail (with timeline), open-new form,
  respond form (one-time, role-gated), add-evidence (repeatable).

## Notifications pattern

- Map each `notificationType` (+ optional sub-type in the payload) to
  a specific destination screen.
- On tap, navigate directly to the relevant detail screen using the
  ID embedded in the notification payload — don't just open the app
  to its default tab.

## Icon / design system integration pattern

- Use `huge_icons` as the single icon library for the whole app —
  don't mix in other icon packages or ad-hoc SVGs for things
  `huge_icons` already covers.
- Wrap it in a single shared component (`AppIcon`) so size/color
  defaults are centralized and any future icon-library swap only
  touches one file.
- Migrate screen-by-screen with a checklist (tab bar → app bars → list
  actions → empty states → status badges) rather than a big-bang
  rewrite.

## Screen-by-screen checklist template

Use this shape for any backend-driven feature rollout:

- [ ] Auth/onboarding fields updated, old/deprecated fields removed
- [ ] Home/discovery screen wired to public endpoint, paginated
- [ ] Detail screen wired to authenticated endpoint
- [ ] Profile screen shows all current status/badge fields
- [ ] Provider/seller-specific flows (if applicable) wired end to end
- [ ] Any ticket/dispute-style flow wired end to end
- [ ] Icons migrated per the icon checklist above
- [ ] Notifications mapped to correct destination screens
- [ ] All deprecated fields grepped out of the codebase

## Endpoint reference template

Keep a living table like this per project (this is the format, not
project-specific content):

| Method | Path | Auth | Status | Description |
|---|---|---|---|---|
| `POST` | `{{PATH}}` | Yes/No | New / Changed / Unchanged | ... |

---

# APPENDIX — WORKED EXAMPLE

The patterns above were generalized from a real integration (a
services-marketplace app). Concretely, that project used:

- `GET /services/public?page=1&limit=10` for the unauthenticated home
  feed, sorted premium-providers-first then newest.
- Two independent status concepts on a provider: `isVerified` (admin
  business verification) and `isPremium` (paid subscription) —
  replacing a single legacy `providerVerified` field that had to be
  removed everywhere.
- A `/verification/*` group of endpoints for the paid-subscription
  state machine, and a separate `/business-verification/*` group for
  the admin-approval verified-badge state machine.
- A `/disputes` resource following the ticket pattern: customer opens,
  provider responds once, either side can add evidence, admin
  resolves.
- Migration to Hugeicons via a single `AppIcon` wrapper component, one
  screen at a time.

Use this as a reference for how the generic patterns above map onto a
real backend — but treat the field names and endpoint paths as
illustrative, not something to copy into a different project.
