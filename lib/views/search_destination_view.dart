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
                _searchController.showingOriginSuggestions.value = true;
              },
            ),
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
                _searchController.showingOriginSuggestions.value = false;
              },
            ),
            const SizedBox(height: 16),

            // Exibe "Carregando..." durante a busca de sugestões
            Obx(() {
              if (_searchController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final suggestions =
                  _searchController.showingOriginSuggestions.value
                      ? _searchController.originSuggestions
                      : _searchController.destinationSuggestions;

              if (suggestions.isEmpty) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(suggestion['description']),
                      onTap: () {
                        // Atualiza o campo correto com a seleção
                        if (_searchController.showingOriginSuggestions.value) {
                          _searchController.originController.text =
                              suggestion['description'];
                          _searchController.originSuggestions.clear();
                        } else {
                          _searchController.destinationController.text =
                              suggestion['description'];
                          _searchController.destinationSuggestions.clear();
                        }
                      },
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            // Espaçador para empurrar o botão para baixo
            const Spacer(),

            // Botão "Avançar" só aparece quando ambos os campos são definidos
            Obx(() {
              // Verifica se a rota está sendo carregada
              if (_searchController.isRouteLoading.value) {
                return const Column(
                  children: [
                    CircularProgressIndicator(), // Indicador de carregamento
                    SizedBox(height: 8),
                    Text('Carregando a rota...'), // Mensagem de carregamento
                  ],
                );
              }

              // Exibe o botão "Avançar" apenas quando a origem e o destino estiverem definidos
              return _searchController.canProceed.value
                  ? ElevatedButton(
                      onPressed: () async {
                        // Inicia o carregamento da rota
                        await _searchController.drawRoute();

                        // Navega para a tela da rota passando as informações
                        Get.toNamed('/route', arguments: {
                          'distance': _searchController.routeInfo['distance'],
                          'duration': _searchController.routeInfo['duration'],
                          'price': _searchController.routeInfo['price'],
                        });
                      },
                      child: const Text('Avançar'),
                    )
                  : const SizedBox.shrink();
            })
          ],
        ),
      ),
    );
  }
}
