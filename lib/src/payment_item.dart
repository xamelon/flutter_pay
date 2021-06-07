part of flutter_pay;

class PaymentItem {
  final String name;
  final double price;

  PaymentItem({required this.name, required this.price});

  Map<String, String> toJson() => {
        "name": name,
        "price": price.toStringAsFixed(2),
      };
}
