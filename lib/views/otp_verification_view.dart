import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class OtpVerificationView extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());
  final TextEditingController otpController = TextEditingController();

  OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments['email'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação de Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Enviamos um código OTP para $email.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Código OTP',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final otp = otpController.text.trim();
                if (otp.isNotEmpty) {
                  controller.verifyOtp(otp);
                } else {
                  Get.snackbar(
                    'Erro',
                    'Por favor, insira o código OTP.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
