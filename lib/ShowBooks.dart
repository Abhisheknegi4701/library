import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:progress_dialog/progress_dialog.dart';

import 'LoginSignup.dart';
import 'ShowData.dart';

class ShowBooks extends StatefulWidget {
  String tit;
  String ID;
  ShowBooks({required this.tit, required this.ID});

  @override
  State<StatefulWidget> createState() {
    return ShowBooksState();
  }
}

class ShowBooksState extends State<ShowBooks> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Data')
                .doc(widget.ID)
                .collection("Books")
                .where("Type", isEqualTo: widget.tit)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  return new ListView(
                    physics: NeverScrollableScrollPhysics(),
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
                                    builder: (context) => BookDetail(
                                        ID: document.id, OldID: widget.ID)));
                          },
                          child: Container(
                            child: new Column(
                              children: <Widget>[
                                Image.network(
                                  document['Image'],
                                  loadingBuilder:
                                      (context, child, loadingProgress) =>
                                          (loadingProgress == null)
                                              ? child
                                              : CircularProgressIndicator(),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text("Error on Download Image."),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Name: ",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      document['Name'],
                                      style: TextStyle(
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Rs. ",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      document['Price'],
                                      style: TextStyle(
                                        fontSize: 20.0,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
              }
            },
          ),
          floatingActionButton: _getFAB()),
    );
  }

  Widget _getFAB() {
    if (firebaseAuth.currentUser == null) {
      return Container();
    } else {
      return FloatingActionButton(
          backgroundColor: Colors.deepOrange[800],
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EnterForm(ID: widget.ID)));
          });
    }
  }
}

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class BookDetail extends StatefulWidget {
  String ID;
  String OldID;
  BookDetail({required this.ID, required this.OldID});

  @override
  State<StatefulWidget> createState() {
    return BookDetailState();
  }
}

class BookDetailState extends State<BookDetail> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Data')
              .doc(widget.OldID)
              .collection("Books")
              .where(FieldPath.documentId, isEqualTo: widget.ID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((document) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: new GestureDetector(
                        onTap: () {
                          /* Navigator.push(
                                context, MaterialPageRoute(builder: (context) => EmailSignup()));*/
                        },
                        child: Container(
                          child: new Column(
                            children: <Widget>[
                              Image.network(
                                document['Image'],
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    (loadingProgress == null)
                                        ? child
                                        : CircularProgressIndicator(),
                                errorBuilder: (context, error, stackTrace) =>
                                    Text("Error on Download Image."),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Name: ",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    document['Name'],
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Rs. ",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    document['Price'],
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Description: ",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                  Expanded(
                                      child: Text(
                                    document['Description'],
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
            }
          },
        ),
      ),
    );
  }
}

class EnterForm extends StatefulWidget {
  String ID;
  EnterForm({required this.ID});

  @override
  State<StatefulWidget> createState() {
    return EnterFormState();
  }
}

class EnterFormState extends State<EnterForm> {
  late ProgressDialog pr;
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController Booknamecontroller = TextEditingController();
  TextEditingController typecontroller = TextEditingController();
  TextEditingController Descriptioncontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(
        message: 'Please Wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    final height = MediaQuery.of(context).size.height;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: Container(
                    child: Transform.rotate(
                  angle: -pi / 3.5,
                  child: ClipPath(
                    clipper: ClipPainter(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .5,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF46D3F6), Color(0xFF182DBA)])),
                    ),
                  ),
                )),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      _title(),
                      SizedBox(height: 50),
                      _emailPasswordWidget(),
                      SizedBox(height: 20),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        )));
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entrynameField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: Booknamecontroller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _entrypriceField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: pricecontroller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _entrytypeField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: typecontroller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _entrydescriptionField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: true,
              controller: Descriptioncontroller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if (Booknamecontroller.text.isEmpty) {
          showToast("Enter Book Name!");
        } else if (pricecontroller.text.isEmpty) {
          showToast("Enter Price of Book!");
        } else if (typecontroller.text.isEmpty) {
          showToast("Enter Type of Book!");
        } else if (Descriptioncontroller.text.isEmpty) {
          showToast("Enter Description!");
        } else {
          pr.show();
          if (firebaseAuth.currentUser == null) {
            showToast("First Login.");
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => new Login()));
          } else {
            FirebaseFirestore.instance
                .collection('Data')
                .doc(widget.ID)
                .collection("Books")
                .doc()
                .set({
              'Name': Booknamecontroller.text,
              'Price': pricecontroller.text, // John Doe
              'Type': typecontroller.text, // Stokes and Sons
              'Description': Descriptioncontroller.text // 42
            }).then((value) {
              showToast("Book Added");
              pr.hide();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => new Home()));
            })
                // ignore: invalid_return_type_for_catch_error
                .catchError((error) {
              pr.hide();
              // ignore: invalid_return_type_for_catch_error
              showToast("Failed to add user: $error");
            });
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF46D3F6), Color(0xFF182DBA)])),
        child: Text(
          'Submit',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  void showToast(String Message) {
    Fluttertoast.showToast(
        msg: Message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Li',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xFF182DBA),
          ),
          children: [
            TextSpan(
              text: 'br',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'ary',
              style: TextStyle(color: Color(0xFF182DBA), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entrynameField("Book Name"),
        _entrypriceField("Price"),
        _entrytypeField("Book Type"),
        _entrydescriptionField("Description"),
      ],
    );
  }
}
