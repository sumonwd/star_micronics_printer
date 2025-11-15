# iOS Setup Instructions for Star Micronics Printer Plugin

This document provides setup instructions for using the Star Micronics Printer Flutter plugin on iOS.

## Prerequisites

- iOS 14.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

## StarIO10 SDK Installation

The StarIO10 SDK (StarXpand SDK) is required for iOS support but **does not support CocoaPods**. You must add it manually via Swift Package Manager.

### Installation Steps

1. **Run pod install** (if you haven't already):
   ```bash
   cd ios
   pod install
   ```

2. **Open your iOS project in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Add StarIO10 SDK via Swift Package Manager**:
   - In Xcode, select `File` > `Add Packages...`
   - In the search field, enter: `https://github.com/star-micronics/StarXpand-SDK-iOS`
   - Select the latest version (recommended: 2.10.0 or later)
   - Ensure the package is added to your **Runner** target
   - Click **Add Package**

4. **Verify Installation**:
   - In Xcode's Project Navigator, you should see `StarIO10` under **Package Dependencies**
   - Build your project (`Cmd + B`) to ensure there are no errors

## Required Info.plist Configurations

Depending on which printer interface types you plan to use, you must add the following privacy keys to your `Info.plist` file (`ios/Runner/Info.plist`):

### For Bluetooth Printers

Add these keys:

```xml
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>jp.star-m.starpro</string>
</array>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to Star Micronics printers</string>
```

### For LAN/Ethernet Printers

Add this key:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs local network access to discover and connect to Star Micronics printers</string>
```

### For Lightning USB Printers

Add these keys:

```xml
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>jp.star-m.starpro</string>
</array>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to Star Micronics printers</string>
```

**Note**: Lightning USB printers require MFi (Made for iPhone) certification. You must complete Apple's MFi approval process before submitting to the App Store. Bluetooth Low Energy printers do not require MFi certification.

## Supported Printer Interface Types

- **LAN (Ethernet/Wi-Fi)**: Network printers
- **Bluetooth Classic**: Traditional Bluetooth printers
- **Bluetooth LE**: Bluetooth Low Energy printers
- **USB**: Lightning USB connection (requires MFi certification)

## Testing

### Simulator Limitations

The iOS Simulator has limitations when testing printer functionality:

- **Bluetooth**: Not available in Simulator
- **USB**: Not available in Simulator
- **LAN**: May work for network discovery but cannot connect to actual printers

**Recommendation**: Always test on a physical iOS device with actual Star Micronics printers.

### Physical Device Testing

1. Ensure your printer is:
   - Powered on
   - Connected to the same Wi-Fi network (for LAN printers)
   - Paired with your iOS device (for Bluetooth printers)

2. Run the example app:
   ```bash
   cd example
   flutter run
   ```

3. Test printer discovery, status checking, and printing functions.

## Troubleshooting

### "Module 'StarIO10' not found" Error

**Solution**: You haven't added the StarIO10 SDK via Swift Package Manager. Follow the installation steps above.

### "No printers found" during discovery

**Solutions**:
- Ensure the printer is powered on
- For LAN: Verify the iOS device is on the same network as the printer
- For Bluetooth: Pair the printer with your iOS device in Settings > Bluetooth
- Check that you've added the required Info.plist keys (see above)
- Verify permissions have been granted when the app prompts

### Build errors related to architectures

**Solution**: The plugin excludes i386 architecture by default (not needed for modern iOS). If you encounter architecture-related errors, ensure you're building for iOS 14.0 or later.

### Privacy permission prompts not appearing

**Solution**: Make sure you've added the required `NS*UsageDescription` keys to your Info.plist. iOS will not prompt for permissions without these descriptions.

## MFi Certification for Lightning USB

If you plan to distribute your app on the App Store and use Lightning USB printers:

1. Enroll in the [MFi Program](https://mfi.apple.com/)
2. Complete the approval process with Apple
3. Obtain the necessary MFi documentation
4. Include MFi compliance information in your App Store submission

**Note**: This process can take several weeks. Plan accordingly.

## Additional Resources

- [StarXpand SDK for iOS - Official Documentation](https://star-m.jp/products/s_print/sdk/starxpand/manual/en/index.html)
- [StarXpand SDK iOS - GitHub](https://github.com/star-micronics/StarXpand-SDK-iOS)
- [Star Micronics Developer Portal](https://starmicronics.com/support/star-micronics-developers/)

## Example Info.plist

Here's a complete example of the privacy keys section in Info.plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other keys ... -->

    <!-- For Bluetooth and USB printers -->
    <key>UISupportedExternalAccessoryProtocols</key>
    <array>
        <string>jp.star-m.starpro</string>
    </array>

    <!-- For Bluetooth -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth access to connect to Star Micronics printers</string>

    <!-- For LAN/Network printers -->
    <key>NSLocalNetworkUsageDescription</key>
    <string>This app needs local network access to discover and connect to Star Micronics printers</string>

    <!-- ... other keys ... -->
</dict>
</plist>
```

## Support

For issues specific to the StarIO10 SDK, please refer to Star Micronics' official support channels.

For issues with this Flutter plugin, please open an issue on the GitHub repository.
