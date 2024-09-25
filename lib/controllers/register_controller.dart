import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class RegisterController extends GetxController {
  final ApiService _apiService = ApiService();
  final email = ''.obs;
  final password = ''.obs;
  final password2 = ''.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;
  final cidade = ''.obs;
  final telefone = ''.obs;
  final cpf = ''.obs;
  final dataNascimento = ''.obs;
  final genero = ''.obs;
  final termoAceite = false.obs;

  final fotoRosto = Rxn<File>();

  // Função para selecionar imagem
  Future<void> selectImage(String imageType) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      fotoRosto.value = File(image.path);
    }
  }

  // Função para realizar o registro
  Future<void> register() async {
    try {
      final registrationData = {
        'email': email.value,
        'password': password.value,
        'password2': password2.value,
        'first_name': firstName.value,
        'last_name': lastName.value,
        'cidade': cidade.value,
        'telefone': telefone.value,
        'cpf': cpf.value,
        'data_nascimento': dataNascimento.value,
        'genero': genero.value,
        'termo_aceite': termoAceite.value,
      };

      // Chamando o método register com dados de registro e foto
      final response = await _apiService.register(
        registrationData,
        {
          'foto_rosto': fotoRosto.value,
        },
      );

      // Verificar o código de status em vez de 'success'
      if (response.containsKey('data')) {
        // Registro bem-sucedido, redirecionar para a tela de verificação de OTP
        Get.snackbar(
          'Sucesso',
          'Registro realizado com sucesso. Verifique seu email para OTP.',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Redireciona para a tela de verificação de OTP (ajuste a rota conforme seu app)
        Get.offAllNamed('/verify-otp', arguments: {'email': email.value});
      } else {
        Get.snackbar(
          'Erro',
          'Erro ao realizar o registro.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Verificar OTP
  Future<void> verifyOtp(String otp) async {
    try {
      await _apiService.verifyEmail(otp);

      Get.snackbar(
        'Sucesso',
        'Email verificado com sucesso. Faça login.',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Redirecionar para a página de login
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao verificar o email: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
