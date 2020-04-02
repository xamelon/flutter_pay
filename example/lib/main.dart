import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pay/flutter_pay.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterPay flutterPay = FlutterPay();

  @override
  void initState() {
    super.initState();
  }

  void makePayment() async {
    List<PaymentItem> items = [
      PaymentItem(name: "Маргарита 30 см", price: 30.0)
    ];

    flutterPay.makePayment(
        merchantIdentifier: "dominospizza1",
        currencyCode: "RUB",
        countryCode: "RU",
        paymentItems: items,
        gatewayName: "sberbank");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Column(children: [
            FlatButton(
              child: Text("Can make payments?"),
              onPressed: () async {
                bool result = await flutterPay.canMakePayments;
                print("Can make payments: $result");
              },
            ),
            FlatButton(
                child: Text("Try to pay?"),
                onPressed: () {
                  makePayment();
                })
          ]),
        ),
      ),
    );
  }
}
