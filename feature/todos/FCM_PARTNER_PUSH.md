# Partner activity push — FCM

> **Priority:** P1 · **Status:** Live (2026-09). Android + iOS client files gitignored. API service account on VPS; `PushSender.configured` is true. Sideload **1.0.0+20** includes Android Firebase.  
> **User-facing toggle:** Settings → Partner notifications → *When partner logs* (off by default).

Android / iOS application id: `baby.enfold.app`. Display name is **Enfold**.

## Firebase project (done)

Client files and the API service account are in place (gitignored). The original setup steps are below for reference.

## Original setup steps

Firebase Console: [https://console.firebase.google.com](https://console.firebase.google.com)

1. Create a project named **Enfold** (or **enfold-baby**). Skip Google Analytics if you want.
2. **Add an Android app**
   - Package name: **`baby.enfold.app`** (must match exactly)
   - App nickname: Enfold
   - SHA-1: optional for FCM
   - Download **`google-services.json`**
3. **Add an iOS app** (optional until TestFlight)
   - Bundle ID: **`baby.enfold.app`**
   - Download **`GoogleService-Info.plist`**
4. Enable **Cloud Messaging** (usually on by default): Project settings → Cloud Messaging.
5. Create a **service account key** for the API:
   - Project settings → Service accounts → **Generate new private key**
   - Saves a JSON file like `enfold-xxxxx-firebase-adminsdk-xxxxx.json`

Then drop the files here (or send them to me in chat):

| File | Put it here | Status |
|---|---|---|
| `google-services.json` | `android/app/google-services.json` | **Done** — package `baby.enfold.app`, project `enfold-28c4e` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` | **Done** — bundle `baby.enfold.app`, added to the Xcode resources |
| Service account JSON | `backend/secrets/firebase-sa.json` (never commit) | **Done locally** — `firebase-adminsdk` on `enfold-28c4e` |

SHA-1 of the upload keystore is optional for FCM. Add it later if you turn on Google Sign-In or App Check. For Play App Signing, add both the **upload** SHA-1 and the **App signing** SHA-1 from Play Console.

Done on the API:

- Service account at VPS `backend/secrets/firebase-sa.json` (mode 600), mounted at `/app/secrets/firebase-sa.json`
- `FIREBASE_PROJECT_ID=enfold-28c4e`
- `FIREBASE_SERVICE_ACCOUNT_JSON=/app/secrets/firebase-sa.json`
- Backend recreated; Google OAuth token refresh succeeds

Rebuild the Android/iOS app so devices pick up the native config and can register an FCM token.

Those three files are gitignored. Do not paste the service account JSON into GitHub.

**iOS send:** in Firebase Console → Project settings → Cloud Messaging, upload an Apple **APNs auth key** (`.p8` from Apple Developer) if you have not already. Without it, Android partner pushes work and iOS tokens may register but iOS devices will not receive notifications.

## Already implemented

### Flutter
- `firebase_core` + `firebase_messaging`
- `FirebaseFcmTokenSource` + `POST /v1/devices` on sign-in when the toggle is on
- Token refresh re-registers
- Toggle off → `POST /v1/devices/unregister`
- Android 13+ `POST_NOTIFICATIONS` + `partner_activity` notification channel + `ic_stat_enfold` status icon
- Google Services Gradle plugin applies only if `google-services.json` exists
- iOS background modes + push entitlements

### API
- FCM HTTP v1 in `backend/app/services/push.py`
- Upsert device tokens; drop tokens FCM marks unregistered
- Unique index on `devices.fcm_token` (alembic `20260903_0003`)

## Verify end-to-end (after the files above)

1. Parent A: sign in, join family, enable *When partner logs*, allow notifications
2. Parent B: log a feed → Parent A receives a push
3. Pull sync still shows the partner's display name on the entry
4. Toggle off on A → B's next log should not notify A
