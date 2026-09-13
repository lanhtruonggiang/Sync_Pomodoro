import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Gửi Magic Link về Email
  Future<void> sendPasswordlessLink(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: Uri.base.origin, // Tự động redirect về trang Web hiện tại
      handleCodeInApp: true,
      iOSBundleId: 'com.example.pomodoro',
      androidPackageName: 'com.example.pomodoro',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await _auth.sendSignInLinkToEmail(
      email: email.trim(),
      actionCodeSettings: actionCodeSettings,
    );
  }

  // Xác thực Link người dùng bấm vào
  Future<void> completeSignInWithEmailLink(String email, String emailLink) async {
    if (_auth.isSignInWithEmailLink(emailLink)) {
      await _auth.signInWithEmailLink(email: email.trim(), emailLink: emailLink);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}