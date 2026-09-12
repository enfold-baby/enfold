# Todo — in-app Android version check + APK update (Artsani-style)

> **Priority:** P2 · **Status:** API still exists. **In-app APK installer was removed for Play policy** (no `REQUEST_INSTALL_PACKAGES`). `UpdateService` is leftover code, **not wired** from `AppShell` / `EnfoldApp`. After Play, point people at the store. Sideload friends can still install `enfold-1.0.0-N.apk` from Desktop.  
> **Reference:** AD `update_service.dart` + `MainActivity` installer channel (Enfold no longer uses the channel)

## Why this existed

Friends/family install Enfold via **sideload APK** until Play Store is live.  
The original plan was a calm “new version available” prompt that could **download + open the system installer**, same pattern as AD.

**Not** a substitute for Play/App Store after public launch (iOS never sideloads APKs this way). Play policy blocked `REQUEST_INSTALL_PACKAGES`, so the installer path was removed.

## Artsani pattern (summary)

| Layer | Behavior |
|---|---|
| **API** | Public `GET /api/app-version` → `{ version, build_number, download_url, force_update }` |
| **Upload** | Auth’d `POST …/upload` stores APK; `GET …/download` serves it |
| **Admin web** | Settings page: upload APK, toggle force update |
| **Mobile** | On shell open: compare local `PackageInfo.buildNumber` vs remote; dialog Update / Later |
| **Later** | Dismisses for this process only; re-checks next cold start |
| **Install** | Dio download → MethodChannel → Kotlin `ACTION_VIEW` + FileProvider |

## Enfold plan

### Backend (`backend/`)

- [x] `GET /v1/app-version` (public)  
- [x] `GET /v1/app-version/download` (public APK)  
- [x] `PUT /v1/app-version` via `X-Admin-Token`  
- [x] `POST /v1/app-version/upload` via `X-Admin-Token`  
- [x] State: `backend/app_version.json` · APK: `backend/uploads/enfold.apk`  

### Mobile (`lib/`)

- [x] `UpdateService` (file still in repo)  
- [ ] Check once on `AppShell` open — **unwired** after installer removal  
- [x] Dialog: **Update** / **Later** (hide Later if `force_update`) — leftover, unused  
- [x] Progress UI while downloading — leftover, unused  
- [ ] Android MethodChannel + FileProvider install — **removed** from `MainActivity` + manifest  
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
- [ ] Manual: bump build_number above app +N → emulator dialog (verify on device) — **blocked** until installer is replaced by a store link  
- [x] Later dismisses for process; re-checks next cold start  
- [x] Force update hides Later  
- [x] Non-Android does not crash  

## Ops (local)

```bash
# After flutter build apk --release
APP_VERSION_ADMIN_TOKEN=dev-local-apk-admin \
  ./scripts/publish_beta_apk.sh \
  build/app/outputs/flutter-apk/app-release.apk 1.0.0 20
```

Sideload friends: copy `~/Desktop/enfold-1.0.0-N.apk`. There is **no** in-app install prompt.

## Out of scope for first ship

- Full admin UI polish  
- iOS OTA installs  
- Silent install without user confirmation (impossible on stock Android)
