import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as custom;

class SearchDestinationView extends StatelessWidget {
  final custom.SearchController _searchController =
      Get.put(custom.SearchController());

  SearchDestinationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar destino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo "De onde?" (Localização atual)
            TextField(
              controller: _searchController.originController,
              decoration: InputDecoration(
                hintText: 'De onde?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(
                  Icons.circle,
                  size: 14,
                ),
              ),
              onChanged: (value) {
                // Atualiza as sugestões de locais de partida
                _searchController.getAutocompleteSuggestions(value);
              },
            ),
            const SizedBox(height: 16),

            // Sugestões de locais de partida
            Obx(() {
              if (_searchController.originSuggestions.isEmpty) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: _searchController.originSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion =
                        _searchController.originSuggestions[index];
                    return ListTile(
                      title: Text(suggestion['description']),
                      onTap: () {
                        // Seleciona o local de origem
                        _searchController.originController.text =
                            suggestion['description'];
                        _searchController.originSuggestions.clear();
                      },
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Campo "Para onde?" (Destino)
            TextField(
              controller: _searchController.destinationController,
              decoration: InputDecoration(
                hintText: 'Para onde?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(
                  Icons.square,
                  size: 14,
                  color: Colors.red,
                ),
              ),
              onChanged: (value) {
                // Atualiza as sugestões de locais de destino
                _searchController.getAutocompleteSuggestions(value,
                    isDestination: true);
              },
            ),

            // Sugestões de locais de destino
            Obx(() {
              if (_searchController.destinationSuggestions.isEmpty) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: _searchController.destinationSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion =
                        _searchController.destinationSuggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(suggestion['description']),
                      onTap: () {
                        // Seleciona o local de destino
                        _searchController.destinationController.text =
                            suggestion['description'];
                        _searchController.destinationSuggestions.clear();
                      },
                    );
                  },
                ),
              );
            }),
            // Botão "Avançar"
            Obx(() {
              return ElevatedButton(
                onPressed: _searchController.canProceed.value
                    ? () async {
                        // Desenhar a rota e pegar as informações
                        await _searchController.drawRoute();

                        // Navegar para a RouteView passando as informações da rota usando a rota nomeada
                        Get.toNamed('/route', arguments: {
                          'distance': _searchController.routeInfo['distance'],
                          'duration': _searchController.routeInfo['duration'],
                          'price': _searchController.routeInfo['price'],
                        });
                      }
                    : null, // Desabilitado até que tanto origem quanto destino estejam selecionados
                child: const Text('Avançar'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
