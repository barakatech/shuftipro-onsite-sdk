import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuftipro_onsite_sdk/shuftipro_onsite_sdk.dart';

void main() {
  // const MethodChannel channel = MethodChannel('kyc_plugin');
  const MethodChannel channel =
      MethodChannel('com.example.package_sample/sendAndroid');
  // const MethodChannel channel_ios = MethodChannel('com.example.package_sample/sendios');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await KycPlugin.platformVersion, '42');
  // });
  test('sendRequest', () async {
    expect(
        await ShuftiproSdk.sendRequest(
            authObject: {}, createdPayload: {}, configObject: {}),
        '42');
  });
}
