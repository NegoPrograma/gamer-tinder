// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location_permissions/location_permissions.dart';

class Login extends StatefulWidget {
  /**
   * Setting login UI variables
   */

  TextEditingController _emailController =
      TextEditingController(text: "");
  TextEditingController _passwordController =
      TextEditingController(text: "");

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Widget loginPage;
  Widget demandPermissionWidget;

  void enterRegisterScreen(context) {
    Navigator.pushNamed(context, '/Register');
  }

  void requirePermission() async {
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();
    if (permission != PermissionStatus.granted) {
      await LocationPermissions().requestPermissions();
      permission = await LocationPermissions().checkPermissionStatus();
      setState(() {
        if (permission == PermissionStatus.granted)
          demandPermissionWidget = loginPage;
      });
    } else if (permission == PermissionStatus.granted) {
      setState(() {
        demandPermissionWidget = loginPage;
      });
    }
    print(permission);
  }

  @override
  void initState() {
    super.initState();
    loginPage = Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(controller: widget._emailController, decoration: InputDecoration(
              labelText: 'Email'
          )),
          TextField(controller: widget._passwordController, decoration: InputDecoration(
              labelText: 'Senha'
          ),
          obscureText: true,),
          ElevatedButton(
              onPressed: () => signIn(widget._emailController.value.text,
                  widget._passwordController.value.text),
              child: Text("Logar no sistema")
              ),
          FlatButton(
            onPressed: () => enterRegisterScreen(this.context),
            child: Text("Registrar-se"),
          ),
          SignInButton(
            Buttons.Google,
            text: "Entrar com Google",
            onPressed: () => googleSignIn(),
          )
        ],
      ),
    );

    demandPermissionWidget = Container(
      child: Column(
        children: [
          Text(
              "Precisamos acessar sua localização para continuar.",
              style: TextStyle(fontSize: 20)
              ),
          ElevatedButton(
            onPressed: () => requirePermission(),
              child: Text("Permitir acesso"),
          ),
        ],
      ),
    );
  }

  void enterHomeScreen(context) {
    if (FirebaseAuth.instance.currentUser != null)
      Navigator.popAndPushNamed(context, "/Home");
  }

  void signIn(email, password) async {
    print(email + password);
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    enterHomeScreen(this.context);
  }

  void registerGoogleAccountToDatabase(UserCredential credential) async {
    //registra o documento se ele não existir ainda
    FirebaseFirestore db = FirebaseFirestore.instance;
    User user = credential.user;
    Position userPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest);
    Map<String, dynamic> data = {
      "id": user.uid,
      "email": user.email,
      "name": user.displayName,
      "age": 18,
      "profilePicURL":
          "https://freepikpsd.com/wp-content/uploads/2019/10/default-png-2-Transparent-Images.png",
      "coordinates": {
        "latitude": userPos.latitude,
        "longitude": userPos.longitude
      }
    };
    await db.collection("appUsers").doc(user.uid).set(data);
  }

  void googleSignIn() async {
    UserCredential user = await signInWithGoogle();
    if (user.additionalUserInfo.isNewUser)
      await registerGoogleAccountToDatabase(user);
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
        title: Text("Login"),
        backgroundColor: Colors.blueAccent,
      ),
      body: demandPermissionWidget,
    );
  }
}
