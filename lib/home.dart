// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/register.dart';
import 'tabs/contacts.dart';
import 'tabs/matches.dart';
import 'tabs/profile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin {

  TabController _tabController;


  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: 3,
        vsync: this,
      initialIndex: 0
    );

  }

  @override
  void dispose() {

    super.dispose();
    _tabController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text("Abas"),
        bottom: TabBar(
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.black,
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: "Procurar",
              icon: Icon(Icons.favorite,color: Colors.blueAccent,),
            ),
            Tab(
              text: "Contatos",
              icon: Icon(Icons.chat,color: Colors.blueAccent,),
            ),
            Tab(
              text: "Perfil",
              icon: Icon(Icons.settings,color: Colors.blueAccent,),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          MatchTab(),
          ContactsTab(),//Contacts(),
          ProfileTab(),//Profile()
        ],
      ),
    );
  }
}
