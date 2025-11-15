# CLAUDE.md - Star Micronics Printer Flutter Plugin

## Project Overview

**Project Name:** star_micronics_printer
**Type:** Flutter Plugin Package
**Version:** 0.0.1
**Package:** com.phonetechbd.star_micronics_printer
**Description:** A Flutter plugin for integrating Star Micronics printers with Flutter applications. Provides comprehensive printing functionality including receipt printing, barcode/QR code generation, and cash drawer control.

### Supported Platforms
- **Android** (min SDK 24, compile SDK 36) - ✅ Full implementation
- **iOS** - ⚠️ Stub implementation only (getPlatformVersion)
- **Windows** - ⚠️ C API plugin structure exists but not implemented

### Key Technologies
- **Flutter SDK:** >=3.3.0
- **Dart SDK:** ^3.9.0
- **Kotlin:** 2.1.0 (Android)
- **Android Gradle:** 8.9.1
- **Star Micronics StarIO10 SDK** (Android native dependency)

---

## Project Structure

```
star_micronics_printer/
├── lib/                              # Dart/Flutter code
│   ├── star_micronics_printer.dart   # Main export file
│   ├── star_micronics_printer_platform_interface.dart
│   ├── star_micronics_printer_method_channel.dart
│   └── src/
│       ├── star_micronics_printer.dart   # Main plugin class
│       ├── print_commands.dart           # Command builder API (627 lines)
│       └── models/
│           ├── connection_settings.dart  # Printer connection config
│           ├── printer_info.dart         # Discovered printer info
│           ├── printer_status.dart       # Status monitoring
│           ├── interface_type.dart       # LAN/BT/USB enums
│           ├── star_printer_model.dart   # Printer model enums
│           └── enums.dart                # All printing enums (276 lines)
│
├── android/                          # Android native implementation
│   ├── build.gradle                  # Build configuration
│   └── src/main/kotlin/com/phonetechbd/star_micronics_printer/
│       └── StarMicronicsPrinterPlugin.kt  # Main plugin (335 lines)
│
├── ios/                              # iOS stub implementation
│   └── Classes/
│       └── StarMicronicsPrinterPlugin.swift  # Needs implementation
│
├── windows/                          # Windows C++ stub
│   ├── star_micronics_printer_plugin.cpp
│   └── star_micronics_printer_plugin_c_api.cpp
│
├── test/                             # Unit tests
│   ├── star_micronics_printer_test.dart
│   └── star_micronics_printer_method_channel_test.dart
│
└── example/                          # Demo application
    ├── lib/main.dart                 # Comprehensive demo (353 lines)
    └── integration_test/
        └── plugin_integration_test.dart
```

---

## Architecture

### Plugin Architecture Pattern

This plugin follows the **federated plugin architecture**:

```
Flutter App
    ↓
StarMicronicsPrinter (public API)
    ↓
StarMicronicsPrinterPlatform (interface)
    ↓
MethodChannelStarMicronicsPrinter (implementation)
    ↓
Platform Channel: 'star_micronics_printer'
    ↓
Native Platform Implementation (Android/iOS/Windows)
```

### Communication Flow

1. **Flutter → Native:** Method channels with structured data (Maps)
2. **Native → Flutter:** Async results using Kotlin coroutines on Android
3. **Command Pattern:** PrintCommands builder creates command lists sent to native

---

## Key Components

### 1. StarMicronicsPrinter (Main API)

**Location:** `lib/src/star_micronics_printer.dart`
**Channel:** `MethodChannel('star_micronics_printer')`

**Public Methods:**
```dart
// Printer discovery
static Future<List<PrinterInfo>> searchPrinters({Duration timeout})

// Status monitoring
static Future<PrinterStatus?> getStatus(ConnectionSettings settings)

// Printing methods
static Future<bool> print({ConnectionSettings, String starXpandCommand})
static Future<bool> printCommands({ConnectionSettings, PrintCommands})

// Cash drawer
static Future<bool> openCashDrawer(ConnectionSettings settings)
```

### 2. PrintCommands Builder

**Location:** `lib/src/print_commands.dart`
**Pattern:** Fluent API / Builder pattern
**Purpose:** Type-safe command construction for receipts

**Command Categories:**
- **Text:** `appendText()`, `appendTextMagnified()`, `appendTextBold()`
- **Alignment:** `setAlignment(StarAlignmentPosition)`
- **Barcodes:** `appendBarcode()` - Code128, Code39, etc.
- **QR Codes:** `appendQrCode()` with error correction levels
- **Images:** `appendBitmap()`, `appendBitmapByte()`, `appendBitmapWidget()`
- **Paper Control:** `appendCutPaper()`, `feedLine()`
- **Styling:** `setBold()`, `setMagnification()`, `setEncoding()`
- **Convenience:** `addReceiptHeader()`, `addItemLine()`, `addTotalLine()`

**Important:** Commands are stored as `List<Map<String, dynamic>>` and sent to native platform.

### 3. Models

#### ConnectionSettings
```dart
class ConnectionSettings {
  final InterfaceType interfaceType;  // lan, bluetooth, bluetoothLE, usb
  final String identifier;             // MAC, IP, or USB identifier
}
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

  bool get hasError => !online || coverOpen || paperEmpty;
}
```

### 4. Android Native Implementation

**Location:** `android/src/main/kotlin/.../StarMicronicsPrinterPlugin.kt`
**SDK:** Star Micronics StarIO10 SDK
**Concurrency:** Kotlin Coroutines with CoroutineScope

**Method Handlers:**
- `searchPrinters` → StarDeviceDiscoveryManager
- `getStatus` → StarPrinter.getStatusAsync()
- `print` → Raw StarXpand command printing
- `printCommands` → Processes command list into StarXpandCommandBuilder
- `openCashDrawer` → Drawer control

**Key Implementation Details:**
- Uses `scope.launch` for async operations
- `withContext(Dispatchers.IO)` for printer I/O
- Opens printer connection → executes command → closes connection
- Command processing in `processCommands()` function maps Dart commands to StarIO10 SDK

---

## Development Workflows

### Setting Up Development Environment

1. **Flutter/Dart Setup:**
   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

2. **Android Development:**
   - Ensure Android SDK with API 24-36
   - StarIO10 SDK (add to gradle dependencies if not auto-resolved)
   - Kotlin 2.1.0 or higher

3. **iOS Development:**
   - ⚠️ iOS implementation is incomplete
   - Requires StarIO10 SDK for iOS
   - Current stub only returns platform version

### Running the Example App

```bash
cd example
flutter run
```

**Example App Features:**
- Search for printers on network/Bluetooth/USB
- Select printer from discovered list
- Test print receipt with items and totals
- Print barcodes (Code128)
- Print QR codes
- Print styled text (bold, magnified, inverted)
- Check printer status
- Open cash drawer

### Testing

**Unit Tests:**
```bash
flutter test
```

**Integration Tests:**
```bash
cd example
flutter test integration_test/
```

**Android Native Tests:**
```bash
cd android
./gradlew test
```

### Adding New Print Commands

1. **Add enum to `lib/src/models/enums.dart`** (if needed)
2. **Add method to `PrintCommands` class** in `lib/src/print_commands.dart`
3. **Update `processCommands()` in Android plugin** to handle new command
4. **Add iOS implementation** in Swift (when iOS support is added)
5. **Update example app** with demo of new feature
6. **Write tests** for new functionality

**Example:**
```dart
// 1. Add to PrintCommands
PrintCommands appendCustomCommand(String data) {
  _commands.add({'customCommand': data});
  return this;
}

// 2. Add to Android processCommands()
cmd.containsKey("customCommand") -> {
  val data = cmd["customCommand"] as String
  // Use StarIO10 SDK to execute custom command
  builder.actionCustom(data)
}
```

---

## Coding Conventions

### Dart/Flutter Conventions

1. **Follow Flutter Lints:**
   - Uses `package:flutter_lints/flutter.yaml`
   - Run `flutter analyze` before commits

2. **Naming:**
   - Classes: `PascalCase`
   - Methods/variables: `camelCase`
   - Constants: `camelCase` with `const`
   - Enums: `camelCase` values, `PascalCase` type

3. **Documentation:**
   - All public APIs should have doc comments
   - Use triple-slash `///` for documentation
   - Include code examples in doc comments

4. **Async Patterns:**
   - Always use `async`/`await` for async operations
   - Handle `PlatformException` for method channel calls
   - Return bool for success/failure, nullable types for data

5. **Fluent API:**
   - Return `this` from builder methods
   - Chain methods for readable code
   - Use named parameters for optional params

### Kotlin Conventions (Android)

1. **Coroutines:**
   - Use `scope.launch` for async operations
   - `withContext(Dispatchers.IO)` for I/O operations
   - `withContext(Dispatchers.Main)` for Flutter results

2. **Error Handling:**
   - Wrap operations in try-catch
   - Return `result.error(code, message, null)` for errors
   - Use descriptive error codes: `"SEARCH_ERROR"`, `"PRINT_ERROR"`

3. **Resource Management:**
   - Always close printer connections: `printer.closeAsync().await()`
   - Cancel coroutine scope in `onDetachedFromEngine`

4. **Type Safety:**
   - Use nullable types appropriately
   - Safe casts with `as?`
   - Provide defaults for nullable arguments

### Platform Channel Data Format

**Dart → Native:**
```dart
{
  'interfaceType': 'lan',
  'identifier': '192.168.1.100',
  'timeout': 10000,
  'commands': [
    {'appendText': 'Hello\n'},
    {'setAlignment': 'center'},
    {'appendBarcode': '123456', 'symbology': 'code128'}
  ]
}
```

**Native → Dart:**
```dart
// Printer info
{
  'model': 'TSP100',
  'identifier': '192.168.1.100',
  'interfaceType': 'lan',
  'emulation': 'StarLine'
}

// Status
{
  'online': true,
  'coverOpen': false,
  'paperEmpty': false,
  'paperNearEmpty': false,
  'drawerOpen': false
}
```

---

## Platform-Specific Notes

### Android Implementation Status: ✅ Complete

**Implemented Features:**
- ✅ Printer discovery (LAN, Bluetooth, USB)
- ✅ Status monitoring
- ✅ Text printing with styles
- ✅ Barcode printing
- ✅ QR code printing
- ✅ Image printing (from byte array)
- ✅ Paper control (cut, feed)
- ✅ Cash drawer control
- ✅ Alignment and magnification
- ⚠️ **Partially implemented:** Not all PrintCommands methods mapped yet

**Missing Command Mappings:**
- Text underline/invert styles
- Logo printing
- PDF417 barcodes
- Black mark control
- Font style/encoding changes
- Character/line spacing
- Position commands (absolute/relative)

**Dependencies:**
```gradle
// Note: StarIO10 SDK dependency not explicitly shown in build.gradle
// May need to be added manually or via AAR/Maven
```

### iOS Implementation Status: ⚠️ Stub Only

**Current State:**
- Only `getPlatformVersion` implemented
- Requires full implementation using StarIO10 SDK for iOS
- Structure in place: `ios/Classes/StarMicronicsPrinterPlugin.swift`

**TODO for iOS:**
1. Add StarIO10 SDK via CocoaPods
2. Implement method channel handlers
3. Map command structures to iOS SDK
4. Test on physical iOS devices with Star printers

### Windows Implementation Status: ⚠️ C API Stub

**Current State:**
- C++ plugin structure exists
- No actual printer functionality
- Would require Windows-compatible Star SDK

---

## Testing Strategy

### Unit Tests
- Test model serialization (`toMap()`, `fromMap()`)
- Test enum conversions
- Mock method channel for API tests

### Integration Tests
- Requires physical Star Micronics printer
- Test printer discovery
- Test actual print jobs
- Verify status reporting

### Manual Testing Checklist
- [ ] Printer discovery via LAN
- [ ] Printer discovery via Bluetooth
- [ ] Printer discovery via USB
- [ ] Print simple text receipt
- [ ] Print receipt with barcodes
- [ ] Print receipt with QR codes
- [ ] Print with various text styles
- [ ] Print images
- [ ] Check printer status
- [ ] Open cash drawer
- [ ] Handle printer offline scenarios
- [ ] Handle paper empty scenarios
- [ ] Handle cover open scenarios

---

## Common Tasks for AI Assistants

### 1. Adding iOS Support

**Current Priority:** HIGH (iOS is not implemented)

Steps:
1. Add StarIO10 SDK to `ios/star_micronics_printer.podspec`
2. Implement method handlers in `ios/Classes/StarMicronicsPrinterPlugin.swift`
3. Mirror Android implementation structure
4. Handle iOS-specific async patterns (callbacks or async/await)
5. Test on physical devices

### 2. Completing Android Command Mapping

**Location:** `android/src/main/kotlin/.../StarMicronicsPrinterPlugin.kt:168`

The `processCommands()` function needs additional case handlers for:
- `appendTextUnderline`
- `appendTextInvert`
- `setEncoding`
- `setCodePage`
- `setInternationalCharacter`
- `appendPdf417`
- `appendLogo`
- `setAbsolutePosition`
- `setRelativePosition`

Refer to StarIO10 SDK documentation for corresponding Android API calls.

### 3. Adding New Printer Models

**Location:** `lib/src/models/star_printer_model.dart`

Add new models to the enum and `fromString()` method.

### 4. Improving Error Handling

Current implementation swallows errors and returns `false` or `null`.
Consider adding detailed error objects:

```dart
class PrinterError {
  final String code;
  final String message;
  final dynamic details;
}
```

### 5. Adding Print Job Queue

For high-volume printing, consider implementing a queue system:
- Queue print jobs in memory
- Process sequentially to avoid connection conflicts
- Provide job status callbacks

### 6. Widget to Image Conversion

The `createImageFromWidget()` helper in `print_commands.dart:482` is powerful but complex.
When modifying:
- Test across different screen densities
- Verify aspect ratio preservation
- Handle async rendering delays

---

## Important Implementation Notes

### Method Channel Communication

**Channel Name:** `'star_micronics_printer'`

**All communication is async** - use `await` on Flutter side, return `result.success()` or `result.error()` on native side.

### Printer Connection Lifecycle

Every print operation follows this pattern:
1. Create `StarConnectionSettings` from `ConnectionSettings`
2. Instantiate `StarPrinter`
3. `printer.openAsync().await()`
4. Execute commands
5. `printer.closeAsync().await()` ← **Critical: Always close!**

Failure to close connections can cause printer locks.

### Command Builder Pattern

`PrintCommands` uses a fluent API. Commands are accumulated in `_commands` list and sent as a batch to native platform. Each native platform interprets the command maps differently.

**Key:** The Dart side is platform-agnostic. Platform-specific SDK calls happen only on native side.

### Encoding and Internationalization

Text encoding is handled via:
- `setEncoding(StarEncoding)` - Character encoding (UTF-8, Shift-JIS, etc.)
- `setCodePage(StarCodePageType)` - Code page selection
- `setInternationalCharacter(StarInternationalType)` - Regional character sets

**Note:** Not all combinations work on all printer models. Test with target hardware.

---

## Debugging Tips

### Android Debugging

1. **Enable verbose logging:**
   ```kotlin
   import android.util.Log
   Log.d("StarPrinter", "Debug message here")
   ```

2. **Check printer connectivity:**
   - Ensure printer is on same network (for LAN)
   - Verify Bluetooth permissions in AndroidManifest.xml
   - USB requires USB host mode support

3. **Common errors:**
   - `SEARCH_ERROR`: Network timeout, check firewall
   - `PRINT_ERROR`: Printer offline, check connection
   - `STATUS_ERROR`: Printer not responding

### Flutter Debugging

1. **Check method channel calls:**
   ```dart
   debugPrint('Calling searchPrinters...');
   final printers = await StarMicronicsPrinter.searchPrinters();
   debugPrint('Found ${printers.length} printers');
   ```

2. **Inspect command structures:**
   ```dart
   final commands = PrintCommands().appendText('Test\n');
   debugPrint(commands.getCommands().toString());
   ```

### Network Printer Discovery

Star printers typically respond to discovery on port 9100 (LAN). Ensure:
- Printer has static IP or DHCP reservation
- No firewall blocking port 9100
- Printer on same subnet

---

## Dependencies and SDK Requirements

### Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  plugin_platform_interface: ^2.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Android Dependencies
- StarIO10 SDK (not explicitly in build.gradle - may require manual integration)
- Kotlin Coroutines (implied, may need explicit declaration)

### iOS Dependencies (when implemented)
- StarIO10 SDK via CocoaPods
- Swift 5.0+

---

## Git Workflow

### Current Branch
- **Development Branch:** `claude/claude-md-mhzqb5izx3ak9fxa-01Vu6e7eLKvRR3zW8XYrE4db`

### Committing Changes
1. Test changes thoroughly
2. Run `flutter analyze` and fix issues
3. Format code: `dart format .`
4. Commit with descriptive message
5. Push to feature branch

### Pull Request Guidelines
- Describe what changed and why
- Include test results
- Note any breaking changes
- Update CHANGELOG.md

---

## Future Enhancements

### High Priority
1. ✅ **Complete iOS implementation**
2. ✅ **Complete Android command mapping**
3. Add error callback system
4. Add print job queue
5. Improve documentation with more examples

### Medium Priority
6. Add printer configuration management
7. Support for saved printer profiles
8. Receipt template system
9. Add more barcode symbologies
10. Improve status polling/monitoring

### Low Priority
11. Windows implementation
12. Linux support
13. Web support (if feasible)
14. Printer firmware update support

---

## Resources

### Star Micronics Documentation
- [StarIO10 SDK Documentation](https://star-m.jp/products/s_print/sdk/starxpand/manual/en/)
- [Star Printer Models](https://www.starmicronics.com/products/)

### Flutter Plugin Development
- [Developing packages & plugins](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [Platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels)

### Testing
- [Flutter testing guide](https://docs.flutter.dev/testing)
- [Integration testing](https://docs.flutter.dev/testing/integration-tests)

---

## Contact and Support

**Package:** com.phonetechbd.star_micronics_printer
**Version:** 0.0.1 (Initial development)
**License:** TODO (see LICENSE file)

For issues and feature requests, refer to the project repository.

---

## Quick Reference for AI Assistants

**When asked to:**

- **Add a print feature** → Modify `PrintCommands` + update `processCommands()` in Android plugin
- **Fix iOS** → Implement handlers in `StarMicronicsPrinterPlugin.swift` using StarIO10 iOS SDK
- **Debug printing issues** → Check printer connection, status, and command structure
- **Add printer model** → Update `star_printer_model.dart` enum
- **Improve examples** → Modify `example/lib/main.dart`
- **Write tests** → Add to `test/` directory, follow existing test patterns
- **Update docs** → Update this CLAUDE.md file and inline documentation

**Key Files:**
- API: `lib/src/star_micronics_printer.dart`
- Commands: `lib/src/print_commands.dart`
- Android: `android/src/main/kotlin/.../StarMicronicsPrinterPlugin.kt`
- iOS: `ios/Classes/StarMicronicsPrinterPlugin.swift`
- Example: `example/lib/main.dart`

---

*Last Updated: 2025-11-15*
*This document should be updated whenever significant architectural changes are made.*
