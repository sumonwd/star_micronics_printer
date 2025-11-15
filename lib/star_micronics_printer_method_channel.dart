import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'star_micronics_printer_platform_interface.dart';

/// An implementation of [StarMicronicsPrinterPlatform] that uses method channels.
class MethodChannelStarMicronicsPrinter extends StarMicronicsPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('star_micronics_printer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
