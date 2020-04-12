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
final String TARGET_DEVICE_NAME = 'PILL_BOTTLE';
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
  void _setConnected() {
    setState(() {
      connected = true; //only sets PILL_BOTTLE connection status, for ease. basically hardcoded
    });
  }
  ListView _buildListViewOfDevices() { //builds listview of devices
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in devicesList) {
      if(connected && device.name == TARGET_DEVICE_NAME){
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
                  if(device.name == TARGET_DEVICE_NAME){
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
                      _setConnected();
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
                return Future.value(false);
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

class _MainPageState extends State<MainPage> {

  void incrementCounter(String string) {
    setState(() { //change state of main to have increment a larger value.
      if(string == 'manualOverridesDone'){
        manualOverridesDone++;
      }else if(string == 'pillsConsumed'){
        pillsConsumed++;
      }else if(string == 'pillsReleased'){
        pillsReleased++;
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adherence & Alarm'),
      ),

      body: ListView(

        children: <Widget>[

          Titles(title:'Adherence',hexColor:0xff622f74,size:30.0),
          DataBoxes(title:'Pills Consumed',data:pillsConsumed),
          new Container(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0.5),
                ),
                new MaterialButton(
                    color: Colors.blueAccent,
                    minWidth: 50.0,
                    child: Text('Increase Pill Consumption', style:TextStyle(color: Colors.white)),
                    onPressed: (){
                      if(pillsConsumed + 1 > pillsReleased){
                        Alert(
                            context: context,
                            title: 'WARNING! Consuming more pills than released.',
                            desc: 'Proceed?',
                            buttons: [
                              DialogButton(
                                child:Text('No.',style:TextStyle(color:Colors.white)),
                                color: Colors.blueAccent,
                                onPressed: () => Navigator.pop(context),
                              ),
                              DialogButton(
                                  child:Text('Yes.', style:TextStyle(color:Colors.white)),
                                  color: Colors.blueAccent,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    incrementCounter('pillsConsumed');
                                  }
                              )
                            ]
                        ).show();
                      }else {
                        incrementCounter('pillsConsumed');
                      }
                    }
                ),
              ],
            ),
          ),

          DataBoxes(title:'Pills Released',data:pillsReleased),
          DataBoxes(title:'Manual Overrides Done',data:manualOverridesDone),
          Titles(title:'Alarm',hexColor:0xff622f74,size:30.0),
          DataBoxes(title:'Last Date/Time Consumed Pill',data:0),
          DataBoxes(title:'Last Date/Time Released Pill',data:0),
          DataBoxes(title:'Time Until Next Alarm',data:0),

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
            child: Text('Manual Override Pill Release',style:TextStyle(color:Colors.grey[50])),
            color: Color.fromRGBO(55, 65, 75, 1),
            onPressed: (){
              return Alert(
                  context: context,
                  title: 'Manually release pill before schedule?',
                  desc: 'Are you sure you want to release a pill?',
                  buttons: [
                    DialogButton(
                      child:Text('No, nevermind.',style:TextStyle(color:Colors.white)),
                      color: Colors.blueAccent,
                      onPressed: () => Navigator.pop(context),
                    ),
                    DialogButton(
                      child:Text('Yes, I am sure!', style:TextStyle(color:Colors.white)),
                      color: Colors.blueAccent,
                      onPressed: () {
                        Navigator.pop(context);
                        //c.write(utf8.encode(UARTunlock));
                        c.write(utf8.encode(UARTdispense));
                        //c.write(utf8.encode(UARTlock));
                        incrementCounter('manualOverridesDone');
                        incrementCounter('pillsReleased');
                      }
                    )
                  ]
              ).show();

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