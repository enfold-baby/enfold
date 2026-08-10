# Todo — in-app Android version check + APK update (Artsani-style)

> **Priority:** P2 · **Status:** Not started · **Model:** Artsani Digital mobile  
> **Reference:** `~/apps/artsani-digital/mobile/lib/core/services/update_service.dart`  
> + backend `app/routers/app_version.py` + web `SetariAplicatieMobila.jsx`

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

- [ ] `GET /v1/app-version` (public)  
- [ ] `GET /v1/app-version/download` (public APK)  
- [ ] `PUT /v1/app-version` ops fields (auth or simple admin token for v1)  
- [ ] `POST /v1/app-version/upload` (APK)  
- [ ] Version source: `app-version.json` or DB + file on disk under uploads  

### Mobile (`lib/`)

- [ ] `UpdateService` (port AD logic, EN copy, BloomDue package)  
- [ ] Check once on main shell / after onboarding when app opens  
- [ ] Dialog: **Update** / **Later** (hide Later if `force_update`)  
- [ ] Progress UI while downloading  
- [ ] Android MethodChannel + FileProvider install (mirror AD `MainActivity`)  
- [ ] iOS: optional “open TestFlight/App Store” only — no APK path  

### Landing / ops (minimal v1)

- [ ] Simple upload path: admin page **or** script/scp APK + bump `app-version.json`  
- [ ] Document “bump `pubspec` +N before each beta APK”  

### Later

- [ ] FCM “new version” push (optional; cold-start check is enough for beta)  
- [ ] After Play Store: keep check optional or point to store listing  

## Acceptance

- [ ] Local docker: bump remote build_number → emulator shows dialog  
- [ ] Later dismisses; kill app and reopen → dialog again  
- [ ] Update downloads APK and opens installer  
- [ ] Force update cannot be dismissed  
- [ ] Release builds still work; iOS does not crash on missing channel  

## Out of scope for first ship

- Full admin UI polish  
- iOS OTA installs  
- Silent install without user confirmation (impossible on stock Android)  
