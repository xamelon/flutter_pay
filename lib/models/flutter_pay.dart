import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_pay/models/payment_item.dart';
import 'package:flutter_pay/models/flutter_pay_error.dart';
import 'package:flutter_pay/models/payment_network.dart';
import 'package:flutter_pay/models/payment_environment.dart';

class FlutterPay {
  final MethodChannel _channel = MethodChannel('flutter_pay');

  /// Switch Google Pay environment
  Future<void> setEnvironment({PaymentEnvironment environment}) async {

    Map<String, bool> params = {
      "isTestEnvironment": environment == PaymentEnvironment.Test,
    };
    _channel.invokeMethod('switchEnvironment', params);
  }

  /// Returns true if Apple/ Google Pay is available on device
  Future<bool> get canMakePayments async {
  Future<bool> canMakePayments() async {
    final bool canMakePayments = await _channel.invokeMethod('canMakePayments');
    return canMakePayments;
  }

  /// Returns true if Apple/Google Pay is available on device
  /// and there is at least one activated card
  /// with payment networks
  Future<bool> canMakePaymentsWithActiveCard({
    List<PaymentNetwork> allowedPaymentNetworks,
  }) async {
    List<String> paymentNetworks =
        allowedPaymentNetworks.map((network) => network.toJson()).toList();
    Map<String, dynamic> params = {"paymentNetworks": paymentNetworks};

    final bool canMakePayments =
        await _channel.invokeMethod('canMakePaymentsWithActiveCard', params);
    return canMakePayments;
  }

  Future<String> makePayment(
      {String merchantIdentifier,
      String currencyCode,
      String countryCode,
      List<PaymentNetwork> allowedPaymentNetworks = const [],
      List<PaymentItem> paymentItems,
      String merchantName,
      String gatewayName}) async {
    List<Map<String, String>> items =
        paymentItems.map((item) => item.toJson()).toList();

    print("Gateway name: $gatewayName");

    Map<String, dynamic> params = {
      "gateway": gatewayName,
      "merchantIdentifier": merchantIdentifier,
      "currencyCode": currencyCode,
      "countryCode": countryCode,
      "merchantName": merchantName,
      "allowedPaymentNetworks":
          allowedPaymentNetworks.map((p) => p.toJson()).toList(),
      "items": items,
    };
    try {
      dynamic rawPayResponse =
          await _channel.invokeMethod('requestPayment', params);
      Map<String, String> payResponse =
          Map<String, String>.from(rawPayResponse);
      if (payResponse == null) {
        throw FlutterPayError(description: "Pay response cannot be parsed");
      }
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
    } on PlatformException catch (e) {
      throw FlutterPayError(description: e.message);
    }
    return "";
  }
}
