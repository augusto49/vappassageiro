import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reset_password_request_controller.dart';

class ResetPasswordRequestView extends StatelessWidget {
  final ResetPasswordController controller = Get.put(ResetPasswordController());

  ResetPasswordRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        await controller.requestPasswordReset();
                        if (controller.resetSuccessful.value) {
                          Get.defaultDialog(
                            title: 'Sucesso',
                            middleText:
                                'Verifique seu email para redefinir a senha.',
                            onConfirm: () {
                              Get.offAllNamed('/login');
                            },
                            textConfirm: 'OK',
                          );
                        } else {
                          Get.snackbar(
                            'Erro',
                            'Falha ao solicitar redefinição de senha. Tente novamente.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text('Redefinir Senha'),
                    ),
            ],
          ),
        );
      }),
    );
  }
}
