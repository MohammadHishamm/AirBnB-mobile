import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthServices {
  final auth = FirebaseAuth.instance;

  final googleSignIn = GoogleSignIn(
    clientId:
        '356192158933-qta0vj9gvfgqd94gm7d9rmov0mspgtft.apps.googleusercontent.com', // Explicitly set the client ID for web
  );
  Future<void> signInWithGoogle() async {
    try {
      print('Starting Google sign-in...');
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        print('Google account selected: ${googleSignInAccount.email}');
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        print('Google authentication successful');
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        print('Credentials obtained. Signing in to Firebase...');
        UserCredential userCredential =
            await auth.signInWithCredential(authCredential);
        print('Signed in user: ${userCredential.user?.email}');
      } else {
        print('Google sign-in was canceled by the user.');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      print('Signing out...');
      // Sign out from Firebase
      await auth.signOut();
      // Disconnect from GoogleSignIn
      await googleSignIn.disconnect();
      print('User successfully signed out.');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
