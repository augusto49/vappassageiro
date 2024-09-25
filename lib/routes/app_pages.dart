import 'package:get/get.dart';
import 'package:vappassageiro/views/route_view.dart';

import '../bindeng/route_bindeng.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/otp_verification_view.dart';
import '../views/register_view.dart';
import '../views/reset_password_request_view.dart';
import '../views/search_destination_view.dart';
import '../views/splash_view.dart';

class AppPages {
  static const String initialRoute = '/';

  static final routes = [
    GetPage(name: '/', page: () => const SplashView()),
    GetPage(name: '/login', page: () => LoginView()),
    GetPage(name: '/register', page: () => const RegisterView()),
    GetPage(name: '/verify-otp', page: () => OtpVerificationView()),
    GetPage(name: '/reset-password', page: () => ResetPasswordRequestView()),
    GetPage(name: '/home', page: () => const HomeView()),
    GetPage(
      name: '/searchDestination',
      page: () => SearchDestinationView(),
      binding: RouteBinding(),
    ),
    GetPage(
      name: '/route',
      page: () => RouteView(),
      binding: RouteBinding(),
    ),
  ];
}
