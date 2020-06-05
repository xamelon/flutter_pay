part of flutter_pay;

class PaymentItem {
  String name;
  double price;

  PaymentItem({this.name, this.price});

  Map<String, String> toJson() => {
        "name": name,
        "price": "$price",
      };
}
