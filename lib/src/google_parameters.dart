part of flutter_pay;

// https://developers.google.com/pay/api/web/reference/request-objects#gateway
class GoogleParameters {
  final String gatewayName;
  final String? gatewayMerchantId;
  final Map<String, dynamic>? gatewayArgs;
  final String? merchantId;
  final String? merchantName;
  final List<CardAuthMethods> allowedCardAuthMethods;

  GoogleParameters(
      {required this.gatewayName,
      this.gatewayMerchantId,
      this.gatewayArgs,
      this.merchantId,
      this.merchantName,
      this.allowedCardAuthMethods = const []})
      : assert(
          ((gatewayMerchantId != null) ^ (gatewayArgs != null)),
          "You can not use gatewayMerchantId and gatewayArgs at the same time",
        );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'gatewayName': gatewayName,
    };

    if (merchantId != null) {
      map["merchantId"] = merchantId!;
    }

    if (merchantName != null) {
      map["merchantName"] = merchantName!;
    }

    map["allowedAuthMethods"] =
        allowedCardAuthMethods.map((method) => method.getName).toList();

    if (gatewayMerchantId != null) {
      map.addAll({'gatewayMerchantId': gatewayMerchantId!});
    }
    if (gatewayArgs != null) {
      map.addAll(gatewayArgs!);
    }

    return map;
  }
}
