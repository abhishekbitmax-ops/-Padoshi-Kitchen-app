class CartItem {
  final String name;
  final String image;
  final int price;
  int qty;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
  });
}

List<CartItem> cartItems = [];


class AddressModel {
  final String label;
  final String fullAddress;

  AddressModel({
    required this.label,
    required this.fullAddress,
  });
}
