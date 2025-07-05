import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:notes_taking_app/model/user.dart' as app_user;

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  final Rx<firebase_auth.User?> _firebaseUser = Rx<firebase_auth.User?>(null);
  final RxBool _isLoading = false.obs;
  final Rx<app_user.User?> _appUser = Rx<app_user.User?>(null);

  firebase_auth.User? get firebaseUser => _firebaseUser.value;
  app_user.User? get appUser => _appUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to Firebase Auth state changes
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(firebase_auth.User? firebaseUser) {
    if (firebaseUser != null) {
      _loadUserData(firebaseUser.uid);
    } else {
      _appUser.value = null;
      Get.offAllNamed('/login');
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _logger.i('Loading user data for UID: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _logger.i('User document found: ${doc.data()}');
        _appUser.value = app_user.User.fromJson(doc.data()!);
        _logger.i('User loaded successfully: ${_appUser.value}');
        Get.offAllNamed('/notes');
      } else {
        _logger.w('No user document found for UID: $uid');
      }
    } catch (e) {
      _logger.e('Error loading user data: $e');
      Get.snackbar('Error', 'Failed to load user data');
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      _isLoading.value = true;
      _logger.i('Starting registration for: $email');

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
      _logger.i('Creating Firebase user...');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.i('fire base credential created successfully!');
      _logger.d('Credential: $credential');

      if (credential.user != null) {
        _logger.i('Firebase user created successfully!');
        _logger.d('User ID: ${credential.user!.uid}');

        // Update display name
        await credential.user!.updateDisplayName(name);
        _logger.d('Display name updated to: $name');

        // Create user document in Firestore
        _logger.i('Creating User object...');
        final newUser = app_user.User(
          id: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _logger.d('User object created: $newUser');

        // Log the JSON conversion
        _logger.i('Converting to JSON...');
        final userJson = newUser.toJson();
        _logger.d('User JSON: $userJson');

        // Log each field in the JSON
        _logger.d('JSON Fields:');
        userJson.forEach((key, value) {
          _logger.d('  $key: $value (${value.runtimeType})');
        });

        // Try to save to Firestore
        _logger.i('Saving to Firestore...');
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userJson);

        _logger.i('Successfully saved to Firestore!');
        _appUser.value = newUser;
        _logger.d('App user set: ${_appUser.value}');
        Get.snackbar('Success', 'Registration successful!');
      } else {
        _logger.w('Firebase credential user is null');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Exception: ${e.code} - ${e.message}');
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
      _logger.e('General Exception: $e');
      _logger.e('Exception type: ${e.runtimeType}');
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      _logger.i('Registration process completed');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _logger.i('Starting login for: $email');

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
      _logger.i('Signing in with Firebase...');
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _logger.i('Login successful!');
      Get.snackbar('Success', 'Login successful!');
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e(
        'Firebase Auth Exception during login: ${e.code} - ${e.message}',
      );
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
      _logger.e('General Exception during login: $e');
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('Logging out...');
      await _auth.signOut();
      _appUser.value = null;
      _logger.i('Logout successful');
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      _logger.e('Logout error: $e');
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Resetting password for: $email');
      if (email.isEmpty) {
        Get.snackbar('Error', 'Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email');
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent');
      Get.snackbar('Success', 'Password reset email sent!');
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Password reset error: ${e.code} - ${e.message}');
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
      _logger.e('General password reset error: $e');
      Get.snackbar('Error', 'Password reset failed: ${e.toString()}');
    }
  }
}
