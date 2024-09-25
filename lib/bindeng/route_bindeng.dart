import 'package:get/get.dart';
import 'package:vappassageiro/controllers/route_controller.dart';
import 'package:vappassageiro/controllers/home_controller.dart';

class RouteBinding extends Bindings {
  @override
  void dependencies() {
    // Registra os controladores que serão usados nesta rota
    Get.lazyPut<RouteController>(() => RouteController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
