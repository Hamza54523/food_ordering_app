import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/food_item.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.all_inclusive},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Burgers', 'icon': Icons.fastfood},
    {'name': 'Drinks', 'icon': Icons.local_drink},
    {'name': 'Desserts', 'icon': Icons.icecream},
    {'name': 'Asian', 'icon': Icons.ramen_dining},
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'FoodExpress',
          style: TextStyle(
            color: Color(0xFFFF6B35),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          StreamBuilder<int>(
            stream: firestoreService.getCartItemsCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart, color: Color(0xFFFF6B35)),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search for food...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B35)),
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedCategory == category['name']
                          ? const Color(0xFFFF6B35)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: _selectedCategory == category['name']
                              ? Colors.white
                              : const Color(0xFFFF6B35),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'],
                          style: TextStyle(
                            color: _selectedCategory == category['name']
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Food Items
          Expanded(
            child: StreamBuilder<List<FoodItem>>(
              stream: _selectedCategory == 'All'
                  ? firestoreService.getFoodItems()
                  : firestoreService.getFoodItemsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No food items available'),
                  );
                }

                List<FoodItem> foodItems = snapshot.data!;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  foodItems = foodItems
                      .where((item) =>
                      item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = foodItems[index];
                    return FoodCard(
                      foodItem: foodItem,
                      onAddToCart: () async {
                        try {
                          await firestoreService.addToCart(foodItem);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${foodItem.name} added to cart!'),
                              backgroundColor: const Color(0xFFFF6B35),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add to cart: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onAddToCart;

  const FoodCard({
    super.key,
    required this.foodItem,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              image: DecorationImage(
                image: NetworkImage(foodItem.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      foodItem.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${foodItem.preparationTime} min',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${foodItem.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: onAddToCart,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}