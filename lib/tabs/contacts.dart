import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsTab extends StatefulWidget {
  Map<String, dynamic> user;

  ContactsTab();
  @override
  _ContactsTabState createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final _chatController = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    //_setUserValues();
  }

  Future<List<Map<String, dynamic>>> _getMatches() async {
    QuerySnapshot myTriedMatches = await db
        .collection("matches")
        .where("sender", isEqualTo: auth.currentUser.uid)
        .get();

    List<Map<String, dynamic>> result = List<Map<String, dynamic>>();
    for (QueryDocumentSnapshot element in myTriedMatches.docs) {
      String receiverId = element.data()["receiver"];
      print("você deu like no usuario de id $receiverId");
      QuerySnapshot match = await db
          .collection("matches")
          .where("sender", isEqualTo: receiverId)
          .where("receiver", isEqualTo: auth.currentUser.uid)
          .get();
      if (match.docs.length > 0) {
        DocumentSnapshot user =
            await db.collection("appUsers").doc(receiverId).get();
        result.add(user.data());
      }
    }
    return result;
  }

  void enterConversation(name, photo, contactId) async {
    DocumentSnapshot snapshot =
        await db.collection("appUsers").doc(auth.currentUser.uid).get();
    Map<String, dynamic> user = snapshot.data();
    Map<String, dynamic> contact = {
      "contactName": name,
      "profilePicURL": photo,
      'contactId': contactId,
      'userId': user["id"],
      'username': user["name"],
      'userPic': user["profilePicURL"],
    };
    Navigator.pushNamed(this.context, "/Messages", arguments: contact);
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _getMatches(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text(
                      "Carregando...",
                      style: TextStyle(fontSize: 40),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              List<Map<String, dynamic>> contactList = snapshot.data;
              if (snapshot.hasError)
                return Text("Você não tem matches ainda :((");

              if (contactList.length == 0)
                return Text("Você não tem matches ainda :((");
              else
                return ListView.builder(
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> qs = contactList[index];

                      return ListTile(
                        onTap: () {
                          enterConversation(
                              qs['name'], qs['profilePicURL'], qs['id']);
                        },
                        contentPadding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          8,
                        ),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.green,
                          backgroundImage: NetworkImage(qs['profilePicURL']),
                        ),
                        title: Text(
                          qs['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    });
          }
          return Container();
        });
  }
}
