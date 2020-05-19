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

  String result = "Result will be shown here";

  @override
  void initState() {
    super.initState();
  }

  void makePayment() async {
    List<PaymentItem> items = [
      PaymentItem(name: "Маргарита 30 см", price: 30.0)
    ];

    flutterPay.makePayment(
        merchantIdentifier: "_",
        currencyCode: "RUB",
        countryCode: "RU",
        paymentItems: items,
        gatewayName: "_");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.space_between,
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
                      bool result = await flutterPay.canMakePayments;
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
