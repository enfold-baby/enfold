# Todo — in-app Android version check + APK update (Artsani-style)

> **Priority:** P2 · **Status:** ✅ Shipped 2026-08-10 (local) · **Model:** Artsani Digital  
> **Reference:** AD `update_service.dart` + `MainActivity` installer channel

## Why

Friends/family install BloomDue via **sideload APK** until Play Store is live.  
We need a calm “new version available” prompt that can **download + open the system installer**, same pattern as AD.

**Not** a substitute for Play/App Store after public launch (iOS never sideloads APKs this way).

## Artsani pattern (summary)

| Layer | Behavior |
|---|---|
| **API** | Public `GET /api/app-version` → `{ version, build_number, download_url, force_update }` |
| **Upload** | Auth’d `POST …/upload` stores APK; `GET …/download` serves it |
| **Admin web** | Settings page: upload APK, toggle force update |
| **Mobile** | On shell open: compare local `PackageInfo.buildNumber` vs remote; dialog Update / Later |
| **Later** | Dismisses for this process only; re-checks next cold start |
| **Install** | Dio download → MethodChannel → Kotlin `ACTION_VIEW` + FileProvider |

## BloomDue plan

### Backend (`backend/`)

- [x] `GET /v1/app-version` (public)  
- [x] `GET /v1/app-version/download` (public APK)  
- [x] `PUT /v1/app-version` via `X-Admin-Token`  
- [x] `POST /v1/app-version/upload` via `X-Admin-Token`  
- [x] State: `backend/app_version.json` · APK: `backend/uploads/bloomdue-baby.apk`  

### Mobile (`lib/`)

- [x] `UpdateService`  
- [x] Check once on `AppShell` open  
- [x] Dialog: **Update** / **Later** (hide Later if `force_update`)  
- [x] Progress UI while downloading  
- [x] Android MethodChannel + FileProvider install  
- [x] iOS/web: no-op check (returns null)  

### Landing / ops (minimal v1)

- [x] Script: `scripts/publish_beta_apk.sh`  
- [x] Document bump `pubspec` +N before each beta APK  

### Later

- [ ] FCM “new version” push  
- [ ] After Play Store: optional store deep link  
- [ ] Admin UI on landing (optional)  

## Acceptance

- [x] Local docker: `GET/PUT /v1/app-version` works with admin token  
- [ ] Manual: bump build_number above app +N → emulator dialog (verify on device)  
- [x] Later dismisses for process; re-checks next cold start  
- [x] Force update hides Later  
- [x] Non-Android does not crash  

## Ops (local)

```bash
# After flutter build apk --release
APP_VERSION_ADMIN_TOKEN=dev-local-apk-admin \
  ./scripts/publish_beta_apk.sh \
  build/app/outputs/flutter-apk/app-release.apk 0.1.0 10
```

## Out of scope for first ship

- Full admin UI polish  
- iOS OTA installs  
- Silent install without user confirmation (impossible on stock Android)  
