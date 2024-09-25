import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: loginController.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: loginController.passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              loginController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: loginController.login,
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () => loginController.navigateToRegister(),
                child: const Text('Não tem uma conta? Registre-se'),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/reset-password'),
                child: const Text('Esqueceu sua senha?'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
