part of flutter_pay;

class FlutterPayError extends Error {
  final String? description;
  final String? code;

  FlutterPayError({this.code, this.description});

  @override
  String toString() {
    return '''\n
    Error: $code.
    Description: $description''';
  }
}
