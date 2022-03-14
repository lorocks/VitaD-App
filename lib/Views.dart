import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:ble/main.dart';

class ThirdScreen1 extends StatelessWidget {
  int start;
  int stop;
  final String documentId;
  ThirdScreen1(this.documentId);

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('ldrdata');

    Future<void> addUser() {
      // Call the user's CollectionReference to add a new user
      DateTime now = new DateTime.now();
      stop = now.microsecondsSinceEpoch;
      int timediff = stop - start;
      double timeout = timediff / 6;
      timeout = timeout / 10000000;

      int hour = now.hour;
      // if (hour >= 10 || hour <= 2) { keep this cause necessary
      users
          .doc(documentId)
          .set({'LDR': 'SomeValue', 'HourOut': hour, 'TimeOut': timeout})
          .then((value) => print("User Added and ${timeout}"))
          .catchError((error) => print("Failed to add user: $error"));
    }
    // }

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/timerpg.jpg"),
                fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Expanded(
                  child: Center(child: Text('')),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ButtonTheme(
                        minWidth: 150,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade100,
                            ),
                          ),
                          color: Colors.blueGrey.shade600,
                          onPressed: () {
                            start = new DateTime.now().microsecondsSinceEpoch;
                          },
                          //     () {
                          //   start = new DateTime.now().microsecondsSinceEpoch;
                          //   //started = 1;
                          // },
                        )),
                    ButtonTheme(
                        minWidth: 150,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'Stop',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade100,
                            ),
                          ),
                          color: Colors.indigo.shade900,
                          onPressed: addUser,
                        )),
                  ],
                ),
                Text(''),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text("          Timer Started",
                        style: TextStyle(color: Colors.blueGrey.shade700)),
                  ),
                ), //this should be text variable
                Text(''),
                Text(''),
                Text(''),
                Text(''),
                ButtonTheme(
                    minWidth: 300,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Check',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade100,
                        ),
                      ),
                      color: Colors.lightBlue.shade300,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GetUserName(documentId)));
                      },
                    )),
                Text(''),
                Text(''),
              ],
            )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to test timer'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            child: Text('Start'),
            color: Colors.blue,
            onPressed: () {
              start = new DateTime.now().microsecondsSinceEpoch;
            },
          ),
          RaisedButton(
            child: Text('Stop'),
            color: Colors.blue,
            onPressed: addUser,
          ),
          RaisedButton(
            child: Text('Return'),
            color: Colors.blue,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      )),
    );
  }
}

class GetUserName extends StatefulWidget {
  final String documentId;

  GetUserName(this.documentId);
  @override
  _GetUserName createState() => _GetUserName(documentId);
}

class _GetUserName extends State<GetUserName> {
  final String documentId;

  _GetUserName(this.documentId);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('mldata');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data.exists) {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/loadingpg.jpg"),
                    fit: BoxFit.cover)),
            child: Center(
              child: Text(
                "No Data For Today",
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data.data() as Map<String, dynamic>;
          double LDR = double.parse((data['LDR']).toStringAsFixed(2));
          double Time = double.parse((data['Time']).toStringAsFixed(2));
          double Duration = double.parse((data['Duration']).toStringAsFixed(2));
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/status.jpeg"),
                      fit: BoxFit.cover)),
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(child: Text('')),
                        ),
                        if (data['Class'] == 0)
                          Image.asset('assets/images/goodicon.png',
                              height: 500, width: 500),
                        if (data['Class'] == 1)
                          Image.asset('assets/images/okayicon.png',
                              height: 500, width: 500),
                        if (data['Class'] == 2)
                          Image.asset('assets/images/badicon.png',
                              height: 500, width: 500),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                '${LDR}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${Time}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${Duration}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                        Text(''),
                        Text(''),
                        Text(''),
                        Text(''),
                      ],
                    ),
                  )));

          // return Text(
          //     "LDR: ${data['LDR']}, HourOut: ${data['HourOut']}, TimeOut: ${'TimeOut'}");
        }

        return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/loadingpg.jpg"),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //...containers,
                Container(
                    padding: EdgeInsets.all(100),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      color: Colors.lightBlue.shade900,
                      strokeWidth: 5,
                    )),
                Center(
                  child: Text(
                    "Fetching Data",
                    style: TextStyle(
                      fontSize: 27,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
