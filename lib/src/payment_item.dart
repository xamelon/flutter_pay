part of flutter_pay;

class PaymentItem {
  final String name;
  final double price;

  PaymentItem({this.name, this.price});

  Map<String, String> toJson() => {
        "name": name,
        "price": price.toStringAsFixed(2),
      };
}
