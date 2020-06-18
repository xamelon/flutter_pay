import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_pay/flutter_pay.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterPay flutterPay = FlutterPay();

  String result = "Result will be shown here";

  @override
  void initState() {
    super.initState();
  }

  void makePayment() async {
    List<PaymentItem> items = [
      PaymentItem(name: "Маргарита 30 см", price: 30.0)
    ];

    if (Platform.isAndroid) {
      flutterPay.makePayment(
        // https://developers.google.com/pay/api/web/reference/request-objects#gateway
        gatewayName: "",
        merchantIdentifier: "",
        currencyCode: "RUB",
        countryCode: "RU",
        paymentItems: items,
      ).then((v) {
        print(v);
      }).catchError((e) {
        print(e);
      });
    } else if (Platform.isIOS) {
      flutterPay.makePayment(
        merchantIdentifier: "merchant.flutterpay.example",
        currencyCode: "RUB",
        countryCode: "RU",
        paymentItems: items,
      ).then((v) {
        print(v);
      }).catchError((e) {
        print(e);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  this.result,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                FlatButton(
                  child: Text("Can make payments?"),
                  onPressed: () async {
                    try {
                      bool result = await flutterPay.canMakePayments();
                      setState(() {
                        this.result = "Can make payments: $result";
                      });
                    } catch (e) {
                      setState(() {
                        this.result = "$e";
                      });
                    }
                  },
                ),
                FlatButton(
                  child: Text("Can make payments with verified card: $result"),
                  onPressed: () async {
                    try {
                      bool result =
                          await flutterPay.canMakePaymentsWithActiveCard(
                        allowedPaymentNetworks: [
                          PaymentNetwork.visa,
                          PaymentNetwork.masterCard,
                        ],
                      );
                      setState(() {
                        this.result = "$result";
                      });
                    } catch (e) {
                      setState(() {
                        this.result = "Error: $e";
                      });
                    }
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
