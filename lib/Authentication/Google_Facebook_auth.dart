import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null;

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

  final user = userCredential.user;
  if (user != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'provider': 'google',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  return userCredential;
}


Future<UserCredential?> signInWithFacebook() async {
  final LoginResult result = await FacebookAuth.instance.login();

  if (result.status == LoginStatus.success && result.accessToken != null) {
    final OAuthCredential credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } else {
    print("Facebook login failed: ${result.status}, ${result.message}");
    return null;
  }
}
