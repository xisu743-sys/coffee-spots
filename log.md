# Coffee Spots — Development Log

## 2026-04-24 — Session 2: GitHub + Maps + Product Thinking

### GitHub Setup
- Installed GitHub CLI, authenticated as xisu743-sys
- Initialized git repo, pushed all code to github.com/xisu743-sys/coffee-spots
- `lib/config.dart` added to .gitignore — API key never goes to GitHub

### Address & Map Features Added
- Detail screen: embedded OpenStreetMap tile with red pin, auto-geocodes address on load
- Add screen: address autocomplete — suggestions appear as you type
- Switched from OpenStreetMap Nominatim → Google Places API for better business search
- Google Places API key restricted by package name + SHA-1 fingerprint for security

### Product Thinking
- User raised valid question: is this necessary vs just using Google Maps?
- Conclusion: Google Maps saves a *place*, Coffee Spots saves a *memory*
- Differentiators: Recommended By, Recommended Drink, personal photo, personal journal feel
- User paused to think about product direction — decision pending next session

### Next Steps (pending user decision)
- Decide: keep current direction (personal journal) or pivot the product idea
- If keeping: lean harder into the "memory" angle (story, friend, feeling)
- Build release APK when direction is confirmed

---

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
