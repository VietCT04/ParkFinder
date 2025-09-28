import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Sign In with Firestore Verification
  Future<User?> signInWithFirestore(String email, String password) async {
    try {
      var userQuery =
          await _firestore
              .collection("users")
              .where("email", isEqualTo: email)
              .get();

      if (userQuery.docs.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user;
      } else {
        print("Invalid credentials");
        return null;
      }
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // 🔹 Register New User in Firestore & Firebase Auth
  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "email": email,
          "name": name,
          "phoneNumber": phoneNumber,
          "createdAt": Timestamp.now(),
          "isAdmin": false,
          "isBanned": false,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }

  // 🔹 New signOut Method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
