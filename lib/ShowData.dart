import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:libraryb/ShowBooks.dart';

import 'main.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class CONSTANTS {
  static const String INTERNET_ERROR = "No Internet Connection";
  static const HOME_SERVICE_URL = 'http://codemansion.co.in/test.json';
}

class HomeState extends State<Home> {
  CollectionReference reference = FirebaseFirestore.instance.collection("Data");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text("Test Screen"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => new SplashScreen()),
                      (route) => false);
                },
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Data').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  return new GridView(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    children: snapshot.data!.docs.map((document) {
                      return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: new GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowBooks(
                                          tit: document['Title'],
                                          ID: document.id)));
                            },
                            child: Center(
                              child: Container(
                                child: new Column(
                                  children: <Widget>[
                                    Image.network(
                                      document['Icon'],
                                      loadingBuilder:
                                          (context, child, loadingProgress) =>
                                              (loadingProgress == null)
                                                  ? child
                                                  : CircularProgressIndicator(),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Text("Error on Download Image."),
                                    ),
                                    Text(
                                      document['Title'],
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
                    }).toList(),
                  );
              }
            },
          )),
    );
  }
}
