import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_micronics_printer/star_micronics_printer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelStarMicronicsPrinter platform = MethodChannelStarMicronicsPrinter();
  const MethodChannel channel = MethodChannel('star_micronics_printer');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
