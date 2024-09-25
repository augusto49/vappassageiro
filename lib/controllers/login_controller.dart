import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/storage_util.dart';

class LoginController extends GetxController {
  final ApiService apiService = ApiService();
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  Future<void> login() async {
    isLoading(true);
    final email = emailController.text;
    final password = passwordController.text;

    try {
      final user = await apiService.login(email, password);

      // Salvar o token
      StorageUtil.saveToken(user.accessToken);

      Get.snackbar('Login', 'Login bem-sucedido!');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Função para navegação para a tela de registro
  void navigateToRegister() {
    Get.toNamed('/register');
  }
}
