part of flutter_pay;

class FlutterPay {
  final MethodChannel _channel = MethodChannel('flutter_pay');

  /// Switch Google Pay [environment]
  ///
  /// See [PaymentEnvironment]
  Future<void> setEnvironment({PaymentEnvironment environment}) async {
    var params = <String, bool>{
      "isTestEnvironment": environment == PaymentEnvironment.Test,
    };
    _channel.invokeMethod('switchEnvironment', params);
  }

  /// Returns `true` if Apple/ Google Pay is available on device
  Future<bool> canMakePayments() async {
    final canMakePayments = await _channel.invokeMethod('canMakePayments');
    return canMakePayments;
  }

  /// Returns true if Apple/Google Pay is available on device and there is at least one activated card
  ///
  /// You can set allowed payment networks in [allowedPaymentNetworks] parameter.
  /// See [PaymentNetwork]
  Future<bool> canMakePaymentsWithActiveCard({
    List<PaymentNetwork> allowedPaymentNetworks,
  }) async {
    var paymentNetworks =
        allowedPaymentNetworks.map((network) => network.toJson()).toList();
    var params = <String, dynamic>{"paymentNetworks": paymentNetworks};

    final canMakePayments =
        await _channel.invokeMethod('canMakePaymentsWithActiveCard', params);
    return canMakePayments;
  }

  /// Process the payment and returns the token from Apple/Google pay
  ///
  /// Can throw [FlutterPayError]
  ///
  /// * [gatewayName] - affects only Google Pay.
  /// Gateway name which you are using to make payments.
  /// * [merchantIdentifier] - merchant identifier in Apple Pay. 
  /// In Google Pay it "gatewayMerchantId".
  /// * [allowedPaymentNetwork] - List of allowed payment networks. 
  /// See [PaymentNetwork].
  /// * [paymentItems] - affects only Apple Pay. See [PaymentItem]
  /// * [merchantName] - affects only Google Pay. 
  /// Mercant name which will be displayed to customer.
  Future<String> makePayment({
    String gatewayName,
    String merchantIdentifier,
    List<PaymentNetwork> allowedPaymentNetworks = const [],
    List<PaymentItem> paymentItems,
    String currencyCode,
    String countryCode,
    String merchantName,
  }) async {
    var items = paymentItems.map((item) => item.toJson()).toList();

    print("Gateway name: $gatewayName");

    var params = <String, dynamic>{
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
      var payResponse = Map<String, String>.from(rawPayResponse);
      if (payResponse == null) {
        throw FlutterPayError(description: "Pay response cannot be parsed");
      }
      var paymentToken = payResponse["token"];
      var error = payResponse["error"];
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
