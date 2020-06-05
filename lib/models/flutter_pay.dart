import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_pay/models/payment_item.dart';
import 'package:flutter_pay/models/flutter_pay_error.dart';
import 'package:flutter_pay/models/payment_network.dart';
import 'package:flutter_pay/models/payment_environment.dart';

part of '../flutter_pay.dart';

class FlutterPay {
  final MethodChannel _channel = MethodChannel('flutter_pay');

  /// Switch Google Pay [environment]
  ///
  /// See [PaymentEnvironment]
  Future<void> setEnvironment({PaymentEnvironment environment}) async {

    Map<String, bool> params = {
      "isTestEnvironment": environment == PaymentEnvironment.Test,
    };
    _channel.invokeMethod('switchEnvironment', params);
  }

  /// Returns `true` if Apple/ Google Pay is available on device
  Future<bool> canMakePayments() async {
    final bool canMakePayments = await _channel.invokeMethod('canMakePayments');
    return canMakePayments;
  }

  /// Returns true if Apple/Google Pay is available on device and there is at least one activated card
  ///
  /// You can set allowed payment networks in [allowedPaymentNetworks] parameter. See [PaymentNetwork]
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

  /// Process the payment and returns the token from Apple/Google pay
  ///
  /// Can throw [FlutterPayError]
  ///
  /// * [merchantIdentifier] - merchant identifier in Apple/Google Pay systems
  /// * [allowedPaymentNetwork] - List of allowed payment networks. See [PaymentNetwork]
  /// * [paymentItems] - affects only Apple Pay. See [PaymentItem]
  /// * [merchantName] - affects only Google Pay. Mercant name which will be displayed to customer
  /// * [gatewayName] - affects only Google Pay. Gateway name which you are using to make payments
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
