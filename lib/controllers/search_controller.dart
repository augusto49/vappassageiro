import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vappassageiro/controllers/route_controller.dart';
import '../controllers/home_controller.dart';
import '../services/api_service.dart';

class SearchController extends GetxController {
  final HomeController _homeController = Get.find<HomeController>();
  final RouteController _routeController = Get.find<RouteController>();
  final ApiService _apiService = ApiService();

  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  // Variável para controlar o estado de carregamento da rota
  var isRouteLoading = false.obs;
  var isLoading = false.obs;
  var showingOriginSuggestions = true.obs;
  // Lista de sugestões de autocomplete para origem e destino
  var originSuggestions = <Map<String, dynamic>>[].obs;
  var destinationSuggestions = <Map<String, dynamic>>[].obs;
  var canProceed = false.obs;
  var routeInfo = {}.obs;

  // Dio client para chamadas HTTP
  final Dio _dio = Dio();

  final String _placesApiKey = 'AIzaSyBfbgg59owdm2EaSD8OjnuBB6KCvD49kvs';

  @override
  void onInit() {
    super.onInit();
    // Preencher o campo "De onde?" com o endereço atual
    _loadCurrentAddress();

    // Atualizar o campo automaticamente se o endereço mudar
    ever(_homeController.currentAddress, (address) {
      originController.text = address;
    });

    originController.addListener(_updateCanProceed);
    destinationController.addListener(_updateCanProceed);
  }

  Future<void> _loadCurrentAddress() async {
    // Verifique se a posição atual está disponível
    if (_homeController.currentPosition.value != null) {
      final lat = _homeController.currentPosition.value.latitude;
      final lng = _homeController.currentPosition.value.longitude;

      // Use a geocoding para obter o endereço a partir da posição
      final addressList = await placemarkFromCoordinates(lat, lng);
      if (addressList.isNotEmpty) {
        final address = addressList.first;

        // Formatar o endereço completo
        String fullAddress = '';

        // Mapeamento de abreviações
        Map<String, String> abbreviations = {
          'Avenida': 'Av.',
          'Rua': 'R.',
          'Travessa': 'Tv.',
          'Estrada': 'Est.',
          'Praça': 'Pça.',
          // Adicione mais abreviações conforme necessário
        };

        // Função para substituir termos por abreviações
        String abbreviate(String street) {
          for (var entry in abbreviations.entries) {
            street = street.replaceAll(entry.key, entry.value);
          }
          return street;
        }

        if (address.thoroughfare != null) {
          fullAddress += abbreviate(address.thoroughfare!); // Logradouro
        }
        if (address.subThoroughfare != null) {
          fullAddress += ', ${address.subThoroughfare!}'; // Número
        }
        if (address.subLocality != null) {
          fullAddress += ' - ${address.subLocality!}'; // Bairro
        }
        if (address.locality != null) {
          fullAddress += ' - ${address.locality!}'; // Cidade
        }
        if (address.administrativeArea != null) {
          fullAddress += ' ${address.administrativeArea!}'; // Estado
        }
        if (address.country != null) {
          fullAddress += ' - ${address.country!}'; // País
        }

        // Atribuir o endereço formatado ao controller
        originController.text = fullAddress;
      }
    }
  }

  // Função que verifica se o botão "Avançar" pode ser habilitado
  void _updateCanProceed() {
    canProceed.value = originController.text.isNotEmpty &&
        destinationController.text.isNotEmpty;
  }

  // Função para obter sugestões de autocomplete
  Future<void> getAutocompleteSuggestions(String input,
      {bool isDestination = false}) async {
    if (input.isEmpty) return;

    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    final parameters = {
      'input': input,
      'key': _placesApiKey,
      'location':
          '${_homeController.currentPosition.value.latitude},${_homeController.currentPosition.value.longitude}',
      'radius': '5000',
    };

    try {
      final response = await _dio.get(url, queryParameters: parameters);

      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List;

        if (isDestination) {
          destinationSuggestions.value =
              predictions.map((e) => e as Map<String, dynamic>).toList();
        } else {
          originSuggestions.value =
              predictions.map((e) => e as Map<String, dynamic>).toList();
        }
      } else {
        if (kDebugMode) {
          print('Erro ao buscar sugestões: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar sugestões: $e');
      }
    }
  }

  // Função para traçar a rota usando a Google Directions API
  Future<void> drawRoute() async {
    // Iniciar o carregamento da rota
    isRouteLoading.value = true;
    final origin = originController.text;
    final destination = destinationController.text;

    final originCoords = await _getCoordinatesFromAddress(origin);
    final destinationCoords = await _getCoordinatesFromAddress(destination);

    if (originCoords == null || destinationCoords == null) {
      Get.snackbar(
        'Erro',
        'Não foi possível obter as coordenadas para a origem ou destino.',
        snackPosition: SnackPosition.BOTTOM,
      );
      isRouteLoading.value = false;
      return;
    }

    try {
      // Calcular rota usando a API do seu backend
      final result = await _apiService.calculateRoute(
        originLat: originCoords['lat']!,
        originLng: originCoords['lng']!,
        destinationLat: destinationCoords['lat']!,
        destinationLng: destinationCoords['lng']!,
      );

      final distance = result['distance_km'] as String;
      final price = result['price'] as String;
      final duration = result['duration_minutes'] as String;
      final encodedPolyline =
          result['route']['overview_polyline']['points'] as String;
      final boundsData = result['route']['bounds'] as Map<String, dynamic>;

      final northeast = boundsData['northeast'] as Map<String, dynamic>;
      final southwest = boundsData['southwest'] as Map<String, dynamic>;

      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(southwest['lat'], southwest['lng']),
        northeast: LatLng(northeast['lat'], northeast['lng']),
      );

      // Armazenar as informações da rota
      routeInfo.value = {
        'distance': distance,
        'price': price,
        'duration': duration,
      };

      // Traçar a rota no mapa usando a polyline codificada
      _routeController.setPolyline(
        encodedPolyline,
        LatLng(originCoords['lat']!, originCoords['lng']!), // Origem
        LatLng(destinationCoords['lat']!, destinationCoords['lng']!), // Destino
      );

      // Centralizar a câmera na rota
      _routeController.centerCameraOnRoute(bounds);

      // Atualizar as informações da rota no HomeController
      _routeController.updateRouteInfo(distance, duration, price);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao calcular rota: $e');
      }
      Get.snackbar(
        'Erro',
        'Não foi possível calcular a rota.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRouteLoading.value = false;
    }
  }

  Future<Map<String, double>?> _getCoordinatesFromAddress(
      String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return {'lat': location.latitude, 'lng': location.longitude};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter coordenadas: $e');
      }
    }
    return null;
  }
}
