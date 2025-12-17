abstract class AuthProviderBase {
  String get providerId; // 'firebase', 'gdrive', 'dropbox'
  
  Future<void> signIn();
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<String?> getUserId();
  Future<String?> getUserDisplayName();
  
  // Return the underlying client if needed (e.g. GoogleSignInAccount or HttpClient)
  dynamic getClient(); 
}
