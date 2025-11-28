import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'cart_manager.dart';
class HomePage extends StatefulWidget


class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Burgers', 'icon': Icons.fastfood},
    {'name': 'Drinks', 'icon': Icons.local_drink},
    {'name': 'Desserts', 'icon': Icons.icecream},
    {'name': 'Deals', 'icon': Icons.local_offer},
  ];

  final List<Map<String, dynamic>> _foodItems = [
    {
      'id': 1,
      'name': 'Margherita Pizza',
      'price': 12.99,
      'category': 'Pizza',
      'image': 'assets/Margherita pizza.jpg',
    },
    {
      'id': 2,
      'name': 'Pepperoni Pizza',
      'price': 15.99,
      'category': 'Pizza',
      'image': 'assets/Pepproni pizza.jpg',
    },
    {
      'id': 3,
      'name': 'Classic Burger',
      'price': 8.99,
      'category': 'Burgers',
      'image': 'assets/Classic Burger.jpg',
    },
    {
      'id': 4,
      'name': 'Cheese Burger',
      'price': 9.99,
      'category': 'Burgers',
      'image': 'assets/Cheese Burger.jpg',
    },
    {
      'id': 5,
      'name': 'Cola',
      'price': 2.99,
      'category': 'Drinks',
      'image': 'assets/Cola.jpg',
    },
    {
      'id': 6,
      'name': 'Orange Juice',
      'price': 3.99,
      'category': 'Drinks',
      'image': 'assets/Orange Juice.jpg',
    },
    {
      'id': 7,
      'name': 'Chocolate Cake',
      'price': 6.99,
      'category': 'Desserts',
      'image': 'assets/chocolate_cake.jpg',
    },
    {
      'id': 8,
      'name': 'Vanilla Ice Cream',
      'price': 3.49,
      'category': 'Desserts',
      'image': 'assets/vanilla_ice_cream.jpg',
    },
    {
      'id': 9,
      'name': 'Brownie Sundae',
      'price': 5.99,
      'category': 'Desserts',
      'image': 'assets/brownie_sundae.jpg',
    },
    {
      'id': 100,
      'name': 'Deal 1: Pizza + Drink',
      'price': 16.99,
      'category': 'Deals',
      'image': 'assets/deal1.jpg',
    },
    {
      'id': 101,
      'name': 'Deal 2: Burger + Fries',
      'price': 12.49,
      'category': 'Deals',
      'image': 'assets/deal2.jpg',
    },
    {
      'id': 102,
      'name': 'Deal 3: 2 Burgers + Drink',
      'price': 18.99,
      'category': 'Deals',
      'image': 'assets/deal3.jpg',
    },
    {
      'id': 103,
      'name': 'Deal 4: Pizza + Wings',
      'price': 22.99,
      'category': 'Deals',
      'image': 'assets/deal4.jpg',
    },
    {
      'id': 104,
      'name': 'Deal 5: Full Family Meal',
      'price': 29.99,
      'category': 'Deals',
      'image': 'assets/deal5.jpg',
    },
  ];

  String _selectedCategory = 'Pizza';
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _cartItemCount = CartManager().itemCount;
  }

  void _addToCart(Map<String, dynamic> item) {
    CartManager().addItem(item);
    setState(() => _cartItemCount = CartManager().itemCount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item added to cart!"),
        backgroundColor: Color(0xFFFF6B35),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _foodItems
        .where((item) => item['category'] == _selectedCategory)
        .toList();

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
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartPage()));
                  setState(() => _cartItemCount = CartManager().itemCount);
                },
                icon: const Icon(Icons.shopping_cart,
                    color: Color(0xFFFF6B35)),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _cartItemCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon:
                    Icon(Icons.search, color: Color(0xFFFF6B35)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Categories',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
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
                      onTap: () => setState(() {
                        _selectedCategory = category['name'];
                      }),
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
                            Icon(category['icon'],
                                color:
                                _selectedCategory == category['name']
                                    ? Colors.white
                                    : const Color(0xFFFF6B35)),
                            const SizedBox(height: 4),
                            Text(
                              category['name'],
                              style: TextStyle(
                                color:
                                _selectedCategory == category['name']
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
              Text(
                _selectedCategory == "Deals"
                    ? "Special Deals"
                    : "Popular Items",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final food = filteredItems[index];
                  return FoodCard(
                    name: food['name'],
                    price: food['price'],
                    imagePath: food['image'],
                    onAddToCart: () => _addToCart(food),
                  );
                },
              ),
            ]),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String name;
  final double price;
  final String imagePath;
  final VoidCallback onAddToCart;

  const FoodCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE FIXED + NO BLANK SPACE
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18)),
            child: Container(
              height: 135,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins"),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$$price",
                    style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins"),
                  ),
                  const SizedBox(height: 10),

                  // PERFECT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),
                      ),
                    ),
                  )
                ]),
          )
        ],
      ),
    );
  }
}
