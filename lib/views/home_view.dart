import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.put(HomeController());

  // Controle do estado do drawer
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: const Color.fromARGB(221, 255, 255, 255),
        child: Drawer(
          backgroundColor: const Color.fromARGB(26, 96, 104, 165),
          child: ListView(
            children: <Widget>[
              Container(
                color: const Color.fromARGB(135, 252, 252, 252),
                height: 160,
                child: UserAccountsDrawerHeader(
                  accountName: Obx(() => Text(_homeController.userName.value)),
                  accountEmail: const Text(''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Obx(() => Text(
                          _homeController.userName.value.isNotEmpty
                              ? _homeController.userName.value[0]
                              : '',
                          style: const TextStyle(fontSize: 40.0),
                        )),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    await _homeController.logout();
                    Get.offAllNamed('/login');
                  } catch (e) {
                    Get.snackbar(
                      'Erro',
                      'Falha ao realizar logout. Tente novamente mais tarde.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        // Recarregar o mapa com a nova posição
        if (_homeController.currentPosition.value.latitude == 0.0 &&
            _homeController.currentPosition.value.longitude == 0.0) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _homeController.currentPosition.value,
                zoom: 15.0,
              ),
              onMapCreated: _homeController.onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            //Botão drawer
            Positioned(
              top: 36,
              left: 19,
              child: GestureDetector(
                onTap: () {
                  sKey.currentState!.openDrawer();
                },
                child: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 100, 109, 146),
                  radius: 20,
                  child: Icon(
                    Icons.menu,
                    color: Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
              ),
            ),

            //Botão location
            Positioned(
              bottom: 250,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'location_button',
                onPressed: _homeController.getCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),

            // Barra inferior personalizada
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saudação e campo de destino
                    Center(
                      child: Obx(() => Text(
                            'Bom dia, ${_homeController.userName.value}.',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Para onde?',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Botão de escolher destino
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(
                            '/searchDestination'); // Navega para a página de pesquisa
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'Escolher destino',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
