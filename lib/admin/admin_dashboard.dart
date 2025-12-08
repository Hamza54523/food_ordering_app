import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added missing import
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import 'manage_food_items.dart';
import 'manage_orders.dart';
import 'manage_users.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const ManageFoodItems(),
    const ManageOrders(),
    const ManageUsers(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // Navigate to admin login page
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/admin/login',
                      (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B35),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Food Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsFuture = _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    return await adminService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Cards
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      const Text('Failed to load statistics'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              final stats = snapshot.data!;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'Total Users',
                    value: stats['totalUsers']?.toString() ?? '0',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Total Food Items',
                    value: stats['totalFoodItems']?.toString() ?? '0',
                    icon: Icons.restaurant,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Total Orders',
                    value: stats['totalOrders']?.toString() ?? '0',
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Today\'s Orders',
                    value: stats['todayOrders']?.toString() ?? '0',
                    icon: Icons.today,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    title: 'Pending Orders',
                    value: stats['pendingOrders']?.toString() ?? '0',
                    icon: Icons.pending_actions,
                    color: Colors.red,
                  ),
                  _buildStatCard(
                    title: 'Monthly Revenue',
                    value: '\$${stats['monthlyRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.attach_money,
                    color: Colors.teal,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                title: 'Add New Food Item',
                icon: Icons.add_circle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFoodItemPage(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                title: 'View Orders',
                icon: Icons.list_alt,
                onTap: () {
                  setState(() {
                    // Navigate to orders page via bottom navigation
                    // This assumes you want to switch to the orders tab
                    // If you want to push a new page, use Navigator.push
                    final adminDashboardState = context.findAncestorStateOfType<_AdminDashboardState>();
                    adminDashboardState?.setState(() {
                      adminDashboardState._selectedIndex = 2; // Orders index
                    });
                  });
                },
              ),
              _buildActionCard(
                title: 'Manage Users',
                icon: Icons.people,
                onTap: () {
                  setState(() {
                    final adminDashboardState = context.findAncestorStateOfType<_AdminDashboardState>();
                    adminDashboardState?.setState(() {
                      adminDashboardState._selectedIndex = 3; // Users index
                    });
                  });
                },
              ),
              _buildActionCard(
                title: 'View Reports',
                icon: Icons.analytics,
                onTap: () {
                  _showReportsDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFFFF6B35)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Sales Report'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to sales report
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Popular Items'),
              onTap: () {
                Navigator.pop(context);
                _showPopularItems(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Daily Report'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to daily report
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPopularItems(BuildContext context) async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    try {
      final popularItems = await adminService.getPopularItems();

      if (popularItems['popularItems'] == null ||
          (popularItems['popularItems'] as List).isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Popular Items'),
            content: const Text('No popular items data available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Popular Items'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: popularItems['popularItems'].length,
              itemBuilder: (context, index) {
                final item = popularItems['popularItems'][index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: item['imageUrl'] != null
                        ? NetworkImage(item['imageUrl']!)
                        : const AssetImage('assets/default_food.png') as ImageProvider,
                  ),
                  title: Text(item['name'] ?? 'Unknown Item'),
                  subtitle: Text('Sold: ${item['quantity']?.toString() ?? '0'} units'),
                  trailing: Text('${item['orders']?.toString() ?? '0'} orders'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load popular items: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Placeholder for AddFoodItemPage if it doesn't exist
class AddFoodItemPage extends StatelessWidget {
  const AddFoodItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
      ),
      body: const Center(
        child: Text('Add Food Item Page'),
      ),
    );
  }
}