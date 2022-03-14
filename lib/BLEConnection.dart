import 'dart:convert';
import 'package:ble/Views.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock/wakelock.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BLE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'BLE Connection'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  String text = '';
  int start;
  bool enable = false;

  _MyHomePageState();

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  Future<void> _awaitBLE(device) async {
    print(device.name);
    if (device.name == 'HRM') {
      widget.flutterBlue.stopScan();
      try {
        await device.connect();
      } catch (e) {
        if (e.code != 'already_connected') {
          throw e;
        }
      } finally {
        _services = await device.discoverServices();
      }
      setState(() {
        _connectedDevice = device;
      });
    }
  }

  Container _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();

    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } catch (e) {
                    if (e.code != 'already_connected') {
                      throw e;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                  });
                },
              ),
            ],
          ),
        ),
      );
      _awaitBLE(device);
    }

    return
      Container(
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
          "Searching for Devices",
          style: TextStyle(
            fontSize: 27,
            color: Colors.black,
          ),
        ),
      ),
      ],
    )
      );
  }

  Container ThirdScreen() {
    List<Container> containers = new List<Container>();
    int stop;
    int ldr;
    DateTime now = new DateTime.now();
    String documentId = DateFormat('dd-MM-yyyy').format(now);

    Wakelock.toggle(enable: enable);

    CollectionReference users =
        FirebaseFirestore.instance.collection('ldrdata');

    Future<void> addUser() async {
      // Call the user's CollectionReference to add a new user
      print("in stop");
      DateTime now = new DateTime.now();
      stop = now.microsecondsSinceEpoch;
      int timediff = stop - start;
      double timeout = timediff / 6;
      timeout = timeout / 10000000;
      for (BluetoothService service in _services) {
        List<Widget> characteristicsWidget = new List<Widget>();
        if (service.uuid.toString() == "0000180d-0000-1000-8000-00805f9b34fb") {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() ==
                "00002a37-0000-1000-8000-00805f9b34fb") {
              var sub = characteristic.value.listen((value) {
                // setState(() {
                //   widget.readValues[characteristic.uuid] = value;
                // });
                ldr = value[1];
              });
              await characteristic.read();
              sub.cancel();
            }

            int hour = now.hour;
            // int ldr = widget.readValues[characteristic.uuid][1];
            // if (hour >= 10 || hour <= 2) { keep this cause necessary
            users
                .doc(documentId)
                .set({'LDR': ldr, 'HourOut': hour, 'TimeOut': timeout})
                .then((value) => print("User Added and ${timeout} and ${ldr}"))
                .catchError((error) => print("Failed to add user: $error"));
          }
        }
      }
      setState(() {
        text = '';
        enable = false;
      });
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
                            setState(() {
                              start = new DateTime.now().microsecondsSinceEpoch;
                              text = "          Timer Started";
                              enable = true;
                            });
                          },
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
                    child: Text(text,
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
  }

  Object _buildView() {
    if (_connectedDevice != null) {
      return ThirdScreen();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _buildView(),
      );
}

//0000180d-0000-1000-8000-00-805f9b34fb
