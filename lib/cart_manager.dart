class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addItem(Map<String, dynamic> item) {
    // item expected to contain: id, name, price, image (optional)
    final existingIndex = _cartItems.indexWhere((i) => i['id'] == item['id']);
    if (existingIndex != -1) {
      // already in cart -> increase quantity
      _cartItems[existingIndex]['quantity'] =
          (_cartItems[existingIndex]['quantity'] as int) + 1;
    } else {
      final newItem = Map<String, dynamic>.from(item);
      newItem['quantity'] = 1;
      _cartItems.add(newItem);
    }
  }

  void removeItem(int id) {
    _cartItems.removeWhere((i) => i['id'] == id);
  }

  void updateQuantity(int id, int newQuantity) {
    final idx = _cartItems.indexWhere((i) => i['id'] == id);
    if (idx != -1) {
      if (newQuantity <= 0) removeItem(id);
      else _cartItems[idx]['quantity'] = newQuantity;
    }
  }

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * (item['quantity'] as int));
    });
  }

  int get itemCount {
    return _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  void clear() => _cartItems.clear();
}
