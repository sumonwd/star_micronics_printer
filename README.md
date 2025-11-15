# Star Micronics Printer Flutter Plugin

A comprehensive Flutter plugin for integrating Star Micronics printers with Flutter applications. Provides full printing functionality including receipt printing, barcode/QR code generation, and cash drawer control.

## Features

- **Printer Discovery**: Search for printers on LAN, Bluetooth, Bluetooth LE, and USB
- **Status Monitoring**: Check printer status (online, paper, cover, drawer)
- **Receipt Printing**: Print text with various styles (bold, magnified, aligned)
- **Barcode Support**: Print multiple barcode formats (Code128, Code39, Code93, JAN8, JAN13)
- **QR Code Support**: Print QR codes with configurable error correction
- **Image Printing**: Print images from bytes or Flutter widgets
- **Paper Control**: Cut paper, feed lines
- **Cash Drawer**: Open cash drawer control
- **Fluent API**: Easy-to-use command builder pattern

## Platform Support

| Platform | Status | SDK Used | Notes |
|----------|--------|----------|-------|
| Android (min SDK 24) | ✅ **Fully Supported** | StarIO10 (StarXpand SDK) | Production ready |
| iOS 14.0+ | ✅ **Fully Supported** | StarIO10 (StarXpand SDK) | Requires manual SDK setup |
| Windows | ❌ **Not Supported** | N/A | See [Windows README](windows/README.md) |

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  star_micronics_printer:
    git:
      url: https://github.com/phonetechbd/star_micronics_printer.git
```

Then run:

```bash
flutter pub get
```

### Platform-Specific Setup

#### Android

No additional setup required. The StarIO10 SDK is included via Gradle.

#### iOS

⚠️ **IMPORTANT**: The iOS implementation requires manual setup of the StarIO10 SDK via Swift Package Manager. Follow these steps in order:

1. Open `ios/Runner.xcworkspace` in Xcode (run `flutter pub get` first if needed)
2. In Xcode: `File` > `Add Package Dependencies...`
3. Enter: `https://github.com/star-micronics/StarXpand-SDK-iOS`
4. Select the latest version and add to **Runner** target
5. Build in Xcode to verify (`Cmd + B`)
6. Then run `cd ios && pod install` if needed

**Note**: You may see a "Unable to find a specification for StarIO10" error if you run `pod install` before adding StarIO10 via SPM. This is expected - just add StarIO10 via SPM first as shown above.

See the [iOS README](ios/README.md) for detailed setup instructions, troubleshooting, and required Info.plist configurations.

#### Windows

Windows is not currently supported. See the [Windows README](windows/README.md) for alternatives.

## Quick Start

### Search for Printers

```dart
import 'package:star_micronics_printer/star_micronics_printer.dart';

final printers = await StarMicronicsPrinter.searchPrinters(
  timeout: Duration(seconds: 10),
);

for (var printer in printers) {
  print('Found: ${printer.model} at ${printer.identifier}');
}
```

### Print a Receipt

```dart
final settings = ConnectionSettings(
  interfaceType: InterfaceType.lan,
  identifier: '192.168.1.100', // Printer IP address
);

final commands = PrintCommands()
  .addReceiptHeader('My Store')
  .appendText('Receipt #12345\n')
  .appendText('Date: ${DateTime.now()}\n')
  .feedLine(1)
  .addItemLine('Item 1', '\$10.00')
  .addItemLine('Item 2', '\$15.00')
  .feedLine(1)
  .addTotalLine('Total', '\$25.00')
  .feedLine(2)
  .appendQrCode('https://example.com/receipt/12345')
  .feedLine(1)
  .setAlignment(StarAlignmentPosition.center)
  .appendText('Thank you!\n')
  .appendCutPaper(StarCutPaperAction.partialCutWithFeed);

final success = await StarMicronicsPrinter.printCommands(
  settings: settings,
  commands: commands,
);

if (success) {
  print('Print successful!');
}
```

### Print a Barcode

```dart
final commands = PrintCommands()
  .setAlignment(StarAlignmentPosition.center)
  .appendBarcode(
    '1234567890',
    symbology: StarBarcodeSymbology.code128,
    height: 50,
  )
  .feedLine(2)
  .appendCutPaper(StarCutPaperAction.partialCutWithFeed);

await StarMicronicsPrinter.printCommands(
  settings: settings,
  commands: commands,
);
```

### Check Printer Status

```dart
final status = await StarMicronicsPrinter.getStatus(settings);

if (status != null) {
  if (status.hasError) {
    print('Printer error: Cover=${status.coverOpen}, Paper=${status.paperEmpty}');
  } else {
    print('Printer is ready');
  }
}
```

### Open Cash Drawer

```dart
final success = await StarMicronicsPrinter.openCashDrawer(settings);
```

## API Reference

### StarMicronicsPrinter

Main class with static methods:

- `searchPrinters({Duration timeout})` - Search for printers
- `getStatus(ConnectionSettings)` - Get printer status
- `print({ConnectionSettings, String command})` - Print raw command
- `printCommands({ConnectionSettings, PrintCommands})` - Print using command builder
- `openCashDrawer(ConnectionSettings)` - Open cash drawer

### PrintCommands

Fluent API for building print commands:

#### Text Commands
- `appendText(String text)` - Print text
- `appendTextBold(String text)` - Print bold text
- `appendTextMagnified(String text, {int width, int height})` - Print magnified text
- `setBold(bool enabled)` - Set bold style
- `setMagnification(int width, int height)` - Set magnification
- `setAlignment(StarAlignmentPosition)` - Set alignment (left, center, right)

#### Barcode Commands
- `appendBarcode(String data, {StarBarcodeSymbology symbology, int height})` - Print barcode

#### QR Code Commands
- `appendQrCode(String data, {StarQRCodeLevel level, int cellSize})` - Print QR code

#### Image Commands
- `appendBitmap(Uint8List bytes, {int width})` - Print image from bytes
- `appendBitmapWidget(Widget widget, {int width})` - Print image from Flutter widget

#### Paper Control
- `appendCutPaper(StarCutPaperAction action)` - Cut paper
- `feedLine(int lines)` - Feed paper lines

#### Convenience Methods
- `addReceiptHeader(String storeName)` - Add formatted header
- `addItemLine(String item, String price)` - Add item with price
- `addTotalLine(String label, String total)` - Add total line

### Models

#### ConnectionSettings
```dart
ConnectionSettings(
  interfaceType: InterfaceType.lan, // lan, bluetooth, bluetoothLE, usb
  identifier: '192.168.1.100', // IP, MAC, or USB identifier
)
```

#### PrinterInfo
```dart
class PrinterInfo {
  final String model;
  final String identifier;
  final InterfaceType interfaceType;
  final String? emulation;
}
```

#### PrinterStatus
```dart
class PrinterStatus {
  final bool online;
  final bool coverOpen;
  final bool paperEmpty;
  final bool paperNearEmpty;
  final bool drawerOpen;

  bool get hasError; // true if any error condition
}
```

## Supported Printers

This plugin supports Star Micronics printers that are compatible with the StarIO10 SDK, including:

- mC-Print series
- mC-Label series
- mPOP series
- TSP100 series
- TSP650II series
- TSP700II series
- TSP800II series
- SP700 series
- SM-L series
- SM-S series
- And more...

For a complete list, see [Star Micronics official documentation](https://starmicronics.com/).

## Example App

The plugin includes a comprehensive example app demonstrating all features:

```bash
cd example
flutter run
```

The example app includes:
- Printer search and selection
- Status checking
- Receipt printing with items and totals
- Barcode printing
- QR code printing
- Styled text (bold, magnified, inverted)
- Image printing
- Cash drawer control

## Troubleshooting

### Android

**Printer not found**:
- Ensure printer is on same network (LAN)
- Check Bluetooth permissions in AndroidManifest.xml
- Verify USB host mode support

### iOS

**Module 'StarIO10' not found**:
- You haven't added the StarIO10 SDK via Swift Package Manager
- See [iOS README](ios/README.md) for setup instructions

**No printers found**:
- Check Info.plist privacy keys are configured
- Verify permissions are granted
- Ensure printer is on same network (LAN) or paired (Bluetooth)

### General

**Print not working**:
- Check printer status with `getStatus()`
- Verify connection settings (IP address, interface type)
- Ensure printer is powered on and has paper

## License

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or pull request.

## Resources

- [StarXpand SDK Documentation](https://star-m.jp/products/s_print/sdk/starxpand/manual/en/)
- [Star Micronics Developer Portal](https://starmicronics.com/support/star-micronics-developers/)
- [Flutter Plugin Development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)

## Support

For issues with:
- **This plugin**: Open an issue on GitHub
- **StarIO10 SDK**: Contact Star Micronics support
- **Printer hardware**: Contact Star Micronics support

---

Made with ❤️ by PhoneTech BD
