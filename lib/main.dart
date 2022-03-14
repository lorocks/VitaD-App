import 'package:ble/Views.dart';
import 'package:ble/BLEConnection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'x',
      options: const FirebaseOptions(
          apiKey: "AIzaSyDdRB06v46yI5IMhCAJ7GyNFGtc2zEg4CI",
          appId: '1:780277995861:android:eca4baade077139baa37dc',
          messagingSenderId: 'lorocks',
          projectId: 'vitamind-e3b5c'));

  runApp(MaterialApp(
    title: 'Button new page',
    home: ButtonSelect(),
  ));
}

class ButtonSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/startpg.jpg"),
                fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(children: [
              Expanded(
                child: Center(child: Text('')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ButtonTheme(
                      minWidth: 165,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(17),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => MyApp()));
                        },
                        child: Text(
                          "Connect",
                          style: TextStyle(
                            color: Colors.grey.shade100,
                            fontSize: 18,
                          ),
                        ),
                        color: Colors.lightBlue.shade300,
                      )),
                  ButtonTheme(
                      minWidth: 165,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(17),
                        onPressed: () {
                          DateTime now = new DateTime.now();
                          String date = DateFormat('dd-MM-yyyy').format(now);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetUserName(date)));
                        },
                        child: Text(
                          "Status",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade100,
                          ),
                        ),
                        color: Colors.lightBlue.shade900,
                      )),
                ],
              ),
              //remove down later
              // RaisedButton(
              //   onPressed: () {
              //     DateTime now = new DateTime.now();
              //     String date = DateFormat('dd-MM-yyyy').format(now);
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => ThirdScreen1(date)));
              //   },
              //   child: Text(
              //     "Timer",
              //     style: TextStyle(
              //       fontSize: 20,
              //       color: Colors.black,
              //     ),
              //   ),
              //   color: Colors.blue,
              // ),
              Text(''),
              Text(''),
              Text(''),
              Text(''),
            ])));
  }
}
