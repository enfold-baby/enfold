# Partner activity push — FCM (prepared, finish together)

> **Priority:** P1 · **Status:** Scaffolded in app + VPS. Waiting on Firebase project + credentials.  
> **User-facing toggle:** Settings → Partner notifications → *When partner logs* (off by default).

## What's already done

### Flutter app
- `PushService.registerIfPossible()` → `POST /v1/devices`
- `FcmTokenSource` abstraction; `NoOpFcmTokenSource` returns `null` (safe no-op)
- `pushBootstrapProvider` registers on sign-in when toggle is on
- Toggling *When partner logs* on triggers registration attempt
- Settings copy notes Firebase is required
- `pubspec.yaml` has commented `firebase_core` / `firebase_messaging` deps

### VPS backend (`deploy/api-partner/`, live on api.bloomdue.baby)
- `care_events.created_by_user_id` + `created_by_display_name` on create
- `notify_family_partners()` in `push.py` — no-op until FCM credentials set
- `POST /v1/devices` stores FCM tokens per user
- `.env` keys expected: `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT_JSON`

## Finish together — checklist

### 1. Firebase Console (you + agent)
- [ ] Create Firebase project (e.g. `bloomdue-baby`)
- [ ] Add **Android** app — package `baby.bloomdue.app`
- [ ] Add **iOS** app — bundle `baby.bloomdue.app` (or current Xcode bundle id)
- [ ] Enable **Cloud Messaging**
- [ ] Download `google-services.json` → `android/app/`
- [ ] Download `GoogleService-Info.plist` → `ios/Runner/`
- [ ] Create service account with FCM permissions → JSON for VPS

### 2. Flutter wiring (agent)
- [ ] Uncomment `firebase_core` + `firebase_messaging` in `pubspec.yaml`
- [ ] Android: Google Services Gradle plugin in `android/settings.gradle.kts` + `android/app/build.gradle.kts`
- [ ] iOS: Push Notifications capability, Background Modes → remote notifications
- [ ] `Firebase.initializeApp()` in `main.dart`
- [ ] Add `FirebaseFcmTokenSource` implementing `FcmTokenSource`
- [ ] Override `fcmTokenSourceProvider` to use Firebase implementation
- [ ] Request notification permission (iOS + Android 13+)
- [ ] Listen for token refresh → re-call `registerIfPossible`

### 3. VPS wiring (agent)
- [ ] Set `FIREBASE_PROJECT_ID` and `FIREBASE_SERVICE_ACCOUNT_JSON` in production `.env`
- [ ] Implement FCM HTTP v1 in `backend/app/services/push.py` (replace `send_placeholder`)
- [ ] Redeploy: `deploy/api-partner/deploy_partner.sh` (or push.py-only patch)

### 4. Verify end-to-end
- [ ] Parent A: sign in, join family, enable *When partner logs*, grant notification permission
- [ ] Parent B: log a feed → Parent A receives push
- [ ] Pull sync shows `created_by_display_name` on partner's entries
- [ ] Toggle off → no new pushes (token may remain registered; optional unregister later)

## Key files

| Layer | Path |
|---|---|
| This doc | `feature/todos/FCM_PARTNER_PUSH.md` |
| Token abstraction | `lib/services/push/fcm_token_source.dart` |
| Registration flow | `lib/services/push/push_providers.dart` |
| API client | `lib/services/api/bloomdue_api_client.dart` → `registerDevice()` |
| Settings UI | `lib/features/settings/widgets/partner_notifications_section.dart` |
| Backend push | `deploy/api-partner/push.py` |
| Backend deploy | `deploy/api-partner/deploy_partner.sh` |

## Prompt for next session

> "Let's finish FCM partner push — see `feature/todos/FCM_PARTNER_PUSH.md`"