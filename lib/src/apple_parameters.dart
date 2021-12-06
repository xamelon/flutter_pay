part of flutter_pay;

class AppleParameters {
  final String merchantIdentifier;
  final List<MerchantCapability>? merchantCapabilities;

  AppleParameters({
    required this.merchantIdentifier,
    this.merchantCapabilities,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantIdentifier': merchantIdentifier,
      'merchantCapabilities':
          merchantCapabilities?.map<String>((e) => e.getName).toList() ?? [],
    };
  }
}
