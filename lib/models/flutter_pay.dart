import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_pay/models/payment_item.dart';
import 'package:flutter_pay/models/flutter_pay_error.dart';

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

  Future<String> makePayment(
      {String merchantIdentifier,
      String currencyCode,
      String countryCode,
      List<PaymentItem> paymentItems}) async {
    List<Map<String, String>> items =
        paymentItems.map((item) => item.toJson()).toList();

    Map<String, dynamic> params = {
      "merchantIdentifier": merchantIdentifier,
      "currencyCode": currencyCode,
      "countryCode": countryCode,
      "items": items,
    };
    Map<String, String> payResponse =
        await _channel.invokeMethod('requestPayment', params);
    String paymentToken = payResponse["token"];
    String error = payResponse["error"];
    print("Payment token: $paymentToken");
    print("Error: $error");
    if (paymentToken != null) {
      print("Payment token: $paymentToken");
      return paymentToken;
    }
    if (error != null) {
      throw FlutterPayError(description: error);
    }
  }
}
