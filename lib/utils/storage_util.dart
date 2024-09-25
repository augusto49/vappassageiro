import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);

    // Calcular a expiração do token de acesso (15 minutos)
    final expiryDate = DateTime.now().add(const Duration(minutes: 15));
    await prefs.setString('access_token_expiry', expiryDate.toIso8601String());

    if (kDebugMode) {
      print('Access Token salvo: $token');
    } // Debug
  }

  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString('access_token_expiry');
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null; // Se não houver data de expiração salva
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (kDebugMode) {
      print('Access Token recuperado: $token');
    } // Debug
    return token;
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);

    // Calcular a expiração do refresh token (7 dias)
    final expiryDate = DateTime.now().add(const Duration(days: 7));
    await prefs.setString('refresh_token_expiry', expiryDate.toIso8601String());
  }

  static Future<DateTime?> getRefreshTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString('refresh_token_expiry');
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null; // Se não houver data de expiração salva
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('refresh_token');
    if (kDebugMode) {
      print('Refresh Token recuperado: $token');
    } // Debug
    return token;
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    if (kDebugMode) {
      print('User ID salvo: $userId');
    }
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('access_token_expiry');
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token');
    await prefs.remove('refresh_token_expiry');
  }
}
