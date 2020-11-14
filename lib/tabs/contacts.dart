import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/Messages.dart';

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

    _setUserValues();
  }

  void _setUserValues() {
    String userId = FirebaseAuth.instance.currentUser.uid;
    Timer(Duration(seconds: 1), () {
      _getConversations(userId);
    });
  }

  Stream<QuerySnapshot> _getConversations(String id) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("conversations")
        .doc(id)
        .collection("last_conversation")
        .snapshots();
    stream.listen((data) {
      _chatController.add(data);
    });
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
    print("ta passando isso ó: ");
    print(contact);
    //método para executar assim que o build estiver pronto.
    Navigator.pushNamed(this.context, "/Messages", arguments: contact);

    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   Navigator.pushNamed(context, "/messages", arguments: {contact});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _chatController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text(
                      "Carregando conversas",
                      style: TextStyle(fontSize: 40),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot qs = snapshot.data;
              if (snapshot.hasError) return Text("Erro ao carregar dados");

              if (qs.docs.length == 0)
                return Text("Você é fracassado e não tem amigos ainda :((");

              return ListView.builder(
                  itemCount: qs.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        enterConversation(
                            qs.docs[index]['contactName'],
                            qs.docs[index]['contactProfilePhoto'],
                            qs.docs[index]['contactId']);
                        // Navigator.pushNamed(context, "/Messages", arguments: {
                        //   "contactName": qs.docs[index]['contactName'],
                        //   "profilePicURL": qs.docs[index]
                        //       ['contactProfilePhoto'],
                        //   "userId": widget.user['userId'],
                        //   "contactId": qs.docs[index]['contactId'],
                        //   "username": widget.user["name"],
                        //   "userPic": widget.user["profilePicURL"]
                        // });
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
                        backgroundImage:
                            NetworkImage(qs.docs[index]['contactProfilePhoto']),
                      ),
                      title: Text(
                        qs.docs[index]['contactName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: qs.docs[index]['type'] == "text"
                          ? Text(qs.docs[index]['message'])
                          : Text("Imagem recebida"),
                    );
                  });
          }
          return Container();
        });
  }
}
