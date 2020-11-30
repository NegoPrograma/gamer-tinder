import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

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
  double distance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future userFetch;
  List<Map<String, dynamic>> users;
  bool fetchingUsers, currentUserFetched, noMatchAvaiable;

  Map<String, dynamic> user, currentUser;

  Future<List<Map<String, dynamic>>> _getUsers() async {
    QuerySnapshot snapshot = await db.collection("appUsers").get();
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>();
    if (snapshot.docs.length > 0) {
      for (QueryDocumentSnapshot snapshot in snapshot.docs) {
        bool alreadyLiked = await checkIfUserLiked(snapshot.data());
        //não deverá retornar usuários que você já deu like e obviamente não pode retornar o próprio usuário.
        if (!alreadyLiked && snapshot.data()["id"] != auth.currentUser.uid)
          users.add(snapshot.data());
      }
      /**
     * ordenando do mais perto até o mais longe.
     */
      Position userPos = await Geolocator.getCurrentPosition();
      await db.collection("appUsers").doc(auth.currentUser.uid).update(
        {
          "coordinates": {
            "latitude": userPos.latitude,
            "longitude": userPos.longitude
          },
        },
      );
      users.sort((userA, userB) => compareDistances(userA, userB));

      return users;
    } else
      return null;
  }

/**
 * 
 * método que calcula distância com lógica de comparator para uso no sort
 */
  int compareDistances(Map<String, dynamic> userA, Map<String, dynamic> userB) {
    double distanceA = Geolocator.distanceBetween(
        userA["coordinates"]["latitude"],
        userA["coordinates"]["longitude"],
        currentUser["coordinates"]["latitude"],
        currentUser["coordinates"]["longitude"]);
    double distanceB = Geolocator.distanceBetween(
        userB["coordinates"]["latitude"],
        userB["coordinates"]["longitude"],
        currentUser["coordinates"]["latitude"],
        currentUser["coordinates"]["longitude"]);
    if (distanceA <= distanceB) return -1;
    return 1;
  }

  /**
   * método que calcula distância individual para mostrar na tela.
   */
  double getUniqueDistance(
      Map<String, dynamic> userA, Map<String, dynamic> userB) {
    double distance = Geolocator.distanceBetween(
        userA["coordinates"]["latitude"],
        userA["coordinates"]["longitude"],
        userB["coordinates"]["latitude"],
        userB["coordinates"]["longitude"]);
    return distance / 1000;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noMatchAvaiable = false;
    fetchingUsers = true;
    currentUserFetched = false;
    userFetch = initiateUserData().then((value) {
      currentUser = value;
      currentUserFetched = true;
    });
    _getUsers().then((value) {
      users = value;
      index = 0;
      setState(() {
        if (value != null && value.length > 0) {
          contactId = value[0]["id"];
          photo = value[0]["profilePicURL"];
          name = value[0]["name"];
          age = value[0]["age"].toString();
          distance = getUniqueDistance(currentUser, value[0]);
        } else {
          noMatchAvaiable = true;
        }
        fetchingUsers = false;
      });
    });
  }

  Future initiateUserData() async {
    DocumentSnapshot currentUserSnapshot =
        await db.collection("appUsers").doc(auth.currentUser.uid).get();
    currentUser = currentUserSnapshot.data();
    return currentUser;
  }

  void callNextUser(user) {
      setState(() {
        contactId = user["id"];
        photo = user["profilePicURL"];
        name = user["name"];
        age = user["age"].toString();
        distance = getUniqueDistance(currentUser, user);
        index++;
      });
  }

  void matchUser(user) async {
    Map<String, dynamic> matchTry = {
      "sender": auth.currentUser.uid,
      "receiver": user['id']
    };
    //garantindo que você só pode dar match uma vez
    QuerySnapshot snapshot = await db
        .collection("matches")
        .where("sender", isEqualTo: auth.currentUser.uid)
        .where("receiver", isEqualTo: user['id']).get();

    if(snapshot.docs.length < 1)
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

  String showTags(Map<String, dynamic> user) {
    StringBuffer tags = StringBuffer();
    tags.write("Interesses: ");
    if (user['tags'] != null)
      user['tags'].forEach((tag) {
        tags.write(tag);
        tags.write(",");
      });
    String t = tags.toString();
    if (t != null && t.length > 0) {
      t = t.substring(0, t.length - 1);
    }
    return t;
  }

  Widget build(BuildContext context) {
    if (fetchingUsers || !currentUserFetched)
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
    else if (index <= users.length && !noMatchAvaiable)
      return Container(
        child: Stack(
          children: [
            Column(
              children: [
              Container(
                child:
                Image.network(photo, height: MediaQuery.of(context).size.height * .5),
              ),
                Text(
                  name +
                      ", " +
                      age.toString() +
                      " - " +
                      distance.toStringAsFixed(1) +
                      " Km",
                  style: TextStyle(fontSize: 20)
                ),

                Text(showTags(users[index]),
                  style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      color: Colors.redAccent,
                      child: Text("Ignorar"),
                      onPressed: () {
                        if (index+1 <= users.length-1)
                          callNextUser(users[index+1]);
                        else
                          setState(() => noMatchAvaiable = true);
                      },
                    ),
                    FlatButton(
                      color: Colors.greenAccent,
                      child: Text("Curtir"),
                      onPressed: () {
                        if (index+1 <= users.length-1)
                          matchUser(users[index+1]);
                        else
                          setState(() => noMatchAvaiable = true);
                      },
                    ),
                  ],
                ),

              ],
            )
          ],
        ),
      );
    else if (noMatchAvaiable)
      return Text("Não temos mais matches disponíveis!");
  }
}
