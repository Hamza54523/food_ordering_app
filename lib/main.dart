import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Screens
import 'splash_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'order_confirmation.dart';
import 'admin/admin_login.dart';
import 'admin/admin_dashboard.dart';
import 'admin/manage_food_items.dart';
import 'admin/manage_orders.dart';
import 'admin/manage_users.dart';

// Services
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FoodExpressApp());
}

class FoodExpressApp extends StatelessWidget {
  const FoodExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
      ],
      child: MaterialApp(
        title: 'FoodExpress',
        theme: ThemeData(
          useMaterial3: true,

          // Color Scheme
          primaryColor: const Color(0xFFFF6B35),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            primary: const Color(0xFFFF6B35),
            secondary: const Color(0xFFFFA726),
            // FIX: Using 'surface' instead of deprecated 'background'
            surface: Colors.white,
          ),

          // App Bar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            iconTheme: IconThemeData(color: Color(0xFFFF6B35)),
          ),

          // Scaffold Theme
          scaffoldBackgroundColor: Colors.white,

          // Font
          fontFamily: 'Poppins',

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),

          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          // FIX: Changed CardTheme to CardThemeData to match the required type
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(8),
          ),


          // Floating Action Button Theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFF6B35),
            foregroundColor: Colors.white,
          ),
        ),

        // Initial route
        initialRoute: '/',

        // Routes
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomePage(),
          '/cart': (context) => const CartPage(),
          '/checkout': (context) => OrderConfirmationPage(
            cartItems: const [],
            totalAmount: 0.0,
          ),
          '/admin/login': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminDashboard(),
          '/admin/food-items': (context) => const ManageFoodItems(),
          '/admin/orders': (context) => const ManageOrders(),
          '/admin/users': (context) => const ManageUsers(),
        },

        // Unknown route handler
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Page Not Found'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '404 - Page Not Found',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                              (route) => false,
                        );
                      },
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}