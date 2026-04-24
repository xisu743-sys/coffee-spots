# Coffee Spots — Development Log

## 2026-04-24 — Session 1: Full Setup + MVP Built

### Environment Setup
- Installed Homebrew 5.1.7 via curl script
- Installed Flutter 3.41.7 via Homebrew
- Installed Android Studio Panda 4 (2025.3.4) via Homebrew
- Installed Android SDK 36.1.0, accepted all licenses
- Set up Android emulator: Pixel 6, API 35 VanillaIceCream
- VS Code + Flutter extension already installed

### China Network Fixes Applied
- Flutter analytics disabled (`flutter --disable-analytics`)
- Gradle mirrors added to `android/settings.gradle.kts` and `android/build.gradle.kts`
  — using Alibaba mirrors (maven.aliyun.com) before Google repos

### App Code Written
- `lib/main.dart` — CoffeeSpotsApp, warm coffee theme
- `lib/models/coffee_shop.dart` — CoffeeShop data model
- `lib/db/database.dart` — SQLite database helper (sqflite)
- `lib/widgets/shop_card.dart` — card component for grid
- `lib/screens/home_screen.dart` — 2-column card grid, empty state
- `lib/screens/add_shop_screen.dart` — add shop form
- `lib/screens/detail_screen.dart` — detail view, map button, photo picker
- `android/app/src/main/AndroidManifest.xml` — added INTERNET, photo permissions

### Status
App compiled successfully and is running on Android emulator.
First debug APK built at: `build/app/outputs/flutter-apk/app-debug.apk`

### Next Steps
- Test all features on emulator (add shop, view, maps, photo)
- Build release APK for distribution
