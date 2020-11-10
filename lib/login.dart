// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    enterHomeScreen(context);
    FirebaseAuth.instance.signOut();
  }

  void enterHomeScreen(context) {
    if (FirebaseAuth.instance.currentUser != null)
      Navigator.pushNamed(context, "/Home");
  }

  void signIn(email, password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    enterHomeScreen(this.context);
  }

  void registerGoogleAccountToDatabase(UserCredential credential) async {
    //registra o documento se ele não existir ainda
    FirebaseFirestore db = FirebaseFirestore.instance;

    User user = credential.user;

    Map<String, dynamic> data = {
      "id": user.uid,
      "email": user.email,
      "name": user.displayName,
      "age": 18,
      "profilePicURL":
          "https://freepikpsd.com/wp-content/uploads/2019/10/default-png-2-Transparent-Images.png"
    };
    await db.collection("appUsers").doc(user.uid).set(data);
  }

  void googleSignIn() async {
    UserCredential user = await signInWithGoogle();
    if (user.additionalUserInfo.isNewUser)
      registerGoogleAccountToDatabase(user);
    enterHomeScreen(this.context);
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
