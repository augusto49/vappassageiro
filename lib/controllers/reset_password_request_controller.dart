import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';

class ResetPasswordController extends GetxController {
  final ApiService _apiService = ApiService();
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool resetSuccessful = false.obs;
  final RxString userType = 'passenger'.obs;

  // Função para solicitar redefinição de senha
  Future<void> requestPasswordReset() async {
    isLoading.value = true;
    try {
      await _apiService.requestPasswordReset(
          emailController.text, userType.value);
      resetSuccessful.value = true;
    } catch (e) {
      resetSuccessful.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
