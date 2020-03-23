import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pay/models/payment_item.dart';

export 'package:flutter_pay/models/payment_item.dart';

class FlutterPay {
  static const MethodChannel _channel = const MethodChannel('flutter_pay');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> get canMakePayments async {
    final bool canMakePayments = await _channel.invokeMethod('canMakePayments');
    return canMakePayments;
  }

  Future<void> requestPayment({String merchantIdentifier, String currencyCode, String countryCode, List<PaymentItem> paymentItems}) async {

    List<Map<String, String>> items = paymentItems.map((item) => item.toJson());

    Map<String, dynamic> params = {
      "merchantIdentifier": merchantIdentifier,
      "currencCode": currencyCode,
      "countryCode": countryCode,
      "items": items,
    };
    await _channel.invokeMethod('requestPayment', params);
  }
}
