# Question bank contract (admin → users app)

What the admin app writes to Firestore, and what a users/student app has to
assume when it reads it. Everything below is what the code actually does today
(`lib/features/content/`); there is no API layer in between — the admin talks to
Firestore directly.

## Where the data lives

| Collection | Document id | Written by |
|---|---|---|
| `categories` | `{slug}` — the slug **is** the id | admin app |
| `questions` | `{qid}` — e.g. `q12` | admin app |
| `licenses` | `{deviceId}` | admin app |
| `subscription_plans` | `{planId}` — e.g. `monthly` | admin console (single public doc) |

Natural-key ids mean a category rename does not orphan questions: only `slug`
is the link, and it is immutable once created (the slug field is hidden when
editing an existing category).

## Category document

`categories/{slug}`

```json
{
  "slug": "traffic-signs",
  "name": "Traffic signs",
  "icon": "🚦",
  "description": "Signs you must recognise",
  "order": 0,
  "createdAt": Firestore server timestamp,
  "updatedAt": Firestore server timestamp
}
```

| Field | Type | Notes |
|---|---|---|
| `slug` | string | lowercase kebab-case, `^[a-z0-9]+(-[a-z0-9]+)*$`, unique. Auto-derived from the name when the admin leaves it empty. |
| `name` | string | 1–60 characters, unique (case-insensitive on save). Shown to the user, so it may be Arabic. |
| `icon` | string \| null | **A single emoji glyph**, e.g. `"🚦"`. Optional. See the rules below. |
| `description` | string \| null | ≤ 300 characters. Optional. |
| `order` | int | 0-based display order. Admin reorders with ↑/↓; every affected row is rewritten. |
| `createdAt` / `updatedAt` | timestamp | Server timestamps, never client values. |

Read with `orderBy('order')` — that is the order the admin arranged, and the
order the users app should present.

### Icon rules

- One glyph from the fixed catalog in `lib/core/utils/emoji_catalog.dart`
  (roads, vehicles, emergency, weather, documents, driving school, general —
  ~65 glyphs). The admin picks it from a grid; free text is no longer accepted.
- Rendering needs no image asset and no network: render the string as text at
  the size that fits the UI. Nothing else is stored.
- Treat `icon` as **optional everywhere**. Older rows created before the picker
  may be missing it, and rows may hold a glyph outside the current catalog.
  Always fall back (the admin app falls back to a folder glyph).
- The catalog is the only contract that matters: if a glyph is not in it, the
  users app still renders whatever string it receives, but it must not assume a
  fixed set.

## Question document

`questions/{qid}`

```json
{
  "qid": "q12",
  "categorySlug": "traffic-signs",
  "type": "single_choice",
  "title": "What does this sign mean?",
  "points": 1,
  "answers": [
    { "id": "a1", "text": "No entry" },
    { "id": "a2", "text": "Stop" }
  ],
  "correctAnswerIds": ["a1"],
  "image": "https://i.ibb.co/abcd1234/stop.jpg",
  "explanation": "A red circle with a white bar forbids entry.",
  "createdAt": Firestore server timestamp,
  "updatedAt": Firestore server timestamp
}
```

| Field | Type | Notes |
|---|---|---|
| `qid` | string | `q<N>`, auto-assigned as *next free number*. Never reused. |
| `categorySlug` | string | Must match an existing `categories/{slug}`. The admin dropdown only offers stored slugs, so this holds at write time — but see *Deleting a category*. |
| `type` | string | `single_choice` or `true_false`. |
| `title` | string | 2–500 characters. |
| `points` | int | Always `1` today. Read it, do not assume. |
| `answers` | array | `{ id, text }`, `text` ≤ 300 characters, unique within the question (case-insensitive). |
| `image` | string \| null | Direct ImgBB URL (`https://i.ibb.co/...`). `null`/absent means no image. |
| `explanation` | string \| null | ≤ 1000 characters. Optional; show after answering. |

### Answer ids are generated, not free-form

The admin never types them; the usecase normalizes them before writing:

- `single_choice` → `a1`, `a2`, `a3`, … by position.
- `true_false` → exactly two answers with the fixed ids `true` and `false`
  (position 0 = true, position 1 = false).

`correctAnswerIds` always references ids from `answers` (renumbered the same
way) and holds **one** id, because both question types are single-answer.
Match by id, never by index — the ids are stable and the indices are not.

### Question images

- Picked through the system file picker, accepted only if the bytes carry a real
  image signature (PNG, JPEG, GIF, BMP, WEBP, HEIC/HEIF) and the file is ≤ 8 MB.
  Nothing is downscaled — the original file is uploaded, so a large photo stays
  large. If you need thumbnails, resize on your side or via an ImgBB parameter.
- Uploads go to ImgBB (`POST https://api.imgbb.com/1/upload`) and only the
  returned `data.url` is stored. Treat it as an opaque https URL; do not parse
  it back into a filename.
- Replacing an image writes the new URL; clearing it writes `null`.

## Deleting a category

Deleting a category only removes the `categories/{slug}` document. Questions
that referenced it keep their `categorySlug` and become **orphans**. The users
app must therefore:

- tolerate a question whose `categorySlug` matches no category (hide it, or
  place it in an "Other" bucket — do not crash), and
- re-read both collections after any admin change, because nothing in the bank
  is cascaded.

If you would rather have the admin block deletion of a non-empty category, that
is a change to `DeleteContentCategoryUsecase` — say the word and it is a small
edit.

## Subscription plans (public read)

The users app shows the monthly price and benefits on the subscribe screen. One
document per plan, read-only from the app, written by the admin console. Create
`subscription_plans/monthly`:

| Field | Type | Notes |
|---|---|---|
| `planId` | string | matches the document id, e.g. `"monthly"` |
| `title` | string | e.g. `"اشتراك شهري"` / `"Monthly subscription"` |
| `price` | number | monthly price in `currency` |
| `currency` | string | ISO code, e.g. `"USD"` |
| `features` | array | short strings shown as benefits (optional; a missing/empty list hides the benefits section) |
| `updatedAt` | timestamp | informational, not read by the app |

The app caches the last fetched plan in secure storage so the price still shows
offline. The Firestore rules allow `read` for everyone and deny `write`.

## Suggested read path for the users app

1. `categories` ordered by `order`; `questions` (any order — sort by `qid`
   numerically, not lexicographically, so `q9` sorts before `q10`).
2. Resolve `questions.categorySlug` → category; drop or bucket the unresolved.
3. Offline cache both collections (Hive/SQLite/Isar) — the admin rewrites rows
   in place, so treat the cache as a mirror, not an append-only log.
4. Listen for snapshots (or poll) so an edit made in the admin app shows up
   without a reinstall.

## Licensing (for context only)

`licenses/{deviceId}` is written by the admin app, not by this contract:
`isActive`, `activeUntil`, `fullName`, `phoneNumber`, `note`. The derived state
the users app gates on is: pending when never approved or no expiry set, expired
when `activeUntil` is in the past, inactive when `isActive` is false with an
expiry set, active otherwise. See
[student-app-flow.md](./student-app-flow.md) — note that doc still describes the
older Back4App/Parse backend, while the code has moved to Firestore + ImgBB.