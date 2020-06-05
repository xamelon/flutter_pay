part of '../flutter_pay.dart';

class PaymentNetwork {
  String _name;

  PaymentNetwork._(this._name);

  /// Available on iOS and Android
  static get visa => PaymentNetwork._("VISA");
  /// Available on iOS and Android
  static get masterCard => PaymentNetwork._("MasterCard");
  /// Available on iOS and Android
  static get amex => PaymentNetwork._("AmericanExpress");
  /// Available on iOS and Android
  static get interac => PaymentNetwork._("Interac");
  /// Available on iOS and Android
  static get discover => PaymentNetwork._("Discover");
  /// Available on iOS and Android
  static get jcb => PaymentNetwork._("JCB");

  /// Available only on iOS
  static get maestro => PaymentNetwork._("Maestro");
  /// Available only on iOS
  static get electron => PaymentNetwork._("Electron");
  /// Available only on iOS
  static get cartesBancarries => PaymentNetwork._("CartesBancarries");
  /// Available only on iOS
  static get unionPay => PaymentNetwork._("UnionPay");
  /// Available only on iOS
  static get eftPos => PaymentNetwork._("EftPos");
  /// Available only on iOS
  static get elo => PaymentNetwork._("Elo");
  /// Available only on iOS
  static get idCredit => PaymentNetwork._("IDCredit");
  /// Available only on iOS
  static get mada => PaymentNetwork._("Mada");
  /// Available only on iOS
  static get privateLabel => PaymentNetwork._("PrivateLabel");
  /// Available only on iOS
  static get quicPay => PaymentNetwork._("QuicPay");
  /// Available only on iOS
  static get suica => PaymentNetwork._("Suica");
  /// Available only on iOS
  static get vPay => PaymentNetwork._("VPay");

  String toJson() => this._name.toUpperCase();
}
