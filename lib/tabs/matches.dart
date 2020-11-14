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
  int index = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  // List<Map<String, dynamic>> users = [
  //   {
  //     "name": "example1",
  //     "photo": "assets/example1.jpeg",
  //     "age": 23,
  //   },
  //   {
  //     "name": "example2",
  //     "photo": "assets/example2.jpeg",
  //     "age": 23,
  //   },
  //   {
  //     "name": "example3",
  //     "photo": "assets/example3.jpeg",
  //     "age": 23,
  //   },
  //   {
  //     "name": "example4",
  //     "photo": "assets/example4.jpeg",
  //     "age": 23,
  //   },
  //   {
  //     "name": "example5",
  //     "photo": "assets/example5.jpeg",
  //     "age": 23,
  //   },
  // ];

  Future<QuerySnapshot> _getUsers() async {
    return db.collection("appUsers").get();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // void enterConversation() async {
  //   DocumentSnapshot snapshot =
  //       await db.collection("appUsers").doc(auth.currentUser.uid).get();
  //   Map<String, dynamic> user = snapshot.data();

  //   Map<String, dynamic> contact = {
  //     "contactName": name,
  //     "profilePicURL": photo,
  //     'contactId': contactId,
  //     'userId': user["id"],
  //     'username': user["name"],
  //     'userPic': user["profilePicURL"],
  //   };
  //   print("ta passando isso ó: ");
  //   print(contact);
  //   //método para executar assim que o build estiver pronto.
  //   Navigator.pushNamed(this.context, "/Messages", arguments: contact);

  //   // SchedulerBinding.instance.addPostFrameCallback((_) {
  //   //   Navigator.pushNamed(context, "/messages", arguments: {contact});
  //   // });
  // }

  void callNextUser(user) {
    contactId = user["id"];
    photo = user["profilePicURL"];
    name = user["name"];
    age = user["age"].toString();
    index++;
  }

  void matchUser(user) async {
    Map<String, dynamic> matchTry = {
      "sender": auth.currentUser.uid,
      "receiver": user['id']
    };
    await db.collection("matches").add(matchTry);
    callNextUser(user);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUsers(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<QueryDocumentSnapshot> snapshotList = snapshot.data.docs;
          List<Map<String, dynamic>> users = new List<Map<String, dynamic>>();
          snapshotList.forEach((element) {
            users.add(element.data());
          });
          print(users);
          contactId = users[index]["id"];
          photo = users[index]["profilePicURL"];
          name = users[index]["name"];
          age = users[index]["age"].toString();

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
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

              break;
            case ConnectionState.active:
            case ConnectionState.done:
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
          return Container();
        });
  }
}
