import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'star_micronics_printer_method_channel.dart';

abstract class StarMicronicsPrinterPlatform extends PlatformInterface {
  /// Constructs a StarMicronicsPrinterPlatform.
  StarMicronicsPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static StarMicronicsPrinterPlatform _instance = MethodChannelStarMicronicsPrinter();

  /// The default instance of [StarMicronicsPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelStarMicronicsPrinter].
  static StarMicronicsPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StarMicronicsPrinterPlatform] when
  /// they register themselves.
  static set instance(StarMicronicsPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
