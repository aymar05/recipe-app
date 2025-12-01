import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/models/requests/login_request.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/models/auth_response.dart';
import 'package:recipe_app/services/api/entities/api_response.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final req = LoginRequest(email: email, password: password);

    final authService = AuthService();
    try {
      final ApiResponse<AuthResponse> resp = await authService.login(req);

      setState(() => _isLoading = false);

      if (resp is Success<AuthResponse>) {
        final auth = resp.data;
        final token = auth.token;
        final user = auth.user; // Récupération de l'objet User

        // 1. Sauvegarde du Token
        if (token != null && token.isNotEmpty) {
          await ApiAuthService.to.setToken(token);
        }

        // 2. Sauvegarde de l'Utilisateur pour le Profil
        if (user != null) {
          await ApiAuthService.to.setUser(user);
        }

        // 3. Navigation
        Get.offAllNamed('/root'); 
        
        Get.snackbar(
          "Succès",
          "Connexion réussie",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final code = (resp as Failure).code;
        Get.snackbar(
          "Erreur de connexion",
          "Échec de la connexion (code: $code). Vérifiez vos identifiants.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Erreur réseau",
        "Impossible de se connecter: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/register_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Calque sombre
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5),
          ),
          // Contenu du formulaire
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
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
                        const SizedBox(height: 90),
                        // Champ Email
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veuillez entrer votre email.";
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
                        // Champ Mot de passe
                        SizedBox(
                          height: 45,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veuillez entrer votre mot de passe.";
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
                        // Bouton de Connexion
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 235, 240, 236)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all(Colors.black),
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
                                    "Se connecter",
                                    style: TextStyle(color: Colors.black),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Lien vers l'inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Vous n'avez pas de compte ?",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/register'); 
                              },
                              child: const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold,
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