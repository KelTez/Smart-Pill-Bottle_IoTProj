/*
* JUST A SIMPLE HELLO_WORLD APP, FOR EASE OF FLUTTER FUNCTIONALITY. TO BUILD OFF OF THIS BASE
*/

import 'dart:isolate';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'Widgets.dart';

void main() async {
  int alarmID = 0;
  bool init;
  WidgetsFlutterBinding.ensureInitialized();
  //await AndroidAlarmManager.initialize();
  runApp(MaterialApp(
    title: 'BLEScanPage',
    home: BLEScanPage(title: 'Bluetooth Scan'),
  ));
  //await AndroidAlarmManager.periodic(const Duration(seconds: 10), alarmID, testAlarm);
}

//TODO: Add push notification and sound alert when this occurs
void testAlarm() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$testAlarm'");
}

class BLEScanPage extends StatefulWidget {
  BLEScanPage({Key key, this.title}) : super(key: key);
  int carryOn = 1; //used to see whether the user can carryOn from bluetooth page
  final String title;
  final String TARGET_DEVICE_NAME = 'our device name'; //used for check?
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>(); //WONDERING IF WE NEED TO DISPLAY A LIST, IF PHONE CONNECTED TO DEVICE

  @override
  _BLEPageState createState() => _BLEPageState();

}

class _BLEPageState extends State<BLEScanPage>{
  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }
  //will need a check or something, and a button that says (proceed). The button only proceeds user if the actual pill is selected
  @override

  void initState() {

    super.initState();
    widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) { //add connected bluetooth devices to list. later, might to something that checks the name
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) { //add non-connected devices to list
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      if(device.name == widget.TARGET_DEVICE_NAME){
        widget.carryOn = 1; //MOVE THIS SOMEWHERE ELSE, NEED A CHECK FOR WHEN USER ADDS THE DEVICE FOR CONNECTION
      }
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
                onPressed: () {}, //when device name is whatever, change the state to 1
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
        new FlatButton(
            child:Text('Main Page'),
            onPressed: (){
              if(widget.carryOn == 1){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),

                );
                return Future.value(false); //to be tested
              }else{
                // ignore: missing_return
                return Alert(context: context, title: 'Dispenser not connected').show();
              }
            }
        ),
      ],
    );
  }

 build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Column(
      children: <Widget>[],
    ),
  );

}

class MainPage extends StatelessWidget {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adherence & Alarm'),
      ),

      body: ListView(

        children: <Widget>[

          Titles.adherence,
          Boxes.consumedBox,
          Boxes.overrideBox,
          Boxes.releasedBox,
          Titles.alarm,
          Boxes.lastConsumedBox,
          Boxes.lastReleasedBox,
          Boxes.alarmBox,

          new RaisedButton(
            child: Text('Configurations'),
            onPressed: () {
              // Navigate to configuration when tapped.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
          ),
          new RaisedButton(
            child: Text('Manual Overide Pill Release'),
            color: Color.fromRGBO(55, 65, 75, 1),
            onPressed: null, //TODO SOMETHING, TO ADD FUNCTIONALITY
          ),
        ],

      ),
    );
  }
}

class ConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration"),
      ),
      body: Center(
        child: Text('Add config options. Such options include pill dosage, time intervals'),
      ),
    );
  }
}