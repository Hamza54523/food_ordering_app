import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Margherita Pizza',
      'price': 12.99,
      'quantity': 1,
      'image': 'assets/pizza1.jpg',
    },
    {
      'name': 'Classic Burger',
      'price': 8.99,
      'quantity': 2,
      'image': 'assets/burger1.jpg',
    },
  ];

  double get _totalPrice {
    return _cartItems.fold(0, (total, item) {
      return total + (item['price'] * item['quantity']);
    });
  }

  void _placeOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Order Confirmed!',
          style: TextStyle(
            color: Color(0xFFFF6B35),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          'Your order has been placed successfully. You will receive a confirmation soon.',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
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
          'My Cart',
          style: TextStyle(
            color: Color(0xFFFF6B35),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF6B35)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return CartItemCard(
                  name: item['name'],
                  price: item['price'],
                  quantity: item['quantity'],
                  onQuantityChanged: (newQuantity) {
                    setState(() {
                      _cartItems[index]['quantity'] = newQuantity;
                    });
                  },
                );
              },
            ),
          ),
          if (_cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '\$$_totalPrice',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}

class CartItemCard extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Food Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fastfood,
                color: Colors.orange[300],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: quantity > 1
                      ? () => onQuantityChanged(quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove, color: Color(0xFFFF6B35)),
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  onPressed: () => onQuantityChanged(quantity + 1),
                  icon: const Icon(Icons.add, color: Color(0xFFFF6B35)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}