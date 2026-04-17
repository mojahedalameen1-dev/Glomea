---
description: generates optimized release APKs for the mobile app
---
// turbo-all
1. Check if `android/app/build.gradle` has `minifyEnabled` or desired shrink settings.
2. Navigate to `mobile` directory.
3. Run the following command to generate optimized APKs:
```powershell
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --split-per-abi
```
4. Verify the outputs in `build/app/outputs/flutter-apk/`.
