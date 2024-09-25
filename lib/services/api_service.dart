import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/storage_util.dart';

class ApiService {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = 'http://192.168.3.74:8000/';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageUtil.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          Get.snackbar(
            'Sem Conexão',
            'Você está offline. Verifique sua conexão com a internet.',
            snackPosition: SnackPosition.BOTTOM,
          );
          throw dio.DioException(
            requestOptions: options,
            error: 'Sem conexão com a internet',
          );
        }

        if (kDebugMode) {
          print('Requisição: ${options.method} ${options.uri}');
          print('Header: ${options.headers}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('Resposta: ${response.statusCode} ${response.data}');
        }
        return handler.next(response);
      },
      onError: (dio.DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          if (kDebugMode) {
            print('Erro 401: Token expirado ou inválido');
          }

          try {
            final refreshToken = await StorageUtil.getRefreshToken();
            if (refreshToken == null) {
              throw dio.DioException(
                requestOptions: e.response!.requestOptions,
                error: 'Refresh token não encontrado',
              );
            }

            final response =
                await _dio.post('/api/v1/auth/token/refresh/', data: {
              'refresh': refreshToken,
            });

            final newAccessToken = response.data['access'];
            await StorageUtil.saveToken(newAccessToken);

            if (kDebugMode) {
              print('Novo Access Token salvo: $newAccessToken');
            }

            final options = e.response!.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            if (kDebugMode) {
              print('Erro ao atualizar token: $refreshError');
            }
            Get.offAllNamed('/login');
          }
        }

        if (kDebugMode) {
          print('Erro: $e');
        }
        return handler.next(e);
      },
    ));
  }

  // Função para atualizar o token de acesso usando o refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );
      return response.data as Map<String, dynamic>;
    } on dio.DioException catch (e) {
      throw Exception('Falha ao atualizar o token: ${e.response?.data}');
    }
  }

  // Login
  Future<User> login(String email, String password) async {
    // Verificar conexão com a internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar(
        'Sem Conexão',
        'Você está offline. Verifique sua conexão com a internet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw Exception('Sem conexão com a internet');
    }
    try {
      final response = await _dio.post(
        '/api/v1/auth/passenger/login/',
        data: {'email': email, 'password': password},
      );

      final user = User.fromJson(response.data as Map<String, dynamic>);

      // Salvar tokens
      await StorageUtil.saveToken(user.accessToken);
      await StorageUtil.saveRefreshToken(user.refreshToken);
      await StorageUtil.saveUserId(user.userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_full_name', user.fullName);

      if (kDebugMode) {
        print('Login bem-sucedido');
      } // Debug
      if (kDebugMode) {
        print('User: ${user.email}, Token: ${user.accessToken}');
      } // Debug

      return user;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou senha inválidos');
      } else {
        throw Exception(
            'Ocorreu um erro ao realizar o login. Tente novamente mais tarde.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro inesperado: $e');
      }
      rethrow;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
      Map<String, dynamic> registrationData, Map<String, File?> files) async {
    try {
      // Cria um FormData para enviar dados e arquivos
      dio.FormData formData = dio.FormData.fromMap({
        ...registrationData,
      });

      files.forEach((key, file) {
        if (file != null) {
          formData.files.add(
            MapEntry(
              key,
              dio.MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }
      });

      final response = await _dio.post(
        '/api/v1/auth/passenger/register/',
        data: formData,
        options: dio.Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data as Map<String, dynamic>;
    } on dio.DioException catch (e) {
      throw Exception('Falha ao registrar: ${e.response?.data}');
    }
  }

  // Verificação email OTP
  Future<void> verifyEmail(String otp) async {
    try {
      await _dio.post(
        '/api/v1/auth/verify-email/',
        data: {'otp': otp},
      );
    } on dio.DioException catch (e) {
      throw Exception('Failed to verify email: ${e.response?.data}');
    }
  }

  // Reset de senha
  Future<void> requestPasswordReset(String email, String userType) async {
    try {
      await _dio.post(
        '/api/v1/auth/password-reset/',
        data: {
          'email': email,
          'user_type': userType,
        },
      );
    } on dio.DioException catch (e) {
      throw Exception('Failed to request password reset: ${e.response?.data}');
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = await StorageUtil.getRefreshToken();
    final refreshTokenExpiry = await StorageUtil.getRefreshTokenExpiry();

    // Verificar se o refresh token expirou
    if (refreshToken == null ||
        refreshTokenExpiry == null ||
        refreshTokenExpiry.isBefore(DateTime.now())) {
      // O refresh token expirou, forçar logout
      Get.snackbar(
        'Sessão Expirada',
        'Sua sessão expirou, por favor faça login novamente.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Limpar o armazenamento local e SharedPreferences
      await StorageUtil.removeToken();
      await StorageUtil.removeRefreshToken();
      await StorageUtil.removeUserId();
      await prefs.remove('user_full_name');

      // Redirecionar para a tela de login
      Get.offAllNamed('/login');
      return;
    }

    try {
      final accessToken = await StorageUtil.getToken();

      // Fazer requisição para logout
      await _dio.post(
        '/api/v1/auth/passenger/logout/',
        options: dio.Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
        data: {'refresh_token': refreshToken},
      );

      // Limpar os dados de autenticação do dispositivo
      await StorageUtil.removeToken();
      await StorageUtil.removeRefreshToken();
      await StorageUtil.removeUserId();
      await prefs.remove('user_full_name');

      if (kDebugMode) {
        print('Logout bem-sucedido');
      }

      // Redirecionar para a tela de login
      Get.offAllNamed('/login');
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('Falha ao realizar logout: ${e.response?.data}');
      }

      throw Exception('Falha ao realizar logout.');
    }
  }

  // Função de solicitar corrida
  Future<Map<String, dynamic>> requestRide({
    required Map<String, double> startLocation,
    required Map<String, double> endLocation,
  }) async {
    try {
      // Verificar conexão com a internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Get.snackbar(
          'Sem Conexão',
          'Você está offline. Verifique sua conexão com a internet.',
          snackPosition: SnackPosition.BOTTOM,
        );
        throw Exception('Sem conexão com a internet');
      }

      // Fazer a requisição de corrida
      final response = await _dio.post(
        '/api/v1/passenger/ride-request/',
        data: {
          'start_location': {
            'coordinates': [
              startLocation['latitude'],
              startLocation['longitude']
            ],
          },
          'end_location': {
            'coordinates': [endLocation['latitude'], endLocation['longitude']],
          },
        },
      );

      // Retornar os dados da corrida (preço, distância, etc.)
      return response.data as Map<String, dynamic>;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('Erro ao solicitar corrida: ${e.response?.data}');
      }
      throw Exception('Erro ao solicitar corrida.');
    }
  }

  // Calcular rota
  Future<Map<String, dynamic>> calculateRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    try {
      // Verificar conexão com a internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Get.snackbar(
          'Sem Conexão',
          'Você está offline. Verifique sua conexão com a internet.',
          snackPosition: SnackPosition.BOTTOM,
        );
        throw Exception('Sem conexão com a internet');
      }

      // Obter o token de acesso
      final accesstoken = await StorageUtil.getToken();

      final response = await _dio.post(
        '/api/v1/auth/passenger/calculate-route/',
        data: {
          'origin_lat': originLat,
          'origin_lng': originLng,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
        },
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('Erro ao calcular rota: ${e.response?.data}');
      }
      Get.snackbar(
        'Erro',
        'Ocorreu um erro ao calcular a rota. Tente novamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw Exception('Erro ao calcular rota.');
    }
  }
}
