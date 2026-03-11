import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email/password.
  // If no RM_users profile exists for this uid, auto-create one.
  // The very first user to sign in (empty RM_users collection) becomes admin.
  Future<UserModel?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    if (credential.user == null) return null;

    final uid = credential.user!.uid;
    UserModel? profile = await getUserProfile(uid);

    if (profile == null) {
      // Bootstrap: check if any users exist at all
      final existing = await _db.collection(colUsers).limit(1).get();
      final isFirstUser = existing.docs.isEmpty;

      profile = UserModel(
        userId: uid,
        name: email.split('@').first,
        email: email.trim(),
        // First ever user → admin. Everyone else → seller (admin can promote later).
        role: isFirstUser ? roleAdmin : roleSeller,
        active: true,
        createdAt: DateTime.now(),
      );
      await _db.collection(colUsers).doc(uid).set(profile.toFirestore());
    }

    return profile;
  }

  // Sign out
  Future<void> signOut() async => _auth.signOut();

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection(colUsers).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Stream user profile changes
  Stream<UserModel?> userProfileStream(String uid) {
    return _db.collection(colUsers).doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // Create user account (admin creating a seller account)
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    // Create in Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final uid = credential.user!.uid;

    final user = UserModel(
      userId: uid,
      name: name.trim(),
      email: email.trim(),
      role: role,
      active: true,
      createdAt: DateTime.now(),
    );

    await _db.collection(colUsers).doc(uid).set(user.toFirestore());
    return user;
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection(colUsers).doc(user.userId).update(user.toFirestore());
  }
}
