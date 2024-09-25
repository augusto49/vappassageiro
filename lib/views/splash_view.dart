import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../utils/storage_util.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    _checkLoginStatus();

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Adicione seu logotipo ou animação aqui
            Icon(
              Icons.accessibility_new,
              size: 100.0,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Bem-vindo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    final refreshToken = await StorageUtil.getRefreshToken();
    final refreshTokenExpiry = await StorageUtil.getRefreshTokenExpiry();

    if (refreshToken != null &&
        refreshTokenExpiry != null &&
        DateTime.now().isBefore(refreshTokenExpiry)) {
      try {
        final apiService = ApiService();
        final response = await apiService.refreshToken(refreshToken);

        final newAccessToken = response['access'];
        await StorageUtil.saveToken(newAccessToken);

        // Redirecionar para a tela inicial se o login for bem-sucedido
        Future.microtask(() {
          Get.offAllNamed('/home');
        });
      } catch (e) {
        if (kDebugMode) {
          print('Falha ao fazer login automático: $e');
        }
        // Se falhar, redirecionar para a tela de login
        Future.microtask(() {
          Get.offAllNamed('/login');
        });
      }
    } else {
      // Refresh token expirado ou não definido, redirecionar para a tela de login
      Future.microtask(() {
        Get.offAllNamed('/login');
      });
    }
  }
}
