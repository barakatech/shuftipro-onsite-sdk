import 'dart:async';
import 'package:flutter/services.dart';

// Shuftipro main class or entry point to perform verification.
class ShuftiproSdk {
  static const MethodChannel _platform = MethodChannel('com.example.package_sample/sendAndroid');
  // This is the main bridging function which is called by user's application and forwards the call to native SDK modules.
  static Future<String> sendRequest({
    required Map<String, Object> authObject,
    required Map<String, Object> createdPayload,
    required Map<String, Object> configObject,
  }) async {
    String value = "";

    // The following piece of code will invoke the native modules depending upon user's device's platform
    try {
      value = await _platform.invokeMethod('sendRequest', <String, dynamic>{
        'AuthObj': authObject,
        'RequestObj': createdPayload,
        'ConfigObj': configObject,
      });
      // Print your response here like this
    } catch (e) {
      // doSomething(e);
    }
    return value;
  }


  static Future<String> registerRequest({
    required String clientId,
    required String customerId,
    required Map<String, Object> configObject,
  }) async {
    String value = "";

    // The following piece of code will invoke the native modules depending upon user's device's platform
    try {
      value = await _platform.invokeMethod('registerRequest', <String, dynamic>{
        'clientIdObj': clientId,
        'customerIdObj': customerId,
        'ConfigObj': configObject,
      });
      // Print your response here like this
    } catch (e) {
      // doSomething(e);
    }
    return value;
  }
}
