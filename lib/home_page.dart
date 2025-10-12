import 'package:flutter/material.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Burgers', 'icon': Icons.fastfood},
    {'name': 'Drinks', 'icon': Icons.local_drink},
    {'name': 'Desserts', 'icon': Icons.icecream},
  ];

  final List<Map<String, dynamic>> _foodItems = [
    {
      'id': 1,
      'name': 'Margherita Pizza',
      'price': 12.99,
      'category': 'Pizza',
      'image': 'assets/pizza1.jpg',
    },
    {
      'id': 2,
      'name': 'Pepperoni Pizza',
      'price': 15.99,
      'category': 'Pizza',
      'image': 'assets/pizza2.jpg',
    },
    {
      'id': 3,
      'name': 'Classic Burger',
      'price': 8.99,
      'category': 'Burgers',
      'image': 'assets/burger1.jpg',
    },
    {
      'id': 4,
      'name': 'Cheese Burger',
      'price': 9.99,
      'category': 'Burgers',
      'image': 'assets/burger2.jpg',
    },
    {
      'id': 5,
      'name': 'Cola',
      'price': 2.99,
      'category': 'Drinks',
      'image': 'assets/drink1.jpg',
    },
    {
      'id': 6,
      'name': 'Orange Juice',
      'price': 3.99,
      'category': 'Drinks',
      'image': 'assets/drink2.jpg',
    },
  ];

  String _selectedCategory = 'Pizza';
  int _cartItemCount = 0;

  void _addToCart() {
    setState(() {
      _cartItemCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to cart!'),
        backgroundColor: Color(0xFFFF6B35),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Welcome to FoodExpress',
          style: TextStyle(
            color: Color(0xFFFF6B35),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          Stack(
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
              if (_cartItemCount > 0)
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
                      _cartItemCount.toString(),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for food...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B35)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Food Items
            const Text(
              'Popular Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _foodItems
                  .where((item) => item['category'] == _selectedCategory)
                  .length,
              itemBuilder: (context, index) {
                final categoryItems = _foodItems
                    .where((item) => item['category'] == _selectedCategory)
                    .toList();
                final food = categoryItems[index];
                return FoodCard(
                  name: food['name'],
                  price: food['price'],
                  onAddToCart: _addToCart,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String name;
  final double price;
  final VoidCallback onAddToCart;

  const FoodCard({
    super.key,
    required this.name,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image Placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                    Colors.orange.withOpacity(0.1),
                    BlendMode.darken,
                  ),
                  image: const AssetImage('assets/food_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fastfood,
                  size: 50,
                  color: Colors.orange[300],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}