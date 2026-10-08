# Admin app — implementation plan

Plan for **Bashaer Admin**, the app the driving school uses to manage what the
students' app (`bashaer_driving`, this repo) reads. Written 2026-10-08 from a
read of this codebase. Nothing in the students' app needs to change for
phases 0–3 except `firestore.rules`.

## 1. What the students' app depends on today

The students' app has no backend of its own. It talks to Firestore project
`bashaer-68ee6` directly, and the admin side is currently "Firebase console +
`tool/firebase/seed_firestore.dart`".

| Collection | Students' app does | Code | Admin must |
|---|---|---|---|
| `categories/{slug}` | full `get()` ordered by `order`, cached in Hive | `quiz_remote_datasource.dart` | CRUD, reorder, pick icon |
| `questions/{qid}` | full `get()`, sorted by `qid`, cached in Hive; media cached locally | `quiz_remote_datasource.dart`, `quiz_media_cache.dart` | CRUD, upload image |
| `licenses/{deviceId}` | `get` own row; `create` a pending row (`isActive:false`, `createdAt`) | `license_remote_datasource.dart`, `license_repository_impl.dart` | list pending, approve/extend/revoke, annotate |
| `subscription_plans/monthly` | `get`, cached in secure storage | `subscription_plan_remote_datasource.dart` | edit price, currency, title, features |

License state the students' app derives (`LicenseRepositoryImpl._evaluate`):

| `isActive` | `activeUntil` | Student sees |
|---|---|---|
| false | null | pending (waiting for approval) |
| false | set | inactive (revoked) |
| true | null | pending |
| true | past | expired |
| true | future | access, with offline grace until `activeUntil` |

Payment happens outside the app (WhatsApp / phone in `AppContact`). The student
gives the school their device id from the license gate screen, and the admin
activates that row.

## 2. Findings that shape the admin app

1. **Writes are closed to everyone.** `firestore.rules` denies every write
   except a student creating their own pending license. The app does not use
   Firebase Auth. The admin app needs Firebase Auth plus an admin check in the
   rules (phase 0). A service-account key must never ship inside an app.
2. **No Cloud Storage bucket.** Images are hosted on ImgBB (the seed tool and
   `media_manifest.json`). An ImgBB key inside the admin app can be extracted
   from the APK. That is acceptable only because the admin app is not
   distributed publicly. The safer option is a Cloud Function proxy, which
   needs the Blaze plan. The project stays on Spark, so the key ships in the
   admin app (see Decisions).
3. **The data is richer than `question-bank-contract.md`.** The students' app
   and the seed tool also support `multiple_choice`, `hint`, `difficulty`,
   `audio`, `description`, and per-answer `image`, `description` and
   `isCorrect`. The admin must **merge-update** (`set(..., merge: true)` or
   `update`) and never overwrite a whole document. Otherwise editing a seeded
   question silently drops fields the students' app uses.
4. **Legacy shapes exist in production data.**
   - Category ids are camelCase (`fuelIgnition`, `trafficSigns`), which breaks
     the contract's kebab-case regex. Validate the slug only on create. Existing
     slugs are immutable and must be accepted as they are.
   - Category icons are Font Awesome names (`oil-can`), not emoji. Copy
     `CategoryIcon` into the admin app so the preview matches what students see.
     New picks use the emoji catalog.
5. **`qid` ordering.** The students' app sorts with `a.id.compareTo(b.id)`,
   which is lexicographic. Seeded ids are zero-padded (`q01`…`q83`). The admin
   must generate ids in the same padded width and widen it before 999 (for
   example `q084`, …). Otherwise `q100` sorts before `q84`. The better fix is a
   numeric sort in the students' app (one line in `quiz_remote_datasource.dart`).
6. **The free trial is the first 5 questions by `qid`**
   (`GetTrialQuestionsUsecase`). Editing or deleting `q01`–`q05` changes the
   trial. The admin should mark those rows "trial" in the list.
7. **Deletes don't cascade.** A deleted category orphans its questions, and the
   students' app shows nothing for them. The admin should **block deleting a
   non-empty category** (or offer "move questions to …" first).
8. **The admin can only identify a student by device id.** `fullName` and
   `phoneNumber` are commented out in the students' app. The admin fills
   `fullName`, `phoneNumber` and `note` itself when approving. Because
   `create` rules only check `deviceId` and `isActive`, the admin should
   ignore any other field a student could inject.
9. **Question counts** are computed on the device (`ProgressState`), so the
   admin does not need to maintain `questionCount`.
10. **The pending-license list needs a composite index**
    (`isActive ASC, createdAt DESC`) in `firestore.indexes.json`.

## 3. Decisions (2026-10-08)

| Question | Decision | Consequence |
|---|---|---|
| Platforms | **Android + web** | Image picking and upload must work on both (bytes, not `File` paths). Host the web build on Firebase Hosting, which is free on Spark. |
| Firebase plan | **Spark (free)** | No Cloud Functions and no Cloud Storage bucket. The ImgBB key lives in the admin app (via `--dart-define`), and push-on-approval is out of scope. |
| License duration | **Free-form date picker + preset periods** | The editor offers chips (1 / 3 / 6 / 12 months) that fill a date picker the admin can still change. |
| Non-empty category | **Block delete** | Delete is disabled, with an Arabic message saying how many questions to move or delete first. |
| Admins | **One admin** | No audit trail and no conflict handling. Still stamp `updatedAt`, which is free. |
| Language | **Arabic only, RTL** | Keep `easy_localization` with `ar.json` only, so English can be added later without touching widgets. |
| Images | **Optional, uploaded to ImgBB, URL stored in Firestore** | Upload only when the admin attaches an image. Removing it writes `null`. A question saves fine without one. |

Because there are no server functions, the ImgBB key ships inside the admin APK
and the web bundle. Mitigations: keep the web URL unlisted, publish the admin
app only to the school, and rotate the key from the ImgBB dashboard if it
leaks. The worst case is someone uploading images to the school's ImgBB
account; Firestore stays protected by Auth + rules.

## 4. Product scope

**MVP (phases 0–3)**
- Sign in (email + password). Only users listed as admins get past the gate.
- **Licenses:** pending inbox (newest first), search by device id, name or
  phone; approve or extend with preset chips (1 / 3 / 6 / 12 months) that fill
  a free date picker; revoke (`isActive:false` keeps `activeUntil`, so the
  student sees *inactive* rather than *pending*); edit name, phone and note;
  filter by active, expiring in 7 days, expired, revoked.
- **Categories:** list in `order`, create, edit, reorder (one batched write),
  icon picker, delete **blocked while the category has questions**.
- **Questions:** list with filters (category, type, has image, trial), search
  by title; editor with a type switch, answers, the correct answer, an
  explanation, a hint and difficulty; an **optional** image picked from the
  gallery or files, uploaded to ImgBB, with the returned URL saved on the
  question (replace or remove supported); a preview that renders like the
  students' quiz card; delete with confirmation.
- **Subscription plan:** edit `subscription_plans/monthly` (price, currency,
  title, feature list).

**Later (phase 4)**
- Dashboard: counts of pending, active, expiring and expired licenses, and
  questions per category.
- Bulk import/export of the question bank as JSON (reuse the seed tool's
  validation).

**Out of scope on Spark:** push "your access is active", an ImgBB proxy, and
scheduled expiry reports. These need Cloud Functions; revisit if the project
moves to Blaze.

## 5. Architecture

Create a **separate Flutter project** (`bashaer_admin`) from the same template
as this repo. It uses the same `AGENTS.md` rules, FVM, `flutter_bloc`,
`get_it`/`injectable`, freezed, `easy_localization` (`ar` only, RTL),
`flutter_screenutil` and `AppTheme`. Reasons not to make it a flavor of this
repo: it ships different permissions, has a different auth model, and must
never leak admin code or keys into the students' APK.

Targets: **Android and web** from one codebase.
- No `dart:io` in shared code. Images travel as `Uint8List` from `XFile`
  (`readAsBytes()`), which works on both platforms.
- Layout: the phone layout is the base. On wide web screens (`context.isTablet`
  / `isDesktop`), list and editor sit side by side.
- `flutter_secure_storage` is not needed. Firebase Auth persists the session
  on both platforms.

Packages to add to the new project (**need your approval**, C5):

| Package | Why |
|---|---|
| `firebase_core`, `cloud_firestore` | same as the students' app |
| `firebase_auth` | admin sign-in |
| `http` | ImgBB multipart upload (already used in this repo) |
| `image_picker` | pick an image from gallery or files on Android and web |

Everything else comes from the template.

```
lib/
  core/                       # copied from the template (theme, widgets, error, usecase, DI)
    firebase/firestore_paths.dart     # collection names, one place
    widgets/category_icon.dart        # copy of the students' renderer
    utils/emoji_catalog.dart
  features/
    auth/          data/{datasources: auth_remote_datasource (FirebaseAuth + admins check)}
                   presentation/{cubit: auth_cubit, pages: sign_in_screen, admin_gate}
    licenses/      data/{models: license_model (freezed, Timestamp converters),
                         datasources: licenses_remote_datasource (stream pending, query, update)}
                   domain/usecases: watch_pending, search_licenses, approve_license,
                                    extend_license, revoke_license, update_license_profile
                   presentation/{bloc: licenses_bloc, license_editor_cubit,
                                 pages: licenses_screen, license_detail_screen}
    categories/    data/models/category_model.dart (+ order, createdAt, updatedAt)
                   domain/usecases: watch_categories, save_category, reorder_categories,
                                    count_category_questions,
                                    delete_category (fails with "not empty" when count > 0)
                   presentation/…
    questions/     data/{models: question_model.dart (superset, keeps unknown fields),
                         datasources: questions_remote_datasource, imgbb_datasource}
                   domain/usecases: watch_questions, save_question (normalizes answer ids),
                                    delete_question, next_qid, upload_question_image
                   presentation/{bloc: questions_bloc, question_editor_cubit, pages, widgets/quiz_preview}
    plans/         data + domain + presentation for subscription_plans/monthly
```

Rules of the road:
- Datasources use `FirebaseFirestore.instance` the way this repo does, map
  `FirebaseException` to `ServerFailure`, and are wrapped by
  `HandlingException.wrapHandling` in repositories.
- Lists use `snapshots()` streams, so a student's new pending request shows up
  without a refresh.
- All timestamps are `FieldValue.serverTimestamp()`. Every write stamps
  `updatedAt` (no `updatedBy`, since there is one admin).
- Question save = **merge update** that writes only the fields the editor
  owns. Answer ids are normalized (`a1…aN`; `true`/`false` for true-false), and
  `correctAnswerIds` is remapped by id, not by index.
- `next_qid` takes the highest numeric qid + 1, keeps the existing zero-padding
  width, and writes in a transaction that fails if the id already exists.
- **Category delete** first runs
  `questions.where('categorySlug', isEqualTo: slug).count()`. If the count is
  above 0, it shows "لا يمكن حذف التصنيف — يحتوي على N سؤال" and writes
  nothing. The rules can't enforce this, so the check lives in the use case.
- **Licenses:** `approve`/`extend` write `isActive: true` and `activeUntil` as a
  Firestore `Timestamp` at the end of the chosen day (local 23:59:59, stored in
  UTC). Preset chips add months to `max(today, current activeUntil)`, so
  extending an active license never loses days. The date picker allows any
  future date.
- **Images (optional):** `pick → validate (image signature, ≤ 8 MB) → upload to
  ImgBB → keep data.url in the editor state`. Firestore is written only when
  the question is saved, so a cancelled edit stores nothing. *Remove image*
  saves `image: null`. A failed upload shows a toast and keeps the form; the
  question can still be saved without an image. On Android, `image_picker`
  downscales to a max width of ~1600 px to keep students' downloads small.
- The ImgBB key comes from `--dart-define=IMGBB_API_KEY=…` (on web as well) and
  is never committed (C4). With no key set, the image field is hidden and
  everything else works.

## 6. Firebase changes (this repo, phase 0)

Everything below is available on the Spark plan.

`firestore.rules`:

```
function isAdmin() {
  return request.auth != null
      && exists(/databases/$(database)/documents/admins/$(request.auth.uid));
}
match /admins/{uid}       { allow read: if request.auth != null && request.auth.uid == uid; allow write: if false; }
match /categories/{slug}  { allow read: if true; allow write: if isAdmin(); }
match /questions/{qid}    { allow read: if true; allow write: if isAdmin(); }
match /subscription_plans/{planId} { allow read: if true; allow write: if isAdmin(); }
match /licenses/{deviceId} {
  allow get: if true;
  allow list, update, delete: if isAdmin();
  allow create: if isAdmin() || (request.resource.data.deviceId == deviceId
                                 && request.resource.data.isActive == false
                                 && !('activeUntil' in request.resource.data));
}
```

- Tightening the student `create` (no `activeUntil`) closes a hole in the
  current rules. Today a student can create a row with `isActive:false` and any
  `activeUntil`. It cannot unlock access, but it makes the row read as
  "inactive" instead of "pending".
- Enable Email/Password in Firebase Auth and create the one admin user in the
  console. Add its `admins/{uid}` doc by hand in the console (one admin, so no
  tool is needed).
- Turn off self sign-up for Email/Password if possible, or rely on the
  `admins` check alone. A stranger who creates an account still can't write.
- `firestore.indexes.json`: add `licenses (isActive ASC, createdAt DESC)`.
- Register two apps in `bashaer-68ee6` (Android `com.bashaer.admin`, plus a web
  app) and run `flutterfire configure` in the new project.
- Add **Firebase Hosting** for the web build (free on Spark): `firebase.json`
  `hosting` → `build/web`. Add the hosting domain to Auth's authorized domains.
- Test the rules with the emulator before deploying (`firebase deploy --only
  firestore`). The emulator is free.

**Spike to do in phase 0 (unverified):** confirm that a browser `POST` to
`https://api.imgbb.com/1/upload` from the Flutter web build is not blocked by
CORS. If it is, web uploads are not possible on Spark without a proxy. In that
case web gets "paste an image URL" instead, and Android keeps uploading.

## 7. Phases

| Phase | Deliverable | Est. |
|---|---|---|
| 0 | Firebase: Auth on, `admins` doc, rules + index deployed (tested in the emulator), Hosting set up; admin app scaffolded from the template for Android + web, flutterfire configured; ImgBB CORS spike | 1 d |
| 1 | Auth + admin gate; **Licenses** (pending inbox, approve/extend with preset chips + date picker, revoke, search, name/phone/note) — the highest-value daily task | 2–3 d |
| 2 | **Categories** (CRUD, reorder, icon picker, delete blocked when non-empty) + **Subscription plan** editor | 1–2 d |
| 3 | **Questions** (list/filter, editor for all types, optional ImgBB image, preview, merge-save, qid allocation) | 3–4 d |
| 4 | Dashboard, JSON import/export | 2 d |

Small follow-ups in **this** repo (each optional, each a separate task):
- Sort questions numerically by `qid` (`quiz_remote_datasource.dart`).
- Send `fullName`/`phoneNumber` with the license request (the fields are
  already stubbed and commented out).
- Bring `question-bank-contract.md` in line with reality: legacy slugs and
  icons, the extra question fields, and `multiple_choice`.

## 8. Testing

Unit tests for the parts that can corrupt data: answer-id normalization,
correct-id remapping, qid allocation and padding, license transitions
(approve, extend from an active or expired date, revoke → the state the
students' app derives), category delete blocked when non-empty, and model
round-trips that preserve unknown fields. Run the Firestore rules tests against
the emulator. Use `mocktail` for repositories. `bloc_test` needs approval
before it is added.

## 9. Still to confirm before phase 0

1. Approval to add `firebase_auth` and `image_picker` to the new project.
2. Where the project lives: `D:\projects\bashaer_admin`, a fresh copy of the
   template?
3. The Android application id (proposed: `com.bashaer.admin`).
4. Who creates the ImgBB key: reuse the seed tool's key, or a new one for the
   admin app (recommended, so it can be rotated on its own)?
