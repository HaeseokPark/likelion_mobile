// lib/message/services/auth/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // GoogleSignIn 임포트 추가

class AuthServices {
  final FirebaseAuth user;
  final FirebaseFirestore _database;

  AuthServices(this._database, this.user);

  User? getCurrentuser() {
    return user.currentUser;
  }

  Future<UserCredential> signIn(String email, password) async {
    try {
      final UserCredential userCredential = await user
          .signInWithEmailAndPassword(email: email, password: password);
      _database
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(
        {
          "uid": userCredential.user!.uid,
          "email": email,
        },
        SetOptions(merge: true), // 기존 데이터와 병합
      );
      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  // Google 로그인 메서드 추가
  Future<UserCredential> signInWithGoogle() async {
    try {
      // clientId를 명시적으로 설정 (웹 환경에서 특히 중요)
      // 실제 앱에서는 이 clientId를 Firebase 콘솔에서 얻은 웹 클라이언트 ID로 교체해야 합니다.
      // 예시: GoogleSignIn(clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com');
      final googleSignIn = GoogleSignIn(
        clientId: '852353724402-daa0lne1qv37qsbe4ea57e42da5bte3t.apps.googleusercontent.com', // login.dart에 있던 예시 clientId 사용
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google 로그인 취소됨");
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await user.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _database
            .collection("Users")
            .doc(userCredential.user!.uid)
            .set(
          {
            "uid": userCredential.user!.uid,
            "email": userCredential.user!.email,
            "displayName": userCredential.user!.displayName,
            "photoURL": userCredential.user!.photoURL,
          },
          SetOptions(merge: true), // 기존 데이터와 병합
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Google 로그인 실패: $e");
    }
  }

  @override
  Future<void> signOut() async {
    await user.signOut();
    // Google 로그인 상태도 함께 로그아웃
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }

  Future<UserCredential> signUp(String email, password) async {
    try {
      final UserCredential userCredential = await user
          .createUserWithEmailAndPassword(email: email, password: password);
      _database
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(
        {
          "uid": userCredential.user!.uid,
          "email": email,
        },
        SetOptions(merge: true), // 기존 데이터와 병합
      );

      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }
}