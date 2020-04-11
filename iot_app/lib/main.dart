/*
* JUST A SIMPLE HELLO_WORLD APP, FOR EASE OF FLUTTER FUNCTIONALITY. TO BUILD OFF OF THIS BASE
*/

import 'dart:isolate';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'Widgets.dart';


// TODO: Add push notification and sound alert when this occurs
void testAlarm() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$testAlarm'");
}

void main() async {
  final int alarmID = 0;
  bool init;
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(MaterialApp(
    title: 'BLEScanPage',
    home: BLEScanPage(title: 'Bluetooth Scan'),
  ));
  await AndroidAlarmManager.periodic(const Duration(seconds: 10), alarmID, testAlarm);
}

class BLEScanPage extends StatefulWidget {
  BLEScanPage({Key key, this.title}) : super(key: key);

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

