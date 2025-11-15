import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/connection_settings.dart';
import 'models/printer_info.dart';
import 'models/printer_status.dart';
import 'print_commands.dart';

class StarMicronicsPrinter {
  static const MethodChannel _channel = MethodChannel('star_micronics_printer');

  /// Search for available Star printers
  static Future<List<PrinterInfo>> searchPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('searchPrinters', {
        'timeout': timeout.inMilliseconds,
      });
      return result.map((e) => PrinterInfo.fromMap(Map<String, dynamic>.from(e))).toList();
    } on PlatformException catch (e) {
      debugPrint('Error searching printers: ${e.message}');
      return [];
    }
  }

  /// Get printer status
  static Future<PrinterStatus?> getStatus(ConnectionSettings settings) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod(
        'getStatus',
        settings.toMap(),
      );
      return PrinterStatus.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Error getting status: ${e.message}');
      return null;
    }
  }

  /// Print using raw StarXpand commands string
  static Future<bool> print({
    required ConnectionSettings settings,
    required String starXpandCommand,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('print', {
        ...settings.toMap(),
        'command': starXpandCommand,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error printing: ${e.message}');
      return false;
    }
  }

  /// Print using PrintCommands builder
  ///
  /// ```dart
  /// final commands = PrintCommands()
  ///   .appendText('Hello\n')
  ///   .appendBarcode(data: '123456', symbology: StarBarcodeSymbology.Code128)
  ///   .appendCutPaper(StarCutPaperAction.PartialCut);
  ///
  /// await StarMicronicsPrinter.printCommands(
  ///   settings: connectionSettings,
  ///   commands: commands,
  /// );
  /// ```
  static Future<bool> printCommands({
    required ConnectionSettings settings,
    required PrintCommands commands,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('printCommands', {
        ...settings.toMap(),
        'commands': commands.getCommands(),
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error printing commands: ${e.message}');
      return false;
    }
  }

  /// Open cash drawer
  static Future<bool> openCashDrawer(ConnectionSettings settings) async {
    try {
      final bool result = await _channel.invokeMethod('openCashDrawer', settings.toMap());
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error opening cash drawer: ${e.message}');
      return false;
    }
  }
}
