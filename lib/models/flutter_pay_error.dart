part of flutter_pay;

class FlutterPayError extends Error {
  String description;

  FlutterPayError({this.description});
}
