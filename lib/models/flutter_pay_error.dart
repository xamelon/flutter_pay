part of '../flutter_pay.dart';

class FlutterPayError extends Error {
  String description;

  FlutterPayError({this.description});
}
