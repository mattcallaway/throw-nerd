import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider_interface.dart';
import 'auth_service_firebase.dart';
import 'auth_service_gdrive.dart';
// import 'auth_service_dropbox.dart';

class AuthCoordinator {
  final Map<String, AuthProviderBase> _providers = {};
  
  AuthCoordinator() {
    _register(FirebaseAuthProvider());
    _register(GoogleDriveAuthProvider());
    // _register(DropboxAuthProvider());
  }
  
  void _register(AuthProviderBase provider) {
    _providers[provider.providerId] = provider;
  }
  
  AuthProviderBase? getProvider(String id) => _providers[id];
  
  Future<void> connect(String providerId) async {
    final p = _providers[providerId];
    if (p != null) {
      await p.signIn();
    }
  }
  
  Future<void> disconnect(String providerId) async {
    final p = _providers[providerId];
    if (p != null) {
      await p.signOut();
    }
  }
  
  Future<bool> isConnected(String providerId) async {
     return await _providers[providerId]?.isSignedIn() ?? false;
  }
}

final authCoordinatorProvider = Provider<AuthCoordinator>((ref) => AuthCoordinator());
