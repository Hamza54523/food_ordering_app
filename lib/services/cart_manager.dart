import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _localCartItems = [];

  CartManager._internal();

  // Local cart methods (for offline support)
  List<Map<String, dynamic>> get cartItems => _localCartItems;

  void addItem(Map<String, dynamic> item) {
    final existingIndex = _localCartItems.indexWhere((i) => i['id'] == item['id']);
    if (existingIndex != -1) {
      _localCartItems[existingIndex]['quantity'] =
          (_localCartItems[existingIndex]['quantity'] as int) + 1;
    } else {
      final newItem = Map<String, dynamic>.from(item);
      newItem['quantity'] = 1;
      _localCartItems.add(newItem);
    }
  }

  void removeItem(String id) {
    _localCartItems.removeWhere((i) => i['id'] == id);
  }

  void updateQuantity(String id, int newQuantity) {
    final idx = _localCartItems.indexWhere((i) => i['id'] == id);
    if (idx != -1) {
      if (newQuantity <= 0) removeItem(id);
      else _localCartItems[idx]['quantity'] = newQuantity;
    }
  }

  double get totalPrice {
    return _localCartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * (item['quantity'] as int));
    });
  }

  int get itemCount {
    return _localCartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  void clear() => _localCartItems.clear();

  // Sync local cart with Firestore (for offline to online transition)
  Future<void> syncLocalCartToFirestore() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _localCartItems.isEmpty) return;

    for (var item in _localCartItems) {
      final existingQuery = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: userId)
          .where('foodItemId', isEqualTo: item['id'])
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final docId = existingQuery.docs.first.id;
        final currentQuantity = existingQuery.docs.first['quantity'] as int;
        await _firestore.collection('cart_items').doc(docId).update({
          'quantity': currentQuantity + (item['quantity'] as int),
          'updatedAt': DateTime.now(),
        });
      } else {
        await _firestore.collection('cart_items').add({
          'userId': userId,
          'foodItemId': item['id'],
          'foodName': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
          'imageUrl': item['image'] ?? '',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
      }
    }

    // Clear local cart after sync
    _localCartItems.clear();
  }

  // Load Firestore cart to local (for offline use)
  Future<void> loadFirestoreCartToLocal() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartItems = await _firestore
        .collection('cart_items')
        .where('userId', isEqualTo: userId)
        .get();

    _localCartItems.clear();
    for (var doc in cartItems.docs) {
      final data = doc.data();
      _localCartItems.add({
        'id': data['foodItemId'],
        'name': data['foodName'],
        'price': data['price'],
        'quantity': data['quantity'],
        'image': data['imageUrl'],
      });
    }
  }
}