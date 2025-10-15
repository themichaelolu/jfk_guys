import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Get current user
  User? get currentUser => _auth.currentUser;

  // 🔥 Watch auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Password is incorrect';
      } else if (e.code == 'invalid-credential') {
        return 'Email/password is incorrect';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists with that email.';
      } else if (e.code == 'network-request-failed') {
        return 'Network failed';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'isAnonymous': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> upgradeAnonymousAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        return "No anonymous user to upgrade";
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final result = await currentUser.linkWithCredential(credential);

      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Error upgrading account";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

@riverpod
AuthService authService(Ref ref) => AuthService();
