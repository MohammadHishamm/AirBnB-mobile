import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn(); // No clientId needed for emulator/mobile

  // Define default user type
  static const String defaultUserType = 'customer';

  Future<void> signInWithGoogle() async {
    try {
      print('Starting Google sign-in...');
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        print('Google account selected: ${googleSignInAccount.email}');
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        print('Google authentication successful');
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Credentials obtained. Signing in to Firebase...');
        UserCredential userCredential =
            await auth.signInWithCredential(authCredential);
        print('Signed in user: ${userCredential.user?.email}');

        await _checkAndSetUserType(userCredential.user!);
      } else {
        print('Google sign-in was canceled by the user.');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  Future<void> signOut() async {
    try {
      print('Signing out...');
      await auth.signOut();
      await googleSignIn.disconnect();
      print('User successfully signed out.');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _checkAndSetUserType(User user) async {
    try {
      // Get the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // If user exists, we don't need to set the user type again
        String userType = userDoc['userType'];
        print('User type is: $userType');
      } else {
        // If user doesn't exist, create a new user document and assign them the default type 'customer'
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'userType': defaultUserType, // Set user type as 'customer' by default
        });
        print('New user created with default user type: $defaultUserType');
      }
    } catch (e) {
      print('Error checking and setting user type: $e');
    }
  }

  // You can use this method to retrieve the user type if needed
  Future<String?> getUserType(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['userType'];
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }
}
