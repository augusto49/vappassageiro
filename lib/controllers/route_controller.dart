import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteController extends GetxController {
  final Rx<Set<Polyline>> polylines = Rx<Set<Polyline>>({});
  final RxString routeDistance = ''.obs;
  final RxString routeDuration = ''.obs;
  final RxString routePrice = ''.obs;
  final RxBool isMapReady = false.obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final Rx<Set<Marker>> markers = Rx<Set<Marker>>({});

  // Função para centralizar a câmera na rota
  void centerCameraOnRoute(LatLngBounds bounds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0), // Padding ajustável
      );
    }
  }

  // Função para configurar a polyline no mapa
  void setPolyline(String encodedPolyline, LatLng origin, LatLng destination) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);

    // Converte para uma lista de LatLng
    List<LatLng> polylineCoordinates =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();

    // Cria a polyline
    Polyline polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );

    polylines.value = {polyline};

    // Adiciona marcadores de origem e destino
    markers.value = {
      Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        infoWindow: const InfoWindow(title: 'Origem'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: const InfoWindow(title: 'Destino'),
      ),
    };

    // Centraliza a câmera para cobrir toda a rota
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        origin.latitude < destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude < destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        origin.latitude > destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude > destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
    );
    centerCameraOnRoute(bounds);
  }

  // Método para atualizar as informações da rota
  void updateRouteInfo(String distance, String duration, String price) {
    routeDistance.value = distance;
    routeDuration.value = duration;
    routePrice.value = price;
  }

  // Função para criar o mapa
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    isMapReady.value = true;
  }

  // Função para solicitar corrida
  void solicitarCorrida() {
    // Adicione aqui a lógica para solicitar a corrida,
    // como chamar uma API ou acionar o serviço correspondente.
    Get.snackbar(
      'Solicitação Enviada',
      'A corrida foi solicitada com sucesso!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
