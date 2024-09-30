import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/home_controller.dart';
import '../controllers/route_controller.dart';

class RouteView extends StatelessWidget {
  final RouteController _routeController = Get.put(RouteController());
  final HomeController _homeController = Get.put(HomeController());

  RouteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Corrida'),
      ),
      body: Stack(
        children: [
          // Mapa do Google Maps
          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _homeController.currentPosition.value,
                  zoom: 15.0,
                ),
                onMapCreated: _routeController.onMapCreated,
                polylines: _routeController.polylines.value,
                markers: _routeController.markers.value,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              )),

          // Card na parte inferior com detalhes da corrida
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              elevation: 8.0,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text(
                          'Distância: ${_routeController.routeDistance.value} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          'Duração: ${_routeController.routeDuration.value} min',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        )),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          'Preço: R\$ ${_routeController.routePrice.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Função para solicitar a corrida
                        _routeController.solicitarCorrida();
                      },
                      child: const Text('Solicitar Corrida'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
