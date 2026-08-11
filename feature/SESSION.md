# Last session

**Date:** 2026-08-11  
**Version:** `0.1.0+9` · Drift schema **v10**  
**API prod:** `https://api.bloomdue.baby` · **API local:** `http://127.0.0.1:8282` (emulator `http://10.0.2.2:8282`)  
**Contact:** `contact@globinary.io`  
**Mail:** Microsoft Graph as `contact@globinary.io`; beta → `contact@globinary.io`; no Sent folder  

## Done this session / recent

- Partner dogfood (Android + iOS): invite, join, leave, caregiver Mom/Dad profile  
- Caregiver profile UI + `PATCH /v1/auth/me`  
- Pull partner events from **all** family children (merge workaround)  
- Pull-to-refresh app-wide  
- **Partner hygiene:** join rebinds to host baby; never create 2nd child when family has one  
- **Periodic foreground sync** (~45s while app resumed)  
- Multi-child full switcher still planned → `todos/MULTI_CHILD.md`  

## Next up

1. Multi-child MVP (active switcher) when ready — after partner one-child is solid  
2. Push local commits to GitHub / prod API parity when you want  
3. Store path when DUNS ready · FCM later  

## Local dev

```bash
docker compose up -d
flutter run -d emulator-5554
```

## Quick resume

```
Read feature/SESSION.md and feature/todos/README.md in bloomdue_baby.
Continue mobile features on Android emulator + local API.
Commit local no coauthor; user pushes GitHub.
```
