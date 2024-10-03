import 'package:chat_service/services/auth/auth_service.dart';
import 'package:chat_service/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:chat_service/components/my_textfield.dart';


class LoginPage extends StatelessWidget{

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwmailController = TextEditingController();
  final void Function()? onTap;
  final FocusNode? focusNode;
  LoginPage({super.key, required this.onTap,required this.focusNode});

  void login(BuildContext context) async{
    final authService = AuthService();

    try{
      await authService.signInWithEmailPassword(_emailController.text, _pwmailController.text,);
    }
    catch (e){
      showDialog(context: context,
      builder: (context) => AlertDialog(
          title: Text(e.toString()))
      );
    }
  }
@override
  Widget build(BuildContext context){
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

            // welcome back text
            Text("Welcome back, you've been missed!",
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
            const SizedBox(height: 10),
            // password Text field
             MyTextField(
              hintText: "Type your Password",
              obscureText:true,
              controller: _pwmailController,
               focusNode: focusNode,
            ),

            const SizedBox(height: 25),

           // login button
            MyButton(
             text: "login",
             onTap: () => login(context),
           ),

            const SizedBox(height: 25),
         // Register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("Not a User? ",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Register Now",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
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