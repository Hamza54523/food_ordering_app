import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _foodItemsRef => _firestore.collection('food_items');
  CollectionReference get _cartItemsRef => _firestore.collection('cart_items');
  CollectionReference get _ordersRef => _firestore.collection('orders');
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _categoriesRef => _firestore.collection('categories');

  // ============ FOOD ITEMS ============
  Stream<List<FoodItem>> getFoodItems() {
    return _foodItemsRef
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<FoodItem>> getFoodItemsByCategory(String category) {
    return _foodItemsRef
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addFoodItem(FoodItem item) async {
    await _foodItemsRef.add(item.toFirestore());
    notifyListeners();
  }

  // ============ CART ITEMS ============
  Stream<List<CartItem>> getCartItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _cartItemsRef.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<int> getCartItemsCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _cartItemsRef.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.fold(0, (sum, doc) => sum + (doc['quantity'] as int));
    });
  }

  Future<void> addToCart(FoodItem foodItem) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Check if item already in cart
    final existingQuery = await _cartItemsRef
        .where('userId', isEqualTo: userId)
        .where('foodItemId', isEqualTo: foodItem.id)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      // Update quantity
      final docId = existingQuery.docs.first.id;
      final currentQuantity = existingQuery.docs.first['quantity'] as int;
      await _cartItemsRef.doc(docId).update({
        'quantity': currentQuantity + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Add new item
      await _cartItemsRef.add({
        'userId': userId,
        'foodItemId': foodItem.id,
        'foodName': foodItem.name,
        'price': foodItem.price,
        'quantity': 1,
        'imageUrl': foodItem.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    notifyListeners();
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await _cartItemsRef.doc(cartItemId).delete();
    } else {
      await _cartItemsRef.doc(cartItemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _cartItemsRef.doc(cartItemId).delete();
    notifyListeners();
  }

  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartItems = await _cartItemsRef.where('userId', isEqualTo: userId).get();

    final batch = _firestore.batch();
    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    notifyListeners();
  }

  // ============ ORDERS ============
  Future<void> placeOrder(
      List<CartItem> cartItems,
      double totalAmount, {
        String? deliveryAddress,
        String? paymentMethod,
        String? notes,
      }) async {
    final userId = _auth.currentUser?.uid;
    final userEmail = _auth.currentUser?.email;
    if (userId == null || userEmail == null) throw Exception('User not logged in');

    try {
      // Get user info
      final userDoc = await _usersRef.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final userName = userData?['name'] ?? 'Customer';

      // Generate order number
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // Convert cart items to order items
      final orderItems = cartItems.map((item) {
        return {
          'foodItemId': item.foodItemId,
          'foodName': item.foodName,
          'price': item.price,
          'quantity': item.quantity,
          'imageUrl': item.imageUrl,
        };
      }).toList();

      // Create order
      await _ordersRef.add({
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'items': orderItems,
        'totalAmount': totalAmount,
        'status': 'pending',
        'orderNumber': orderNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod ?? 'Cash on Delivery',
        'notes': notes,
      });

      // Update user stats
      await _usersRef.doc(userId).update({
        'totalOrders': FieldValue.increment(1),
        'totalSpent': FieldValue.increment(totalAmount),
      });

      // Clear cart
      await clearCart();
      notifyListeners();
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  Stream<List<Order>> getUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _ordersRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Order.fromFirestore(doc.data() as DocumentSnapshot<Map<String, dynamic>>, doc.id);
      }).toList();
    });
  }

  // ============ CATEGORIES ============
  Stream<List<String>> getCategories() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> addCategory(String name) async {
    await _categoriesRef.add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  // ============ USER MANAGEMENT ============
  Future<Map<String, dynamic>> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final userDoc = await _usersRef.doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _usersRef.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }
}