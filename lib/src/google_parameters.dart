part of flutter_pay;

// https://developers.google.com/pay/api/web/reference/request-objects#gateway
class GoogleParameters {
  final String gatewayName;
  final String gatewayMerchantId;
  final Map<String, dynamic> gatewayArgs;
  final String merchantId;
  final String merchantName;
  final List<CardAuthMethods> allowedCardAuthMethods;

  GoogleParameters({
    @required this.gatewayName,
    this.gatewayMerchantId,
    this.gatewayArgs,
    this.merchantId,
    this.merchantName,
    List<CardAuthMethods> allowedCardAuthMethods,
  })  : this.allowedCardAuthMethods = allowedCardAuthMethods ?? [],
        assert(
          ((gatewayMerchantId != null) ^ (gatewayArgs != null)),
          "You can not use gatewayMerchantId and gatewayArgs at the same time",
        );

  Map<String, dynamic> toMap() {
    var map = {
      'gatewayName': gatewayName,
      'merchantId': merchantId,
      'merchantName': merchantName,
      "allowedAuthMethods":
          allowedCardAuthMethods.map((method) => method.getName).toList(),
    };

    if (gatewayMerchantId != null) {
      map.addAll({'gatewayMerchantId': gatewayMerchantId});
    } else {
      map.addAll(gatewayArgs);
    }

    return map;
  }
}
