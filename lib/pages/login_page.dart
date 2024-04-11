import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_wall/components/button.dart';
import 'package:the_wall/components/square_tile.dart';
import 'package:the_wall/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  // all users
  final usersCollection = FirebaseFirestore.instance.collection('Users');

  //sign user in
  void signIn() async {
    // loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // try to sign in
    try {
      // try to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // try to get token
      final String? token = await FirebaseMessaging.instance.getToken();

      // try to update the FcmToken
      await usersCollection
          .doc(emailTextController.text)
          .update({'FcmToken': token});

      // pop loading circle
      // if (context.mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      // pop loading circle
      Navigator.pop(context);

      // display a dialog message
      displayMessage(
          "Wrong email or password, please try again... Eror: ${e.message}");
    }
  }

  signInWithGoogle() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      if (context.mounted) Navigator.pop(context);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      Navigator.pop(context);
      displayMessage('Please try again Error: $e');
    }
  }

  //display a dialog mesaage
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              //welcome back message
              Text(
                'Welcome Back You are Missed!',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              // email textfield
              MyTextField(
                controller: emailTextController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              MyTextField(
                controller: passwordTextController,
                hintText: 'password',
                obscureText: true,
              ),

              const SizedBox(height: 20),

              //sign in button
              MyButton(onTap: signIn, text: 'Sign In'),

              const SizedBox(height: 20),

              // go to register page
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  // SquareTile(
                  //   imagePath: 'lib/images/google_logo.png',
                  //   onTap: signInWithGoogle,
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
