import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:gamer_tinder/register.dart';

class MatchTab extends StatefulWidget {
  @override
  _MatchTabState createState() => _MatchTabState();
}

class _MatchTabState extends State<MatchTab> {
  String name;
  String age;
  String photo;
  String contactId;
  int index;
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future fetch;
  List<Map<String, dynamic>> users;
  bool loading;

  Future<List<Map<String, dynamic>>> _getUsers() async {
    QuerySnapshot snapshot = await db.collection("appUsers").get();
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>();
    for (QueryDocumentSnapshot snapshot in snapshot.docs) {
      bool alreadyLiked = await checkIfUserLiked(snapshot.data());
      //não deverá retornar usuários que você já deu like e obviamente não pode retornar o próprio usuário.
      if (!alreadyLiked && snapshot.data()["id"] != auth.currentUser.uid)
        users.add(snapshot.data());
    }
    return users;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = true;
    fetch = _getUsers().then((value) {
      users = value;
      index = 0;
      setState(() {
        loading = false;
        contactId = value[0]["id"];
        photo = value[0]["profilePicURL"];
        name = value[0]["name"];
        age = value[0]["age"].toString();
      });
    });
  }

  void callNextUser(user) {
    if (users.length - 1 >= index)
      setState(() {
        contactId = user["id"];
        photo = user["profilePicURL"];
        name = user["name"];
        age = user["age"].toString();
        index++;
      });
  }

  void matchUser(user) async {
    Map<String, dynamic> matchTry = {
      "sender": auth.currentUser.uid,
      "receiver": user['id']
    };
    await db.collection("matches").add(matchTry);
    callNextUser(user);
  }

  Future<bool> checkIfUserLiked(Map<String, dynamic> user) async {
    QuerySnapshot likedUser = await db
        .collection("matches")
        .where("sender", isEqualTo: auth.currentUser.uid)
        .where("receiver", isEqualTo: user["id"])
        .get();
    return likedUser.docs.length > 0;
  }

  Widget build(BuildContext context) {
    if (loading)
      return Center(
        child: Column(
          children: [
            Text(
              "Carregando matchs",
              style: TextStyle(fontSize: 40),
            ),
            CircularProgressIndicator()
          ],
        ),
      );
    else
      return Container(
        child: Stack(
          children: [
            Image.network(photo),
            Column(
              children: [
                Text(
                  name + " " + age.toString(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      color: Colors.redAccent,
                      child: Text("Nope."),
                      onPressed: () {
                        callNextUser(users[index]);
                      },
                    ),
                    FlatButton(
                      color: Colors.greenAccent,
                      child: Text("Yes!"),
                      onPressed: () {
                        matchUser(users[index]);
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );
  }
}
