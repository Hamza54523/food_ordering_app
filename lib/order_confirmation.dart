import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/cart_item.dart';

class OrderConfirmationPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const OrderConfirmationPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      await firestoreService.placeOrder(
        widget.cartItems,
        widget.totalAmount,
        deliveryAddress: _addressController.text,
        paymentMethod: _paymentMethod,
        notes: _notesController.text,
      );

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(
            'Order Confirmed!',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Order Total: \$${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Color(0xFFFF6B35)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.foodName} x${item.quantity}'),
                          Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${widget.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Address
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your complete delivery address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Cash on Delivery',
                  child: Text('Cash on Delivery'),
                ),
                DropdownMenuItem(
                  value: 'Credit Card',
                  child: Text('Credit Card'),
                ),
                DropdownMenuItem(
                  value: 'Debit Card',
                  child: Text('Debit Card'),
                ),
                DropdownMenuItem(
                  value: 'Digital Wallet',
                  child: Text('Digital Wallet'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Additional Notes
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special instructions for delivery...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isPlacingOrder
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}