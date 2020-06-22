part of flutter_pay;

class PaymentNetwork {
  final String _name;

  PaymentNetwork._(this._name);

  /// Available on iOS and Android
  static PaymentNetwork get visa => PaymentNetwork._("VISA");

  /// Available on iOS and Android
  static PaymentNetwork get masterCard => PaymentNetwork._("MasterCard");

  /// Available on iOS and Android
  static PaymentNetwork get amex => PaymentNetwork._("AmericanExpress");

  /// Available on iOS and Android
  static PaymentNetwork get interac => PaymentNetwork._("Interac");

  /// Available on iOS and Android
  static PaymentNetwork get discover => PaymentNetwork._("Discover");

  /// Available on iOS and Android
  static PaymentNetwork get jcb => PaymentNetwork._("JCB");

  /// Available only on iOS
  static PaymentNetwork get maestro => PaymentNetwork._("Maestro");

  /// Available only on iOS
  static PaymentNetwork get electron => PaymentNetwork._("Electron");

  /// Available only on iOS
  static PaymentNetwork get cartesBancarries =>
      PaymentNetwork._("CartesBancarries");

  /// Available only on iOS
  static PaymentNetwork get unionPay => PaymentNetwork._("UnionPay");

  /// Available only on iOS
  static PaymentNetwork get eftPos => PaymentNetwork._("EftPos");

  /// Available only on iOS
  static PaymentNetwork get elo => PaymentNetwork._("Elo");

  /// Available only on iOS
  static PaymentNetwork get idCredit => PaymentNetwork._("IDCredit");

  /// Available only on iOS
  static PaymentNetwork get mada => PaymentNetwork._("Mada");

  /// Available only on iOS
  static PaymentNetwork get privateLabel => PaymentNetwork._("PrivateLabel");

  /// Available only on iOS
  static PaymentNetwork get quicPay => PaymentNetwork._("QuicPay");

  /// Available only on iOS
  static PaymentNetwork get suica => PaymentNetwork._("Suica");

  /// Available only on iOS
  static PaymentNetwork get vPay => PaymentNetwork._("VPay");

  /// Get payment networks name
  String get getName => _name.toUpperCase();
}
