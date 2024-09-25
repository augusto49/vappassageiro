import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/storage_util.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  final Rx<LatLng> currentPosition = Rx<LatLng>(const LatLng(0.0, 0.0));
  final RxString currentAddress = ''.obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _loadUserId();
    getCurrentLocation();
  }

  Future<void> _loadUserId() async {
    final userId = await StorageUtil.getUserId();
    if (userId != null) {
      // Use o userId conforme necessário
    }
  }

  // Carregar o nome do usuário
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_full_name') ?? 'Usuário';
  }

  // Obter a localização atual
  Future<void> getCurrentLocation() async {
    try {
      // Verifica se o serviço de localização está ativado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desativado.');
      }

      // Verifica permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Permissão de localização negada.');
        }
      }

      // Obtém a localização atual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Atualiza a posição no estado
      currentPosition.value = LatLng(position.latitude, position.longitude);

      // Converte as coordenadas para um endereço legível
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Pega o endereço formatado do primeiro resultado
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      } else {
        currentAddress.value = 'Endereço não encontrado';
      }

      // Move a câmera do mapa para a localização atual
      if (mapController.value != null) {
        mapController.value!.animateCamera(
          CameraUpdate.newLatLng(currentPosition.value),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter a localização: $e');
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao realizar logout. Tente novamente mais tarde.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
