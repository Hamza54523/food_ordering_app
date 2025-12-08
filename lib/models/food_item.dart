import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;
  final double rating;
  final int preparationTime;
  final bool isAvailable;
  final DateTime createdAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.description = '',
    this.rating = 4.5,
    this.preparationTime = 20,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory FoodItem.fromFirestore(Map<String, dynamic> data, String id) {
    return FoodItem(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 4.5).toDouble(),
      preparationTime: data['preparationTime'] ?? 20,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'preparationTime': preparationTime,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}