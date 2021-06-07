part of flutter_pay;

class CardAuthMethods {
  final String _name;

  CardAuthMethods._(this._name);

  ///Cards on file on Google.com linked to user account
  static CardAuthMethods get panOnly => CardAuthMethods._("PAN_ONLY");

  ///Device token on an Android device authenticated
  ///with a 3-D Secure cryptogram
  static CardAuthMethods get cryptogram3ds =>
      CardAuthMethods._("CRYPTOGRAM_3DS");

  /// Get payment networks name
  String get getName => _name.toUpperCase();
}
