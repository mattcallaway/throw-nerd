import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'auth_provider_interface.dart';

class GoogleDriveAuthProvider implements AuthProviderBase {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveAppdataScope,
    ],
  );
  
  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  @override
  String get providerId => 'gdrive';

  @override
  Future<void> signIn() async {
    _currentUser = await _googleSignIn.signIn();
    await _updateClient();
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
    _driveApi = null;
  }

  @override
  Future<bool> isSignedIn() async {
    if (_currentUser != null) return true;
    _currentUser = await _googleSignIn.signInSilently();
    if (_currentUser != null) {
       await _updateClient();
       return true;
    }
    return false;
  }
  
  Future<void> _updateClient() async {
     try {
       if (_currentUser == null) return;
       final auth = await _currentUser!.authentication;
       final token = auth.accessToken;
       if (token != null) {
          final client = AuthenticatedClient(token, http.Client());
          _driveApi = drive.DriveApi(client);
       }
     } catch (e) {
       print('GDrive Client Error: $e');
     }
  }
  
  @override
  Future<String?> getUserId() async {
    return _currentUser?.email; // Use email as ID for Drive
  }
  
  @override
  Future<String?> getUserDisplayName() async {
     return _currentUser?.displayName;
  }
  
  @override
  dynamic getClient() => _driveApi;
}

class AuthenticatedClient extends http.BaseClient {
  final String accessToken;
  final http.Client _inner;

  AuthenticatedClient(this.accessToken, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _inner.send(request);
  }
}
