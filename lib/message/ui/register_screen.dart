// lib/message/ui/register_screen.dart

import 'package:flutter/material.dart';
import 'package:likelion/message/DI/service_locator.dart';
import 'package:likelion/message/services/auth/auth_service.dart';
import 'package:likelion/message/widgets/my_button.dart';
import 'package:likelion/message/widgets/my_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.callBack});
  final VoidCallback callBack; // 콜백은 로그인 페이지로 돌아가기 위함

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pwConfirmController = TextEditingController();

  late AuthServices _authService; // initState에서 초기화할 변수 선언

  @override
  void initState() {
    super.initState();
    _authService = locator.get<AuthServices>(); // GetIt에서 AuthServices 가져오기
  }

  Future<void> signUp(
      String email, String password, String passwordConfirm) async {
    if (password == passwordConfirm) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        await _authService.signUp(email, password); // _authService 사용
        if (!mounted) return;
        Navigator.pop(context); // 로딩 다이얼로그 닫기
        widget.callBack(); // 회원가입 성공 후 이전 화면 (로그인 페이지)으로 돌아가기 위해 콜백 호출
      } on Exception catch (ex) {
        if (!mounted) return;
        Navigator.pop(context); // 로딩 다이얼로그 닫기
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(ex.toString()),
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Passwords don't match"),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Icon(
                Icons.person_add,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                height: 50,
              ),
              // 메시지
              Text(
                "Let's create an account for you!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              // 이메일 텍스트필드
              MyTextField(
                hint: "Email",
                obsecure: false,
                controller: emailController,
              ),
              const SizedBox(
                height: 10,
              ),
              // 비밀번호 텍스트필드
              MyTextField(
                hint: "Password",
                obsecure: true,
                controller: passwordController,
              ),
              const SizedBox(
                height: 10,
              ),
              // 비밀번호 확인 텍스트필드
              MyTextField(
                hint: "Confirm Password",
                obsecure: true,
                controller: pwConfirmController,
              ),
              const SizedBox(
                height: 25,
              ),
              // 회원가입 버튼
              MyButton(
                text: "Register",
                onTap: () async {
                  await signUp(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                    pwConfirmController.text.trim(),
                  );
                },
              ),
              const SizedBox(
                height: 25,
              ),
              // 로그인 페이지로 돌아가기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.callBack, // 콜백을 호출하여 이전 페이지(로그인)로 돌아감
                    child: Text(
                      "Login now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}