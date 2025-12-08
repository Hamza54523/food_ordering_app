import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminService = Provider.of<AdminService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Users List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: adminService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }

                List<Map<String, dynamic>> users = snapshot.data!;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  users = users.where((user) {
                    final name = user['name']?.toString().toLowerCase() ?? '';
                    final email = user['email']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery) ||
                        email.contains(_searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserCard(
                      user: user,
                      onViewDetails: () {
                        _showUserDetails(user);
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

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UserDetailsSheet(user: user),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onViewDetails;

  const UserCard({
    super.key,
    required this.user,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = user['createdAt'] is Timestamp
        ? (user['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF6B35),
          child: Text(
            user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user['name']?.toString() ?? 'No Name',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']?.toString() ?? 'No Email'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.shopping_cart, size: 12),
                const SizedBox(width: 4),
                Text('Orders: ${user['totalOrders'] ?? 0}'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 12),
                const SizedBox(width: 4),
                Text(
                    'Spent: \$${(user['totalSpent'] ?? 0.0).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Joined: ${DateFormat('MMM dd, yyyy').format(createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onViewDetails,
        ),
      ),
    );
  }
}

class UserDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailsSheet({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailsSheet> createState() => _UserDetailsSheetState();
}

class _UserDetailsSheetState extends State<UserDetailsSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name'] ?? '');
    _phoneController = TextEditingController(text: widget.user['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    setState(() => _isLoading = true);

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.updateUserStatus(widget.user['id'], {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.user['createdAt'] is Timestamp
        ? (widget.user['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final lastLogin = widget.user['lastLogin'] is Timestamp
        ? (widget.user['lastLogin'] as Timestamp).toDate()
        : null;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: const Color(0xFFFF6B35),
                ),
                onPressed: () {
                  if (_isEditing) {
                    _updateUser();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Info
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name:', widget.user['name'] ?? 'N/A'),
                _buildDetailRow('Email:', widget.user['email'] ?? 'N/A'),
                _buildDetailRow('Phone:', widget.user['phone'] ?? 'N/A'),
              ],
            ),

          const Divider(),
          const SizedBox(height: 16),

          // User Stats
          const Text(
            'User Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            children: [
              _buildStatItem(
                'Total Orders',
                (widget.user['totalOrders'] ?? 0).toString(),
              ),
              _buildStatItem(
                'Total Spent',
                '\$${(widget.user['totalSpent'] ?? 0.0).toStringAsFixed(2)}',
              ),
              _buildStatItem(
                'Joined Date',
                DateFormat('MMM dd, yyyy').format(createdAt),
              ),
              _buildStatItem(
                'Last Login',
                lastLogin != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(lastLogin)
                    : 'N/A',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          if (_isEditing && _isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
                child: Text(_isEditing ? 'Cancel' : 'Close'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}