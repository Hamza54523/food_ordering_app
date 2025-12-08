import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String userId;
  final String foodItemId;
  final String foodName;
  final double price;
  final int quantity;
  final String imageUrl;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.foodItemId,
    required this.foodName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.updatedAt,
  });

  factory CartItem.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItem(
      id: id,
      userId: data['userId'] ?? '',
      foodItemId: data['foodItemId'] ?? '',
      foodName: data['foodName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  double get totalPrice => price * quantity;
}