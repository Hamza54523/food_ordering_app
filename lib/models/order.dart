// lib/models/order.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// --- OrderItem Model ---
class OrderItem {
  final String foodItemId;
  final String foodName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.foodItemId,
    required this.foodName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      foodItemId: map['foodItemId'] as String? ?? '',
      foodName: map['foodName'] as String? ?? '',
      price: (map['price'] as num? ?? 0.0).toDouble(),
      quantity: (map['quantity'] as int? ?? 1),
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItemId,
      'foodName': foodName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

// --- Order Model ---
class Order {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final List<OrderItem> items;
  final String status;
  final String orderNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;
  final String? paymentMethod;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.items,
    required this.status,
    required this.orderNumber,
    required this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.paymentMethod,
    this.notes,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Updated factory to accept DocumentSnapshot
  factory Order.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data()!;

    // Safely retrieve Timestamps
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    final updatedAtTimestamp = data['updatedAt'] as Timestamp?;

    return Order(
      id: snapshot.id,
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((itemMap) => OrderItem.fromMap(itemMap as Map<String, dynamic>))
          .toList() ??
          [],
      status: data['status'] as String? ?? 'pending',
      orderNumber: data['orderNumber'] as String? ?? '',
      // Use fallback or throw if creation date is missing
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedAtTimestamp?.toDate(),
      deliveryAddress: data['deliveryAddress'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderNumber': orderNumber,
      // When writing, use FieldValue.serverTimestamp() for current time fields
      // NOTE: You must decide if you want to store createdAt/updatedAt as DateTime objects
      // or FieldValue.serverTimestamp() upon creation/update.
      // Using existing DateTime objects here for consistency if model is created elsewhere first:
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }
}