part of flutter_pay;

// https://developers.google.com/pay/api/web/reference/request-objects#gateway
class GoogleParameters {
  final String gatewayName;
  final String gatewayMerchantId;
  final Map<String, dynamic> gatewayArgs;
  final String merchantName;

  GoogleParameters({
    @required this.gatewayName,
    this.gatewayMerchantId,
    this.gatewayArgs,
    this.merchantName,
  }) : assert(
          gatewayMerchantId != null || gatewayArgs != null,
          throw FlutterPayError(description: ""),
        );

  Map<String, dynamic> toMap() {
    var map = {
      'gatewayName': gatewayName,
      'merchantName': merchantName,
    };

    if(gatewayMerchantId != null) {
       map.addAll({'gatewayMerchantId': gatewayMerchantId});
    } else {
      map.addAll(gatewayArgs);
    }

    return map;
  }
}
