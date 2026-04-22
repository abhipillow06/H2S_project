# StayEase — Unified Smart Hotel Guest App

A single Flutter project combining three modules into one cohesive app with a unified gold/navy StayEase design system.

---

## Modules Integrated

| Module | Origin | Feature |
|--------|--------|---------|
| **App Interface** | `app_interface-main` | Login, Home hub, Room Service, Food Order, WiFi Info |
| **QR Check-In/Out** | `Room-Entry-QR-Checkin-out-main` | QR scanner for room check-in/check-out with GPS timestamp |
| **Emergency SOS** | `Room-Emergency-SOS-main` | SOS broadcast, incident report, photo/voice/text evidence |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point + route table
├── theme.dart                     # Shared design tokens (kNavy, kGold, etc.)
├── screens/
│   ├── login_screen.dart          # Login with Google option
│   ├── home_screen.dart           # Dashboard hub — links all modules
│   ├── qr_checkin_screen.dart     # QR scan check-in/out + GPS log
│   ├── emergency_sos_screen.dart  # SOS button + report builder
│   ├── room_service_screen.dart   # Request room items
│   ├── food_order_screen.dart     # Hotel menu ordering
│   └── wifi_info_screen.dart      # WiFi credentials
├── models/
│   └── emergency_report.dart      # SOS report data model
└── pages/                         # SOS sub-pages
    ├── text_report_page.dart      # Incident description form
    ├── camera_page.dart           # Photo/video capture
    ├── voice_page.dart            # Voice memo recorder
    └── submit_page.dart           # Review & submit to emergency services
```

---

## Navigation Flow

```
Login → Home
         ├── [QR icon / banner] → QR Check-In/Out Screen
         │                           └── QR Scanner (camera)
         ├── Room Service → item grid + custom request
         ├── Food Order → menu with cart
         ├── WiFi Info → credentials
         └── [EMERGENCY button] → Emergency SOS Screen
                                     ├── SOS button (3-sec countdown)
                                     ├── Write Incident Report
                                     ├── Attach Photos/Videos
                                     ├── Record Voice Memo
                                     └── Submit to Emergency Services
```

---

## Setup

```bash
flutter pub get
flutter run
```

### Required Permissions (auto-declared in AndroidManifest.xml)
- `CAMERA` — QR scanning + photo capture
- `ACCESS_FINE_LOCATION` — GPS for check-in and SOS
- `RECORD_AUDIO` — Voice memo
- `READ_MEDIA_IMAGES / VIDEO` — Gallery picker
- `VIBRATE`, `FLASHLIGHT` — QR torch

### Min SDK
- Android: **API 21** (minSdk = 21)

---

## Design System (`lib/theme.dart`)

| Token | Color | Use |
|-------|-------|-----|
| `kNavy` | `#0A1628` | Primary text, backgrounds, buttons |
| `kGold` | `#FFD700` | Accent, CTA buttons, icons |
| `kRed` | `#CC2222` | Emergency, SOS, alerts |
| `kGreen` | `#2A7D4F` | Check-out, success states |
| `kBgPage` | `#F7F8FA` | Page backgrounds |
| `kWhite` | `#FFFFFF` | Cards |

All screens use `stayEaseAppBar()`, `cardDecoration()`, `GoldButton`, and `SectionLabel` from `theme.dart`.
