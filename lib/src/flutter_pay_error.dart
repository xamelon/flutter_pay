part of flutter_pay;

class FlutterPayError extends Error {
  final String description;

  FlutterPayError({this.description});
}
