import 'package:flutter_test/flutter_test.dart';
import 'package:star_micronics_printer/star_micronics_printer.dart';
import 'package:star_micronics_printer/star_micronics_printer_platform_interface.dart';
import 'package:star_micronics_printer/star_micronics_printer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStarMicronicsPrinterPlatform
    with MockPlatformInterfaceMixin
    implements StarMicronicsPrinterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StarMicronicsPrinterPlatform initialPlatform = StarMicronicsPrinterPlatform.instance;

  test('$MethodChannelStarMicronicsPrinter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStarMicronicsPrinter>());
  });

  test('getPlatformVersion', () async {
    StarMicronicsPrinter starMicronicsPrinterPlugin = StarMicronicsPrinter();
    MockStarMicronicsPrinterPlatform fakePlatform = MockStarMicronicsPrinterPlatform();
    StarMicronicsPrinterPlatform.instance = fakePlatform;

    expect(await starMicronicsPrinterPlugin.getPlatformVersion(), '42');
  });
}
