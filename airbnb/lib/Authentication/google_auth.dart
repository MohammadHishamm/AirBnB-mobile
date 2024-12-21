import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn(); // No clientId needed for emulator/mobile

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
}
