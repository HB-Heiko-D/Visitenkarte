// Conceptual representation of an Authentication Service using Firebase.
// This would contain methods to interact with Firebase Authentication.

import 'package_rename/firebase_auth.dart'; // Simulated import
import 'package_rename/cloud_firestore.dart'; // Simulated import
import '../models/user_model.dart'; // Simulated import

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up with Email and Password
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Step 1: Create user with Firebase Authentication
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Step 2: Check if username is already taken (conceptual)
        // This is a simplified check. In a real app, this needs to be robust,
        // possibly using a separate 'usernames' collection and Firestore rules
        // or a Cloud Function to ensure atomicity and prevent race conditions.
        final usernameDoc = await _firestore.collection('usernames').doc(username.toLowerCase()).get();
        if (usernameDoc.exists) {
          // Username is taken, cleanup created user (or handle differently)
          await user.delete(); // Simplistic cleanup
          return "Username already taken.";
        }

        // Step 3: Create a user profile document in Firestore
        UserProfile newUserProfile = UserProfile(
          uid: user.uid,
          username: username,
          email: email,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUserProfile.toJson());

        // Step 4: Reserve the username (conceptual)
        await _firestore.collection('usernames').doc(username.toLowerCase()).set({'uid': user.uid});

        return null; // Success
      }
      return "User could not be created.";
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase Auth error message
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
  }

  // Sign in with Email and Password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase Auth error message
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Password Reset
  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
  }

  // Get UserProfile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      // Handle error (e.g., log it)
      print("Error fetching user profile: $e");
      return null;
    }
  }

  // Update UserProfile in Firestore
  Future<String?> updateUserProfile(String uid, Map<String, dynamic> dataToUpdate) async {
    try {
      // Add username uniqueness check if username is being updated
      if (dataToUpdate.containsKey('username')) {
          String newUsername = dataToUpdate['username'] as String;
          UserProfile? currentUserProfile = await getUserProfile(uid);
          if (currentUserProfile != null && currentUserProfile.username.toLowerCase() != newUsername.toLowerCase()) {
            // Username is being changed, check for availability
            final usernameDoc = await _firestore.collection('usernames').doc(newUsername.toLowerCase()).get();
            if (usernameDoc.exists) {
              return "Username already taken.";
            }
            // If available, update the usernames collection (delete old, add new)
            await _firestore.collection('usernames').doc(currentUserProfile.username.toLowerCase()).delete();
            await _firestore.collection('usernames').doc(newUsername.toLowerCase()).set({'uid': uid});
          }
      }
      await _firestore.collection('users').doc(uid).update(dataToUpdate);
      return null; // Success
    } catch (e) {
      print("Error updating user profile: $e");
      return "Failed to update profile.";
    }
  }
}

// Simulated Firebase & Firestore classes for the purpose of this conceptual file
// In a real Flutter project, these would be imported from the firebase_auth and cloud_firestore packages.
class FirebaseAuth {
  static FirebaseAuth get instance => FirebaseAuth();
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  Future<void> signOut() async => throw UnimplementedError();
  Future<void> sendPasswordResetEmail({required String email}) async => throw UnimplementedError();
  User? get currentUser => null;
  Stream<User?> authStateChanges() => Stream.empty();
}

class UserCredential { User? get user => null; }
class User { String get uid => "simulated_uid"; Future<void> delete() async {} }
class FirebaseAuthException implements Exception { String? message; }

class FirebaseFirestore {
  static FirebaseFirestore get instance => FirebaseFirestore();
  CollectionReference collection(String name) => CollectionReference();
}

class CollectionReference {
  DocumentReference doc(String id) => DocumentReference();
  Future<QuerySnapshot> get() async => QuerySnapshot([]); // Simulate get for username check
}

class DocumentReference {
  Future<void> set(Map<String, dynamic> data) async {}
  Future<void> update(Map<String, dynamic> data) async {}
  Future<DocumentSnapshot> get() async => DocumentSnapshot(false, {});
  Future<void> delete() async {}
}

class DocumentSnapshot {
  final bool exists;
  final Map<String, dynamic> _data;
  DocumentSnapshot(this.exists, this._data);
  Map<String, dynamic>? data() => exists ? _data : null;
  String get id => "simulated_doc_id";
}
class QuerySnapshot {
  final List<DocumentSnapshot> docs;
  QuerySnapshot(this.docs);
  bool get isEmpty => docs.isEmpty;
}

// End of simulated classes
namespace services {} // To satisfy the linter for package_rename
namespace models {} // To satisfy the linter for package_rename
