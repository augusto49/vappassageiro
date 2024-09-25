import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => controller.email.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (value) => controller.password.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
                onChanged: (value) => controller.password2.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) => controller.firstName.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Sobrenome'),
                onChanged: (value) => controller.lastName.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Cidade'),
                onChanged: (value) => controller.cidade.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (value) => controller.telefone.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'CPF'),
                onChanged: (value) => controller.cpf.value = value,
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Data de Nascimento'),
                onChanged: (value) => controller.dataNascimento.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Gênero'),
                onChanged: (value) => controller.genero.value = value,
              ),
              CheckboxListTile(
                title: const Text('Aceito os termos'),
                value: controller.termoAceite.value,
                onChanged: (value) =>
                    controller.termoAceite.value = value ?? false,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.selectImage('rosto'),
                child: const Text('Selecionar Foto'),
              ),
              Obx(() {
                if (controller.fotoRosto.value != null) {
                  return Image.file(controller.fotoRosto.value!, height: 100);
                } else {
                  return const Text('Nenhuma foto selecionada');
                }
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.register(),
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
