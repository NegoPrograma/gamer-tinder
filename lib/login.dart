// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gamer_tinder/register.dart';
import 'package:gamer_tinder/home.dart';

class Login extends StatefulWidget {
  /**
   * Setting login UI variables
   */

  TextEditingController _emailController =
      TextEditingController(text: "teste@teste.com");
  TextEditingController _passwordController =
      TextEditingController(text: "tester");

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void enterRegisterScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Register(),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.signOut();
  }

  void enterHomeScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  void signIn(email, password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    if (userCredential.user.email != "") enterHomeScreen(this.context);
  }

  void googleSignIn() async {
      UserCredential userCredential = await signInWithGoogle();
      if (userCredential.user.email != "") enterHomeScreen(this.context);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login page"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: widget._emailController),
            TextField(controller: widget._passwordController),
            FlatButton(
                onPressed: () => signIn(widget._emailController.text,
                    widget._passwordController.text),
                child: Text("Logar no sistema.")),
            FlatButton(
              onPressed: () => enterRegisterScreen(this.context),
              child: Text("Registrar-se"),
            ),
            // with custom text
            SignInButton(
              Buttons.Google,
              text: "Sign up with Google",
              onPressed: () => googleSignIn(),
            )
          ],
        ),
      ),
    );
  }
}
