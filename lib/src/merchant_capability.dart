part of flutter_pay;

///The capability3DS and capabilityEMV values of PKMerchantCapability specify
///the supported cryptographic payment protocols. At least one of these two
///values is required.
///Check with your payment processors about the cryptographic payment protocols
///they support. As a general rule, if you want to support China UnionPay
///cards, you use capabilityEMV. To support cards from other networks—like
///American Express, Visa, or Mastercard—use capability3DS.
///To filter the types of cards to make available for the transaction, pass the
///capabilityCredit and capabilityDebit values. If neither is passed, all card
///types will be available.
class MerchantCapability {
  final String _name;

  MerchantCapability._(this._name);

  ///Support for debit cards.
  static MerchantCapability get debit =>
      MerchantCapability._(".capabilityDebit");

  ///Support for credit cards.
  static MerchantCapability get credit =>
      MerchantCapability._(".capabilityCredit");

  ///Support for the 3-D Secure protocol.
  static MerchantCapability get threeDS =>
      MerchantCapability._(".capability3DS");

  ///Support for the 3-D Secure protocol.
  static MerchantCapability get emv => MerchantCapability._(".capabilityEMV");

  /// Get merchant capabilties name
  String get getName => _name.toUpperCase();
}
