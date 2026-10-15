# DriveSense - Mobile Application (Flutter)

DriveSense is a production-ready mobile application for Android and iOS that tracks motorcycle and vehicle petrol consumption, mileage efficiency, reserve fuel riding, and ride-sharing earnings (InDrive, Bykea, Uber, Yango).

This application was engineered by converting the full React PWA codebase into a high-performance native Flutter architecture.

---

## 🚀 Key Features Preserved & Converted

1. **Dashboard & Mileage Efficiency**
   - Live effective mileage gauge (km/L) with trend indicators.
   - 5-fill rolling average and all-time average progress tracking.
   - Current tank running odometer.
   - Monthly summary metrics (Total distance, Fuel volume, Expenses, Monthly average).

2. **Fuel Refueling (Log Petrol)**
   - Litres and price per litre inputs with quick preset chips (`+2L`, `+4L`, `+6L`, `+8L`, `+10L`).
   - Integrated calendar date picker.
   - Fallback reserve distance deduction.
   - Short tank detection with automatic rolling average fallback (< 20 km threshold).

3. **Personal Trip GPS Tracking**
   - High-accuracy GPS location tracking with 5-meter lock filter to eliminate stationary drift.
   - Live digital speedometer (km/h) with real-time speed smoothing.
   - Live trip distance and cost calculations based on current fuel rates.
   - **Reserve Fuel Tracking System**:
     - Live toggle between Main Tank and Reserve Fuel Mode.
     - Separate odometer tracking for reserve distance.
     - Manual Reserve Distance addition dialog.
     - Manual Odometer KM entry dialog.
   - Dead reckoning estimation for GPS signal dropouts.

4. **Ride Share Earnings Tracker**
   - Tailored for bike/car ride-sharing drivers (Bykea, InDrive, Yango, Uber).
   - Start/stop GPS ride tracking.
   - Post-trip completion dialog prompting for base fare and tips.
   - Automatic fuel expense deduction, net profit calculation, and net profit per kilometer.
   - Grouped daily breakdown with expandable accordion for individual rides.
   - Monthly gross earnings, tips, and net income summaries.

5. **Fare Profit Calculator**
   - Instant decision tool before accepting a passenger ride offer.
   - Computes fuel consumed, fuel cost, net profit, and profit margin per km.
   - Recommendation badges (Great Fare, Acceptable, Low Margin).
   - Counter-offer simulator showing additional profit and increased margin.

6. **Fuel Fill History & Logs**
   - Filter logs by 5-fill rolling window or full history.
   - Real-time date search filter.
   - Visual badges for Reserve Fuel distance and Short Tank estimates.
   - Backup Export: Generates formatted JSON file and shares via native share sheet.

---

## 📁 Architecture & Project Structure

The project follows clean architecture principles:

```text
petrol_tracker_flutter/
├── android/                        # Native Android configuration
│   └── app/src/main/
│       ├── AndroidManifest.xml    # Fine, coarse, background location & foreground service
│       └── kotlin/.../MainActivity.kt
├── ios/                            # Native iOS configuration
│   └── Runner/
│       ├── Info.plist              # Location privacy usage descriptions & background modes
│       └── AppDelegate.swift
├── lib/
│   ├── core/
│   │   ├── constants/              # MileageConfig, thresholds, fallback defaults
│   │   └── theme/                  # AppColors, AppTheme (Material 3 Dark Glassmorphism)
│   ├── models/
│   │   ├── petrol_entry.dart       # Refuel model with reserveDistance & serialization
│   │   ├── trip.dart               # Personal & ride trip model with dead-reckoning metadata
│   │   └── ride_entry.dart         # Commercial ride earnings, fuel cost & net profit
│   ├── services/
│   │   ├── gps_service.dart        # Geolocator stream, accuracy lock, dead reckoning
│   │   └── storage_service.dart    # SharedPreferences persistence & JSON backup export
│   ├── state/
│   │   └── tracker_store.dart      # Central reactive ChangeNotifier state container
│   ├── widgets/
│   │   ├── bottom_nav_bar.dart     # 6-tab persistent bottom navigation bar
│   │   ├── gps_status_banner.dart  # Floating dismissible GPS alerts & signal loss banner
│   │   └── modals/
│   │       ├── manual_km_modal.dart
│   │       ├── add_reserve_modal.dart
│   │       ├── add_ride_modal.dart
│   │       ├── ride_completion_modal.dart
│   │       └── reset_confirm_modal.dart
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── fuel_entry_screen.dart
│   │   ├── personal_trip_screen.dart
│   │   ├── ride_tracker_screen.dart
│   │   ├── fare_calculator_screen.dart
│   │   └── history_screen.dart
│   └── main.dart                   # Application entry point
├── test/
│   ├── mileage_and_reserve_test.dart
│   ├── fare_calculator_test.dart
│   ├── models_serialization_test.dart
│   └── dead_reckoning_distance_test.dart
└── pubspec.yaml                    # Flutter dependencies
```

---

## 🔒 Mobile Permissions Configured

### Android (`android/app/src/main/AndroidManifest.xml`)
- `ACCESS_FINE_LOCATION`: Required for GPS lock and speed tracking.
- `ACCESS_COARSE_LOCATION`: Fallback network location.
- `ACCESS_BACKGROUND_LOCATION`: Ensures ride tracking is not lost when switching apps.
- `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_LOCATION`: Ensures location tracking persists during rides.
- `POST_NOTIFICATIONS`: Android 13+ status notifications.
- `INTERNET`: External map/network connectivity.

### iOS (`ios/Runner/Info.plist`)
- `NSLocationWhenInUseUsageDescription`: Clear explanation for live speed and distance.
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Allows navigation apps to run alongside DriveSense.
- `UIBackgroundModes`: Includes `location` and `fetch`.

---

## 🛠️ How to Run & Build the App

### Prerequisites
- Install Flutter SDK (version >= 3.19.0): [flutter.dev/get-started](https://docs.flutter.dev/get-started/install)
- Android Studio / Android SDK (for Android build)
- Xcode (for iOS build on macOS)

### 1. Fetch Dependencies
```bash
cd petrol_tracker_flutter
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Run on Device / Emulator
```bash
flutter run
```

### 4. Build Android Release APK
```bash
flutter build apk --release
```
The resulting APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

### 5. Build iOS IPA (on macOS)
```bash
flutter build ipa --release
```
