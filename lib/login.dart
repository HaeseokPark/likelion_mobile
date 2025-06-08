import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      // final googleSignIn = GoogleSignIn(
      //   clientId: '852353724402-daa0lne1qv37qsbe4ea57e42da5bte3t.apps.googleusercontent.com',
      // );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        await saveUserInfo(user); // Firestore에 사용자 정보 저장
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError(context, 'Google 로그인 실패: $e');
    }
  }

  Future<void> saveUserInfo(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignIn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset("DOST-logo.png", width: 200, height: 200),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => signInWithGoogle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.grey),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image.asset('google.png', height: 24),
                  const SizedBox(width: 10),
                  const Text('Google로 로그인'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
