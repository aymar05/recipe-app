import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/models/requests/register_request.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/models/auth_response.dart';
import 'package:recipe_app/services/api/entities/api_response.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // Ajout d'un contrôleur pour la confirmation du mot de passe (requis par Laravel)
  final TextEditingController _passwordConfirmationController = TextEditingController(); 

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  // --- Nouvelle méthode de gestion de l'inscription API ---
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirmation = _passwordConfirmationController.text.trim();

    if (password != passwordConfirmation) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas", backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => _isLoading = false);
      return;
    }

    final req = RegisterRequest(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      );

    final authService = AuthService();
    try {
      final ApiResponse<AuthResponse> resp = await authService.register(req);

      setState(() => _isLoading = false);

      if (resp is Success<AuthResponse>) {
          final auth = resp.data;
          final token = auth.token;

          if (token != null && token.isNotEmpty) {
            await ApiAuthService.to.setToken(token); 
          }
          Get.offAllNamed('/root');
          Get.snackbar("Succès", "Inscription réussie", backgroundColor: Colors.green, colorText: Colors.white);
      }  else {
        final code = (resp as Failure).code;
        Get.snackbar("Erreur", "Inscription échouée (code: $code)", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar("Erreur réseau", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  // -----------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/register_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Bienvenu sur",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Recipe Book",
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 55,
                          height: 55,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(55),
                          ),
                          child: Image.asset(
                            "assets/images/splash.png",
                            width: 52,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veuillez entrer un nom";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: "Nom & Prénoms",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            validator: (value) {
                              if (value!.isEmpty ||
                                  !value.contains("@") ||
                                  !value.contains(".")) {
                                return "Veuillez entrer un email valide"; // Texte ajusté
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 6) { // Ajout d'une règle de longueur
                                return "Le mot de passe doit contenir au moins 6 caractères";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: "Mot de passe",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Nouveau champ : Confirmation du mot de passe
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _passwordConfirmationController,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veuillez confirmer votre mot de passe";
                              }
                              if (value != _passwordController.text) {
                                return "Les mots de passe ne correspondent pas";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: "Confirmer Mot de passe",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            // Utilisation de la nouvelle méthode
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 235, 240, 236),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Inscription",
                                    style: TextStyle(color: Colors.black),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Vous avez déjà un compte ?",
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: (){
                                  Get.toNamed('/login');
                                },
                                child: const Text(
                                  "Se connecter",
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, // Rendu plus visible
                                  decoration: TextDecoration.underline,
                                ),
                                ),
                              ),
                            ],
                          )
                      ],
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
