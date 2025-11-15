# Fixing "No such module 'StarIO10'" Error

## The Problem

Even after adding StarXpand-SDK-iOS via Swift Package Manager, you're seeing:
```
No such module 'StarIO10'
```

This happens because in Flutter plugins, the SPM dependency needs to be properly linked to BOTH:
1. The plugin's framework
2. The example/host app

## Quick Fix (Choose ONE method)

### Method 1: Using Xcode (Recommended)

1. **Clean Everything First:**
   ```bash
   cd example/ios
   rm -rf Pods/ Podfile.lock
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   cd ../..
   flutter clean
   ```

2. **Open in Xcode:**
   ```bash
   cd example
   flutter pub get
   cd ios
   pod install --repo-update
   open Runner.xcworkspace
   ```

3. **Add StarIO10 Package to the Plugin Target:**
   - In Xcode, select the **Pods** project (not Runner)
   - Find the **star_micronics_printer** target in the left sidebar
   - Select the target, then go to **Build Phases** tab
   - Look for **Link Binary With Libraries**
   - Click **+** button
   - Click **Add Other** → **Add Package Dependency**
   - Enter URL: `https://github.com/star-micronics/StarXpand-SDK-iOS`
   - Select version (1.0.0 or later)
   - Make sure it's added to **star_micronics_printer** target
   - Click **Add Package**

4. **Also Add to Runner Target:**
   - Now select the **Runner** target (in the Runner project)
   - Go to **General** tab → **Frameworks, Libraries, and Embedded Content**
   - If StarIO10 isn't there, add it using the **+** button
   - Search for **StarIO10** and add it
   - Make sure it's set to **Embed & Sign** or **Do Not Embed** (depending on your setup)

5. **Build:**
   - Press Cmd+B to build
   - If successful, run: `flutter run`

### Method 2: Using Package.swift (Modern Approach)

The Package.swift file has been created in the `ios/` directory. Now you need to:

1. **Clean everything:**
   ```bash
   cd example
   flutter clean
   cd ios
   rm -rf Pods Podfile.lock .symlinks
   cd ../..
   ```

2. **Update Podfile to use Package.swift:**

   Edit `example/ios/Podfile` and add this BEFORE `flutter_install_all_ios_pods`:
   ```ruby
   target 'Runner' do
     use_frameworks!

     # Add this to ensure SPM integration
     pod 'star_micronics_printer', :path => '../../ios'

     flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

     target 'RunnerTests' do
       inherit! :search_paths
     end
   end
   ```

3. **Install and build:**
   ```bash
   cd example/ios
   pod install
   cd ..
   flutter run
   ```

### Method 3: Manual Framework Linking (Last Resort)

If the above don't work:

1. **Download StarXpand SDK manually:**
   ```bash
   cd ios
   git clone https://github.com/star-micronics/StarXpand-SDK-iOS.git
   ```

2. **Build the framework:**
   - Open `StarXpand-SDK-iOS` in Xcode
   - Build for your target architecture
   - Copy the built `StarIO10.framework` to `ios/Frameworks/`

3. **Update podspec:**
   Edit `ios/star_micronics_printer.podspec` and add:
   ```ruby
   s.vendored_frameworks = 'Frameworks/StarIO10.framework'
   ```

4. **Clean and rebuild:**
   ```bash
   flutter clean
   cd example/ios
   pod install
   cd ..
   flutter run
   ```

## Verification Steps

After applying any method above, verify the fix:

```bash
# 1. Check if module is available
cd example/ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -sdk iphoneos -showBuildSettings | grep StarIO10

# 2. Try building
cd ..
flutter build ios --debug --no-codesign
```

## Common Issues

### Issue: "Module 'StarIO10' not found" during pod install
**Solution:** This is expected. The module is added via SPM, not CocoaPods. Ignore this warning during `pod install`.

### Issue: Build succeeds but runtime crash "dyld: Library not loaded"
**Solution:** The framework isn't embedded. In Xcode:
- Runner target → General → Frameworks, Libraries, and Embedded Content
- Change StarIO10 from "Do Not Embed" to "Embed & Sign"

### Issue: "Unsupported Swift version" error
**Solution:** Update your project's Swift version:
- Runner target → Build Settings → Swift Language Version → Swift 5.0

## Why This Happens

Flutter plugins using CocoaPods + Swift Package Manager have a chicken-and-egg problem:
1. CocoaPods builds the plugin as a framework
2. The plugin imports StarIO10 (from SPM)
3. But SPM dependencies aren't automatically linked to CocoaPod targets

The solution is to explicitly link the SPM package to the plugin target in Xcode.

## Need Help?

If none of these work:
1. Share your Xcode build log: `flutter build ios --debug --no-codesign --verbose`
2. Check if StarIO10 is in your Derived Data: `find ~/Library/Developer/Xcode/DerivedData -name "StarIO10.framework"`
3. Verify your Xcode version: `xcodebuild -version` (need Xcode 13+)
