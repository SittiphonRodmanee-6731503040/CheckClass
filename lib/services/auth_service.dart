import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(name);
      final userModel = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
      );
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());
      // Ensure the write reaches the server before returning
      await _firestore.waitForPendingWrites();
      return userModel;
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      return await getUserProfile(credential.user!.uid);
    }
    return null;
  }

  // Get user profile from Firestore (always fetch from server)
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get(const GetOptions(source: Source.server));
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
