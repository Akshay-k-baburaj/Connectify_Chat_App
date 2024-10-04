import 'package:chat_service/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwmailController = TextEditingController();
  final TextEditingController _cwmailController = TextEditingController();
  final void Function()? onTap;
  final FocusNode? focusNode;
  RegisterPage({super.key, required this.onTap, required this.focusNode});

  void register(BuildContext context) {
    final AuthService _auth = AuthService();
    // pass match create user
    if (_pwmailController.text == _cwmailController.text) {
      try {
        _auth.signUpWithEmailPassword(
          _emailController.text,
          _pwmailController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
    // pass not match
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("passwords don't match"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 50),

            // new account
            Text(
              "Let's create a new Account for you",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // email Text field
            MyTextField(
              hintText: "Type your Email ID",
              obscureText: false,
              controller: _emailController,
              focusNode: focusNode,
            ),
            const SizedBox(height: 30),
            // password Text field
            MyTextField(
              hintText: "Type your Password",
              obscureText: true,
              controller: _pwmailController,
              focusNode: focusNode,
            ),
            const SizedBox(height: 10),
            // Confirm password
            MyTextField(
              hintText: "Confirm your Password",
              obscureText: true,
              controller: _cwmailController,
              focusNode: focusNode,
            ),

            const SizedBox(height: 25),

            // login button
            MyButton(
              text: "Register",
              onTap: () => register(context),
            ),

            const SizedBox(height: 25),
            // Register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login Now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
