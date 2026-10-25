# SMVS STK Vahan Vyvastha &mdash; Flutter Android App 🚗📱

Modern, lightweight, real-time native Flutter mobile application for SMVS Swaminarayan Dham Fleet Management (`Vahan Vyvastha`).

---

## 🌟 Key Features

1. **Direct Live Sync with Hostinger MySQL (`u339048620_stk`)**:
   - Powered by the live production REST API: `https://vahan-vyvastha.vercel.app/api/vahan`
   - Any booking or update made in this Flutter app reflects **instantly in the Web Admin Portal**, and vice versa.

2. **Movement Booking (Instant & Advance 2-Day)**:
   - Select Driver / Maharaj from all 19 members (`S-4 Saiyam Maharaj`, `87 Jigar Maharaj`, `106 Ketul Maharaj`, etc.) with user code chips.
   - Support for **Other (New Member)** with auto-registration.
   - Vehicle selector showing live odometer (`Maruti Alto 800` at `27,991 KM`).
   - Starting odometer auto-filled with current vehicle odometer.

3. **Active Movements & Vehicle Return (Check-in)**:
   - Lists in-progress vehicle movements.
   - Seamless **Check-in / Return Dialog**: enter end odometer, automatic distance calculation (`actual_km`), odometer validation, and return notes.

4. **Fuel Tracking & Expense Summary**:
   - Month-end filter with total expense (₹), total liters (L), and receipt entries.
   - Add Fuel Slip with optional liters, odometer, receipt number, and notes.

5. **Secure Admin Gate & Fleet Oversight**:
   - Authorized admin credentials login.
   - Leader approval button to issue vehicle keys.
   - Fleet status dashboard (live available/in-use status).

---

## 🚀 How to Run & Build APK

### Prerequisites:
- Flutter SDK 3.0+ installed on your development machine.
- Android Studio or Android Command Line Tools with Android SDK 34.

### 1. Install Dependencies:
```bash
cd vahan_flutter_app
flutter pub get
```

### 2. Run in Debug Mode:
Connect your Android phone or emulator:
```bash
flutter run
```

### 3. Generate Production Android APK:
```bash
flutter build apk --release
```
The compiled APK will be located at:
`vahan_flutter_app/build/app/outputs/flutter-apk/app-release.apk`

---

## 📁 Project Architecture

```
vahan_flutter_app/
├── android/                   # Native Android configuration & permissions
├── lib/
│   ├── models/
│   │   ├── user_model.dart     # Driver / Mukto data & codes
│   │   ├── vehicle_model.dart  # Fleet vehicle status & odometer
│   │   ├── trip_model.dart     # Movement bookings & returns
│   │   └── fuel_model.dart     # Fuel refill records
│   ├── services/
│   │   └── api_service.dart    # Live REST API integration (Vercel + Hostinger MySQL)
│   ├── screens/
│   │   ├── home_screen.dart    # Bottom navigation hub
│   │   ├── booking_form.dart   # Movement booking form
│   │   ├── trips_screen.dart   # Active movements & vehicle return
│   │   ├── fuel_screen.dart    # Fuel logging & monthly filter
│   │   └── admin_screen.dart   # Admin approvals & fleet oversight
│   ├── theme/
│   │   └── app_theme.dart      # SMVS corporate color palette & typography
│   └── main.dart               # App entrypoint
└── pubspec.yaml                # Dependencies (http, intl, google_fonts)
```
