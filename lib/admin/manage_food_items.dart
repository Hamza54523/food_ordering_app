import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';

class ManageFoodItems extends StatefulWidget {
  const ManageFoodItems({super.key});

  @override
  State<ManageFoodItems> createState() => _ManageFoodItemsState();
}

class _ManageFoodItemsState extends State<ManageFoodItems> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFoodItemPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('food_items')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No food items found'),
            );
          }

          final foodItems = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final doc = foodItems[index];
              final data = doc.data() as Map<String, dynamic>;
              final isAvailable = data['isAvailable'] ?? true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                    radius: 25,
                  ),
                  title: Text(
                    data['name'] ?? 'No Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isAvailable
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${(data['price'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(data['category'] ?? 'No Category'),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text('${(data['rating'] ?? 0.0).toStringAsFixed(1)}'),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text('${data['preparationTime'] ?? 0} min'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isAvailable ? Icons.toggle_on : Icons.toggle_off,
                          color: isAvailable ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleAvailability(doc.id, !isAvailable);
                        },
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editFoodItem(doc.id, data);
                          } else if (value == 'delete') {
                            _deleteFoodItem(doc.id, data['name']);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleAvailability(String itemId, bool isAvailable) async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    await adminService.toggleFoodItemAvailability(itemId, isAvailable);
  }

  void _editFoodItem(String itemId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => EditFoodItemDialog(
        itemId: itemId,
        initialData: data,
      ),
    );
  }

  void _deleteFoodItem(String itemId, String itemName) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.deleteFoodItem(itemId);
    }
  }
}

class AddFoodItemPage extends StatefulWidget {
  const AddFoodItemPage({super.key});

  @override
  State<AddFoodItemPage> createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.5');
  final _preparationTimeController = TextEditingController(text: '20');

  final List<String> _categories = [
    'Pizza',
    'Burgers',
    'Drinks',
    'Desserts',
    'Asian',
    'Italian',
    'Mexican',
    'Indian',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  Future<void> _addFoodItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      final foodItem = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'category': _categoryController.text.isEmpty
            ? null
            : _categoryController.text.trim(), // Handle null if not selected
        'imageUrl': _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rating': double.parse(_ratingController.text),
        'preparationTime': int.parse(_preparationTimeController.text),
      };

      await adminService.addFoodItem(foodItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food item added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add food item: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Food Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  // Only set if value is not null, ensuring the controller reflects selection
                  if (value != null) {
                    _categoryController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating (0-5)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter rating';
                        }
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) {
                          return 'Rating must be between 0 and 5';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _preparationTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Prep Time (min)',
                        border: OutlineInputBorder(),
                        suffixText: 'min',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter preparation time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _addFoodItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white, // Ensure visibility
                  ),
                  child: const Text(
                    'Add Food Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditFoodItemDialog extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> initialData;

  const EditFoodItemDialog({
    super.key,
    required this.itemId,
    required this.initialData,
  });

  @override
  State<EditFoodItemDialog> createState() => _EditFoodItemDialogState();
}

class _EditFoodItemDialogState extends State<EditFoodItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _ratingController;
  late TextEditingController _preparationTimeController;

  final List<String> _categories = [
    'Pizza',
    'Burgers',
    'Drinks',
    'Desserts',
    'Asian',
    'Italian',
    'Mexican',
    'Indian',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _priceController = TextEditingController(
        text: (widget.initialData['price'] as num? ?? 0.0).toString());
    _categoryController =
        TextEditingController(text: widget.initialData['category']);
    _imageUrlController =
        TextEditingController(text: widget.initialData['imageUrl']);
    _descriptionController =
        TextEditingController(text: widget.initialData['description']);
    _ratingController = TextEditingController(
        text: (widget.initialData['rating'] as num? ?? 4.5).toString());
    _preparationTimeController = TextEditingController(
        text: (widget.initialData['preparationTime'] as num? ?? 20).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  Future<void> _updateFoodItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      final updates = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'category': _categoryController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rating': double.parse(_ratingController.text),
        'preparationTime': int.parse(_preparationTimeController.text),
        // isAvailable is handled via the toggle button in the list view
      };

      await adminService.updateFoodItem(widget.itemId, updates);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food item updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update food item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Food Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              // FIX: Using DropdownButtonFormField for category editing consistency
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _categoryController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(labelText: 'Rating'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return 'Valid rating required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _preparationTimeController,
                      decoration: const InputDecoration(labelText: 'Prep Time (min)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Valid time required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateFoodItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }
}