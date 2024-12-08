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
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await auth.signInWithCredential(authCredential);
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
