# iOS Setup Quick Start

## TL;DR - Do This First!

If you're seeing this error:
```
[!] Unable to find a specification for `StarIO10 (~> 1.0)` depended upon by `star_micronics_printer`
```

**Quick Fix:**
1. Open your project in Xcode: `open ios/Runner.xcworkspace`
2. In Xcode: File > Add Package Dependencies...
3. Paste this URL: `https://github.com/star-micronics/StarXpand-SDK-iOS`
4. Click "Add Package" (use latest version)
5. Build in Xcode (`Cmd + B`) to verify
6. Now `pod install` will work

---

## Why This Happens

- **StarIO10 SDK** is only available via **Swift Package Manager** (SPM)
- **StarIO10 is NOT available** via **CocoaPods**
- The plugin's Swift code imports StarIO10, so CocoaPods gets confused during `pod install`
- The solution: Add StarIO10 via SPM in Xcode BEFORE running `pod install`

## Correct Installation Order

### Option 1: SPM First (Recommended)
```bash
# 1. Get dependencies
flutter pub get

# 2. Open Xcode (don't run pod install yet!)
open ios/Runner.xcworkspace

# 3. In Xcode: Add StarIO10 via SPM (see steps above)

# 4. Build to verify
# Press Cmd + B in Xcode

# 5. NOW you can run pod install
cd ios
pod install
```

### Option 2: Already Ran Pod Install?
```bash
# 1. Clean pods
cd ios
pod deintegrate
rm -rf Pods Podfile.lock

# 2. Open Xcode
open Runner.xcworkspace

# 3. Add StarIO10 via SPM in Xcode
# File > Add Package Dependencies...
# URL: https://github.com/star-micronics/StarXpand-SDK-iOS

# 4. Build in Xcode (Cmd + B)

# 5. Now reinstall pods
pod install
```

## Verification Checklist

- [ ] StarIO10 appears under "Package Dependencies" in Xcode
- [ ] Project builds successfully in Xcode (`Cmd + B`)
- [ ] `pod install` completes without StarIO10 errors
- [ ] Flutter app builds: `flutter build ios`

## Still Having Issues?

See the full [iOS README](README.md) for:
- Detailed installation instructions
- Info.plist configuration requirements
- Bluetooth/LAN permission setup
- Full troubleshooting guide

## Technical Explanation

The plugin's podspec uses weak framework linking for StarIO10:

```ruby
s.weak_frameworks = 'StarIO10'
```

This allows CocoaPods to install the plugin even though StarIO10 isn't in the CocoaPods repository. The actual StarIO10 dependency is resolved by Swift Package Manager at the Xcode project level, not by CocoaPods.

---

**Need Help?** Check the [iOS README](README.md) or create an issue in the GitHub repository.
