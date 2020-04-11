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
  int carryOn = 0; //used to see whether the user can carryOn from bluetooth page
  final String title;
  final String TARGET_DEVICE_NAME = 'PILL_BOTTLE'; //used for check?
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>(); //WONDERING IF WE NEED TO DISPLAY A LIST, IF PHONE CONNECTED TO DEVICE

  @override
  _BLEPageState createState() => _BLEPageState();

}

class _BLEPageState extends State<BLEScanPage>{

  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;

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

  ListView _buildListViewOfDevices() { //builds listview of devices
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
                onPressed: () {
                  if(device.name == widget.TARGET_DEVICE_NAME){
                    widget.carryOn = 1;
                  }
                  setState(() async {
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
                    _connectedDevice = device;
                  });
                }, //when device name is whatever, change the state to 1
              ),
            ],
          ),
        ),
      );
    }

    return ListView( //listview of devices that we can connect to
      padding: const EdgeInsets.all(8),

      children: <Widget>[
        ...containers,
        Container(),
        new FlatButton(
            color: Colors.blueAccent,
            child: Text('Main Page', style:TextStyle(color: Colors.white)),
            onPressed: (){
              if(widget.carryOn == 1){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
                return Future.value(false); //to be tested
              }
              return Alert(context: context, title: 'Dispenser not connected').show();
            }
        ),
      ],
    );
  }
  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();
    for (BluetoothService service in _services) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(service.uuid.toString()),
                  ],
                ),
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
      ],
    );
  }

  ListView _buildView() { //creates connected devices view
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

@override
 build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: _buildView(),
  );

}

/*
* MAIN PAGE
*/

class MainPage extends StatelessWidget { //MIGHT HAVE THIS EXTAND A WIDGET CLASS OR SOMETHINEG

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