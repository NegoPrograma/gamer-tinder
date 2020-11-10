import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatefulWidget {
  String _contactName = "New User";
  String _profilePicURL = "";
  String _userId = "";
  String _contactId = "";
  String _username = "";
  String _myProfilePicURL = "";

  void setValues(contact){
    _contactName = contact["contactName"];
    _profilePicURL = contact["profilePicURL"];
    _userId = contact['userId'];
    _contactId = contact['contactId'];
    _username = contact['username'];
    _myProfilePicURL = contact['userPic'];
  }


  Messages({contact}) {
    _contactName = contact["contact"]["contactName"];
    _profilePicURL = contact["contact"]["profilePicURL"];
    _userId = contact["contact"]['userId'];
    _contactId = contact["contact"]['contactId'];
    _username = contact["contact"]['username'];
    _myProfilePicURL = contact["contact"]['userPic'];
    print(_contactId);
  }
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController _messageController = TextEditingController();
  StreamBuilder messageStream;
  FirebaseFirestore db = FirebaseFirestore.instance;
  ScrollController _chatScrollController = ScrollController();
  final StreamController _messageStreamController =
      StreamController<QuerySnapshot>.broadcast();
  void _sendMessage() {
    String message = _messageController.text;

    if (message.isNotEmpty) {
      Map<String, dynamic> messageJSON = {
        "userId": widget._userId,
        'message': message,
        "imageURL": "",
        "type": "text",
        "date": Timestamp.now().toString()
      };

      _storeMessage(widget._userId, widget._contactId, messageJSON);
      _storeMessage(widget._contactId, widget._userId, messageJSON);
      _saveChat(messageJSON);
    }
  }

  Stream<QuerySnapshot> _messageScrollStream() {
    Stream<QuerySnapshot> stream = db
        .collection("messages")
        .doc(widget._userId)
        .collection(widget._contactId)
        .orderBy("date", descending: false)
        .snapshots();
    stream.listen((data) {
      _messageStreamController.add(data);
      Timer(Duration(seconds: 1), () {
        _chatScrollController
            .jumpTo(_chatScrollController.position.maxScrollExtent);
      });
    });
    return stream;
  }

  void _storeMessage(
      String senderId, String receiverId, Map<String, dynamic> message) async {
    /**
     * Estrutura:
     * 
     * messages->id de quem mandou -> uma mesma pessoa pode ter mandado
     * para varias outras, então não adianta só colocar quem recebeu depois,
     * façamos então uma segunda collection:
     * 
     * messages->id de quem mandou -> collection representando quem recebeu
     * ->conjunto de mensagens.
     */
    await db
        .collection("messages")
        .doc(senderId)
        .collection(receiverId)
        .add(message);

    _messageController.clear();
  }

  Widget messageInputField;
  List<String> messageTest = [
    "EAE",
    "QUAL FOI",
    "BOA NOITE NEY JOGOU O QUE SABE",
    "vlw lek"
  ];

  void _saveChat(Map<String, dynamic> lastMessage) async {
    //sender config
    Map<String, dynamic> senderChat = {
      "userId": widget._userId,
      "contactId": widget._contactId,
      "message": lastMessage['message'],
      "contactName": widget._contactName,
      "contactProfilePhoto": widget._profilePicURL,
      "type": lastMessage['type'],
    };

    //receiver config
    Map<String, dynamic> receiverChat = {
      "userId": widget._contactId,
      "contactId": widget._userId,
      "message": lastMessage['message'],
      "contactName": widget._username,
      "contactProfilePhoto": widget._myProfilePicURL,
      "type": lastMessage['type'],
    };

    /**
     * foi preciso colocar esse "last conversation"
     * pois a função set exige um doc antes, 
     * mas a estrutura também exige no minimo duas collections
     * 
     */

    //saving for sender
    await db
        .collection("conversations")
        .doc(widget._userId)
        .collection("last_conversation")
        .doc(widget._contactId)
        .set(senderChat);

    //saving for contact
    await db
        .collection("conversations")
        .doc(widget._contactId)
        .collection("last_conversation")
        .doc(widget._userId)
        .set(receiverChat);
  }

  void initState() {
    super.initState();

    _messageScrollStream();

    messageInputField = Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _messageController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Color(0xff075E54),
              child: Icon(Icons.send, color: Colors.white),
              mini: true,
              onPressed: () {
                _sendMessage();
              },
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 10, 8),
            child: CircleAvatar(
              maxRadius: 20,
              backgroundImage: NetworkImage(widget._profilePicURL),
            ),
          ),
          Text(widget._contactName),
        ]),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                messageStream = StreamBuilder(
                    stream: _messageStreamController.stream,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          Center(
                            child: Column(
                              children: [
                                Text("Carregando mensagens"),
                                CircularProgressIndicator()
                              ],
                            ),
                          );
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:
                          QuerySnapshot qs = snapshot.data;
                          if (snapshot.hasError) {
                            return Expanded(
                              child: Text("Erro ao carregar dados"),
                            );
                          } else {
                            return Expanded(
                              child: ListView.builder(
                                  controller: _chatScrollController,
                                  itemCount: qs.docs.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> message =
                                        qs.docs[index].data();
                                    Alignment align = Alignment.centerLeft;
                                    Color messageColor = Colors.white;
                                    if (message['userId'] == widget._userId) {
                                      align = Alignment.centerRight;
                                      messageColor = Colors.greenAccent;
                                    }

                                    //deixando as imagens com 80% do espaço da tela
                                    double containerWidth =
                                        MediaQuery.of(context).size.width * 0.8;

                                    return Align(
                                      alignment: align,
                                      child: Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Container(
                                          width: containerWidth,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: messageColor,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                          ),
                                          child: message['type'] == 'text'
                                              ? Text(
                                                  message['message'],
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )
                                              : Image.network(
                                                  message['imageURL']),
                                        ),
                                      ),
                                    );
                                  }),
                            );
                          }
                          break;
                      }
                      return Container();
                    }),
                messageInputField,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
