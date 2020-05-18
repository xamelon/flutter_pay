class PaymentNetwork {
  String _name;

  PaymentNetwork._(this._name);

  /// These networks available on Google Pay and Apple Pay

  static get visa => PaymentNetwork._("VISA");
  static get masterCard => PaymentNetwork._("MasterCard");
  static get amex => PaymentNetwork._("AmericanExpress");
  static get interac => PaymentNetwork._("Interac");
  static get discover => PaymentNetwork._("Discover");
  static get jcb => PaymentNetwork._("JCB");

  /// These networks available only on Apple Pay

  static get maestro => PaymentNetwork._("Maestro");
  static get electron => PaymentNetwork._("Electron");
  static get cartesBancarries => PaymentNetwork._("CartesBancarries");
  static get unionPay => PaymentNetwork._("UnionPay");
  static get eftPos => PaymentNetwork._("EftPos");
  static get elo => PaymentNetwork._("Elo");
  static get idCredit => PaymentNetwork._("IDCredit");
  static get mada => PaymentNetwork._("Mada");
  static get privateLabel => PaymentNetwork._("PrivateLabel");
  static get quicPay => PaymentNetwork._("QuicPay");
  static get suica => PaymentNetwork._("Suica");
  static get vPay => PaymentNetwork._("VPay");

  String toJson() => this._name.toUpperCase();
}
