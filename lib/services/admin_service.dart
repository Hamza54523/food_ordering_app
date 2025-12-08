// lib/services/admin_service.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart'; // Assuming this path is correct

class AdminService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _orderCollection =
  FirebaseFirestore.instance.collection('orders');

  final CollectionReference<Map<String, dynamic>> _userCollection =
  FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _foodItemCollection =
  FirebaseFirestore.instance.collection('food_items');


  // ====================================================================
  // 1. FOOD ITEM MANAGEMENT
  // ====================================================================

  /// Implements addFoodItem. Adds a new food item to the 'food_items' collection.
  Future<void> addFoodItem(Map<String, dynamic> foodItemData) async {
    // Add Firestore timestamps and set default availability
    foodItemData['createdAt'] = FieldValue.serverTimestamp();
    foodItemData['isAvailable'] = true;

    await _foodItemCollection.add(foodItemData);
  }

  /// Implements updateFoodItem. Updates an existing food item.
  Future<void> updateFoodItem(String itemId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _foodItemCollection.doc(itemId).update(updates);
  }

  /// Implements toggleFoodItemAvailability. Changes the 'isAvailable' status.
  Future<void> toggleFoodItemAvailability(String itemId, bool isAvailable) async {
    await _foodItemCollection.doc(itemId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Implements deleteFoodItem. Deletes a food item by ID.
  Future<void> deleteFoodItem(String itemId) async {
    await _foodItemCollection.doc(itemId).delete();
  }


  // ====================================================================
  // 2. AUTH & DASHBOARD STATS
  // ====================================================================

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
      return adminDoc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking admin status: $e');
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final totalOrdersQuery = await _orderCollection.count().get();
    final totalUsersQuery = await _userCollection.count().get();
    final totalFoodItemsQuery = await _foodItemCollection.count().get();

    final todayOrdersQuery = await _orderCollection
        .where('createdAt', isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
        .count()
        .get();

    final pendingOrdersQuery = await _orderCollection
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    double monthlyRevenue = 0.0;
    final monthlyOrdersSnapshot = await _orderCollection
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('status', whereIn: ['delivered', 'ready'])
        .get();

    for (var doc in monthlyOrdersSnapshot.docs) {
      final amount = (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
      monthlyRevenue += amount;
    }

    return {
      'totalUsers': totalUsersQuery.count,
      'totalFoodItems': totalFoodItemsQuery.count,
      'totalOrders': totalOrdersQuery.count,
      'todayOrders': todayOrdersQuery.count,
      'pendingOrders': pendingOrdersQuery.count,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  Future<Map<String, dynamic>> getPopularItems() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'popularItems': [
        {'name': 'Classic Burger', 'quantity': 120, 'orders': 55, 'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/flutter-admin-app.appspot.com/o/placeholders%2Fburger.png?alt=media'},
        {'name': 'Chicken Salad', 'quantity': 85, 'orders': 40, 'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/flutter-admin-app.appspot.com/o/placeholders%2Fsalad.png?alt=media'},
      ]
    };
  }


  // ====================================================================
  // 3. ORDER MANAGEMENT
  // ====================================================================

  Stream<List<Order>> getAllOrders() {
    return _orderCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.data()! as DocumentSnapshot<Map<String, dynamic>>, doc.id))
          .toList();
    });
  }

  Stream<List<Order>> getOrdersByStatus(String status) {
    return _orderCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.data()! as DocumentSnapshot<Map<String, dynamic>>, doc.id))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _orderCollection.doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  // ====================================================================
  // 4. USER MANAGEMENT (NEW SECTION ADDED)
  // ====================================================================

  /// Streams all users from the 'users' collection.
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _userCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final userData = doc.data();
        userData['id'] = doc.id; // Include the document ID for updates
        return userData;
      }).toList();
    });
  }

  /// Updates user details (name and phone) based on the user ID.
  Future<void> updateUserStatus(String userId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _userCollection.doc(userId).update(updates);
  }
}