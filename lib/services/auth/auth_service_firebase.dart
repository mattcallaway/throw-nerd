import 'package:firebase_auth/firebase_auth.dart';
import 'auth_provider_interface.dart';

class FirebaseAuthProvider implements AuthProviderBase {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  String get providerId => 'firebase';

  @override
  Future<void> signIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }
  
  @override
  Future<String?> getUserId() async {
     return _auth.currentUser?.uid;
  }
  
  @override
  Future<String?> getUserDisplayName() async {
     return _auth.currentUser?.displayName ?? 'Anonymous';
  }
  
  @override
  dynamic getClient() => _auth;
}
