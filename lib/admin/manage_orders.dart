// lib/admin/manage_orders.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// Assuming paths are correct
import '../../services/admin_service.dart';
import '../../models/order.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  String _selectedFilter = 'all';
  final List<String> _statusFilters = [
    'all',
    'pending',
    'preparing',
    'ready',
    'delivered',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter == 'all' ? 'All' : filter.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFFFF6B35),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Orders List
          Expanded(
            child: _selectedFilter == 'all'
                ? _buildAllOrdersStream()
                : _buildFilteredOrdersStream(_selectedFilter),
          ),
        ],
      ),
    );
  }

  Widget _buildAllOrdersStream() {
    // listen: false to prevent unnecessary rebuilds
    final adminService = Provider.of<AdminService>(context, listen: false);

    return StreamBuilder<List<Order>>(
      stream: adminService.getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No orders found'),
          );
        }

        final orders = snapshot.data!;
        return _buildOrdersList(orders);
      },
    );
  }

  Widget _buildFilteredOrdersStream(String status) {
    final adminService = Provider.of<AdminService>(context, listen: false);

    return StreamBuilder<List<Order>>(
      stream: adminService.getOrdersByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No $status orders found'),
          );
        }

        final orders = snapshot.data!;
        return _buildOrdersList(orders);
      },
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onStatusChanged: (newStatus) {
            _updateOrderStatus(order.id, newStatus);
          },
          onViewDetails: () {
            _showOrderDetails(order);
          },
        );
      },
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    await adminService.updateOrderStatus(orderId, newStatus);
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final Function(String) onStatusChanged;
  final VoidCallback onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
    required this.onViewDetails,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // FIX: Replaced deprecated .withOpacity(0.1) with .withAlpha(25)
                    color: _getStatusColor(order.status).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${order.userName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Email: ${order.userEmail}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items: ${order.items.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (value) => onStatusChanged(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'pending',
                        child: Text('Mark as Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'preparing',
                        child: Text('Mark as Preparing'),
                      ),
                      const PopupMenuItem(
                        value: 'ready',
                        child: Text('Mark as Ready'),
                      ),
                      const PopupMenuItem(
                        value: 'delivered',
                        child: Text('Mark as Delivered'),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Text(
                          'Cancel Order',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Update Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const OrderDetailsSheet({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Order Number:', order.orderNumber),
            _buildDetailRow('Customer:', order.userName),
            _buildDetailRow('Email:', order.userEmail),
            _buildDetailRow(
              'Order Date:',
              DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
            ),
            if (order.deliveryAddress != null)
              _buildDetailRow('Delivery Address:', order.deliveryAddress!),
            _buildDetailRow('Payment Method:', order.paymentMethod ?? 'N/A'),
            _buildDetailRow('Status:', order.status.toUpperCase()),
            _buildDetailRow(
              'Total Amount:',
              '\$${order.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${item.foodName} x${item.quantity}'),
                  ),
                  Text('\$${item.subtotal.toStringAsFixed(2)}'),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            if (order.notes != null && order.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(order.notes!),
                ],
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}