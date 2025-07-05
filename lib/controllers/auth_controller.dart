import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart' as app_user;

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<app_user.User?> _user = Rx<app_user.User?>(null);
  final RxBool _isLoading = false.obs;
  final Rx<firebase_auth.User?> _firebaseUser = Rx<firebase_auth.User?>(null);

  app_user.User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _user.value != null;
  firebase_auth.User? get firebaseUser => _firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    // Listen to Firebase Auth state changes
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  // Set initial screen based on auth state
  void _setInitialScreen(firebase_auth.User? firebaseUser) {
    if (firebaseUser != null) {
      _loadUserData(firebaseUser.uid);
    } else {
      _user.value = null;
      Get.offAllNamed('/login');
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user.value = app_user.User.fromJson(doc.data()!);
        Get.offAllNamed('/notes');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    }
  }

  // Register with email and password
  Future<void> register(String name, String email, String password) async {
    try {
      _isLoading.value = true;

      // Validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'Please fill all fields');
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email');
        return;
      }

      if (password.length < 6) {
        Get.snackbar('Error', 'Password must be at least 6 characters');
        return;
      }

      // Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user document in Firestore
        final newUser = app_user.User(
          id: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toJson());

        _user.value = newUser;
        Get.snackbar('Success', 'Registration successful!');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;

      // Validation
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'Please fill all fields');
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email');
        return;
      }

      // Sign in with Firebase
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.snackbar('Success', 'Login successful!');
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        Get.snackbar('Error', 'Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email');
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent!');
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'Password reset failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'Password reset failed';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Password reset failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateProfile(String name) async {
    try {
      if (name.isEmpty) {
        Get.snackbar('Error', 'Name cannot be empty');
        return;
      }

      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null && _user.value != null) {
        // Update Firebase Auth profile
        await firebaseUser.updateDisplayName(name);

        // Update Firestore document
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'name': name,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Update local user data
        _user.value = app_user.User(
          id: _user.value!.id,
          name: name,
          email: _user.value!.email,
          profileImage: _user.value!.profileImage,
          createdAt: _user.value!.createdAt,
          updatedAt: DateTime.now(),
        );

        Get.snackbar('Success', 'Profile updated successfully!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user.value = null;
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).delete();

        // Delete Firebase Auth user
        await firebaseUser.delete();

        _user.value = null;
        Get.snackbar('Success', 'Account deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: ${e.toString()}');
    }
  }
}
