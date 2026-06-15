import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_service.dart';

class FirebaseAuthService {
  static bool _googleSignInReady = false;

  static Future<void> _ensureFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp();
  }

  static Future<void> _ensureGoogleSignIn() async {
    if (_googleSignInReady) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInReady = true;
  }

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    await _ensureFirebase();
    await _ensureGoogleSignIn();

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final firebaseUser = userCredential.user;
    if (firebaseUser == null || firebaseUser.email == null) {
      throw Exception('Google account has no email');
    }

    return ApiService.googleLogin(
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName ?? googleUser.displayName ?? '',
      firebaseUid: firebaseUser.uid,
      photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
      idToken: await firebaseUser.getIdToken(),
    );
  }

  static Future<Map<String, dynamic>> signInWithFacebook() async {
    await _ensureFirebase();
    await FacebookAuth.instance.logOut();

    final loginResult = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
      loginBehavior: LoginBehavior.webOnly,
      loginTracking: LoginTracking.enabled,
    );
    if (loginResult.status != LoginStatus.success ||
        loginResult.accessToken == null) {
      throw Exception(
        'Facebook login ${loginResult.status.name}: '
        '${loginResult.message ?? 'No error message'}',
      );
    }

    final accessToken = loginResult.accessToken!;
    final credential = FacebookAuthProvider.credential(accessToken.tokenString);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Cannot read Facebook account');
    }

    final facebookProfile = await FacebookAuth.instance.getUserData(
      fields: 'name,email,picture.width(200)',
    );
    final picture = facebookProfile['picture'];
    final pictureData = picture is Map<String, dynamic>
        ? picture['data']
        : null;
    final pictureUrl = pictureData is Map<String, dynamic>
        ? pictureData['url'] as String?
        : null;
    final facebookEmail = facebookProfile['email'] is String
        ? facebookProfile['email'] as String
        : null;
    final facebookName = facebookProfile['name'] is String
        ? facebookProfile['name'] as String
        : null;

    return ApiService.facebookLogin(
      email: firebaseUser.email ?? facebookEmail,
      displayName: firebaseUser.displayName ?? facebookName ?? 'Facebook User',
      firebaseUid: firebaseUser.uid,
      photoUrl: firebaseUser.photoURL ?? pictureUrl,
      idToken: await firebaseUser.getIdToken(),
    );
  }
}
