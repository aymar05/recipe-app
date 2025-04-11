import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                                return "Veuillez entrer un email";
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
                              if (value!.isEmpty) {
                                return "Veuillez entrer un mot de passe";
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
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  UserCredential user = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                          email: _emailController.value.text,
                                          password:
                                              _passwordController.value.text);
                                  if (user.user != null) {
                                    await user.user!
                                        .updateDisplayName(_nameController.value.text);
                                    _formKey.currentState!.reset();
                                    Get.offAllNamed("/root");
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    Get.snackbar(
                                      "Erreur",
                                      'The password provided is too weak.',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(10),
                                    );
                                  } else if (e.code == 'email-already-in-use') {
                                    Get.snackbar(
                                      "Erreur",
                                      'The account already exists for that email.',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(10),
                                    );
                                  }
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF34A853),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const Text("Inscription"),
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
                                style: TextStyle(color: Colors.white),
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
