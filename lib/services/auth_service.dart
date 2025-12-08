import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email/password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      if (result.user != null) {
        await _updateUserLastLogin(result.user!.uid);
      }

      notifyListeners();
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      return null;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Register with email/password
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'email': email,
          'name': name,
          'phone': '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'totalOrders': 0,
          'totalSpent': 0.0,
        });
      }

      notifyListeners();
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.message}');
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile(String name, String phone) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore.collection('users').doc(userId).update({
          'name': name,
          'phone': phone,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        notifyListeners();
      } catch (e) {
        print('Update profile error: $e');
      }
    }
  }

  // Update last login
  Future<void> _updateUserLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update last login error: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }
}