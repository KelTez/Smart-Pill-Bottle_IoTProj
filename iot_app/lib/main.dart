/*
IMPORTS
*/
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'Widgets.dart';

/*
GLOBALS
*/
final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
final String UARTdispense = 'p';
final String UARTlock = 'l';
final String UARTunlock = 'u';
BluetoothCharacteristic c; //use this to write
List<BluetoothService> _services;
int pillsConsumed = 0; //for this one, user manually adds it in
int manualOverridesDone = 0; //need a way for these numbers to be saved, prolly database. for now, ill ignore that
int pillsReleased = 0;
String buttonText = 'Connect';
bool connected = false;

/*
MAIN
*/
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

/*
BLE SCAN PAGE
*/
class BLEScanPage extends StatefulWidget {
  BLEScanPage({Key key, this.title}) : super(key: key);
  int carryOn = 0; //used to see whether the user can carryOn from bluetooth page
  final String title;
  final String TARGET_DEVICE_NAME = 'PILL_BOTTLE'; //used for check?
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  @override
  _BLEPageState createState() => _BLEPageState();

}

class _BLEPageState extends State<BLEScanPage>{

  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
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
  void _changeButtonText() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      buttonText = 'Connected';
      connected = true;
    });
  }
  ListView _buildListViewOfDevices() { //builds listview of devices
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in devicesList) {
      if(connected && device.name == widget.TARGET_DEVICE_NAME){
        buttonText = 'Connected';
      }else{
        buttonText = 'Connect';
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
                  '$buttonText',
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
                      _changeButtonText();
                      if(widget.carryOn == 1) {
                        _services = await device.discoverServices();
                          _services.forEach((service) { //double for
                            if(service.uuid.toString()==SERVICE_UUID){
                              service.characteristics.forEach((characteristic){
                                if (characteristic.uuid.toString() == CHARACTERISTIC_UUID){
                                  c = characteristic;
                                }
                              }
                              );
                            }
                          }
                          );
                      }
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
              if(widget.carryOn ==  1){ //set to 0 for emulation purposes to test the app
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
  ListView _buildView() { //creates connected devices view
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



class MainPage extends StatefulWidget{
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> { //MIGHT HAVE THIS EXTAND A WIDGET CLASS OR SOMETHINEG

  void incrementCounter(int increment) {
    setState(() { //change state of main to have increment a larger value.
      increment++;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adherence & Alarm'),
      ),

      body: ListView(

        children: <Widget>[

          Titles(title:'Adherence',hexColor:0xff622f74,size:30.0), //add the boxes class to main, need to send the data here. to increment with states, to Text('$var')
          DataBoxes(title:'Pills Consumed'),
          DataBoxes(title:'Pills Released'),
          DataBoxes(title:'Manual Overrides Done'),
          Titles(title:'Alarm',hexColor:0xff622f74,size:30.0),
          DataBoxes(title:'Last Date/Time Consumed Pill'),
          DataBoxes(title:'Last Date/Time Released Pill'),
          DataBoxes(title:'Time Until Next Alarm'),

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
            child: Text('$manualOverridesDone'), //Manual Override Pill Release
            color: Color.fromRGBO(55, 65, 75, 1),
            onPressed: (){ //maybe have an alert to ask user if they are sure they want to manually release the pill.
              //c.write(utf8.encode(UARTunlock));
              c.write(utf8.encode(UARTdispense));
              //c.write(utf8.encode(UARTlock));
              //incrementCounter(manualOverridesDone);
              //incrementCounter(pillsReleased);
            },
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