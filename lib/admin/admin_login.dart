import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import the AdminService logic from the services folder
import '../../services/admin_service.dart';

// FIX: Import the AdminDashboard widget using a prefix to avoid the AdminService naming conflict.
// NOTE: Assuming the AdminDashboard class is defined in admin_dashboard.dart.
import 'admin_dashboard.dart' as admin_dash;

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _adminLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Login with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if user is admin
      // FIX: Use Provider.of with listen: false here and elsewhere for optimization
      final adminService = Provider.of<AdminService>(context, listen: false);
      // FIX: Ensure 'isAdmin' method exists in AdminService
      final isAdmin = await adminService.isAdmin();

      if (!mounted) return;

      if (isAdmin) {
        // FIX: Use the prefixed import name (admin_dash.AdminDashboard)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const admin_dash.AdminDashboard()),
        );
      } else {
        _showSnackBar('Access denied. Admin privileges required.');
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Login failed');
    } catch (e) {
      // Catch general errors (e.g., if isAdmin() fails or AdminService isn't provided)
      _showSnackBar('An error occurred: ${e.toString()}');
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Color(0xFFFF6B35),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Admin Portal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to manage your restaurant',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Admin Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _adminLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white, // Ensure text is visible
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login as Admin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to User App'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}