/*
IMPORTS
*/
import 'dart:ui' show IsolateNameServer;
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
BluetoothCharacteristic c; //use this to write
List<BluetoothService> _services;
int pillsConsumed = 0; //for this one, user manually adds it in
int manualOverridesDone = 0; //need a way for these numbers to be saved, prolly database. for now, ill ignore that
int pillsReleased = 0;
String buttonText = 'Connect';
bool connected = false;
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

/*
MAIN
*/
void main() async {
  // This line is needed due to what seems to be a bug in the flutter SDK
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IotApp());
}

/*
IOT APP CLASS
*/

class IotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLEScanPage',
      home: BLEScanPage(title: 'Bluetooth Scan'),
      // For easy testing on emulator
      //home: MainPage(),
    );
  }
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
  final ConfigMenu config = ConfigMenu();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      initAlarms(context);
    });
  }

  void incrementCounter(String string) async {
    SharedPreferences prefs = await _prefs;
    setState(() { //change state of main to have increment a larger value.
      if(string == 'manualOverridesDone'){
        manualOverridesDone++;
      }else if(string == 'pillsConsumed'){
        pillsConsumed++;
      }else if(string == 'pillsReleased'){
        int numPills = prefs.getInt('num_pills') ?? 0;
        if (numPills > 0) {
          prefs.setInt('num_pills', numPills - 1);
        }
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
                            type: AlertType.warning,
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
              config.configMenu(context);
            },
          ),
          new RaisedButton(
            child: Text('Manual Override Pill Release',style:TextStyle(color:Colors.grey[50])),
            color: Color.fromRGBO(55, 65, 75, 1),
            onPressed: (){
              return Alert(
                  context: context,
                  type: AlertType.info,
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

/*
* CONFIG CLASS
*/

class ConfigMenu {
  void configMenu(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Configuration Menu",
      desc: "Please select the option to configure\n"
          "If this is the first configuration, please press next "
          "to go through each field",
      buttons: [
        DialogButton(
          child: Text("Pill Count"),
          onPressed: () {
            enterNumPills(context);
          },
        ),
        DialogButton(
          child: Text("Schedule"),
          onPressed: () {
            enterPrescriptionSchedule(context);
          },
        ),
        DialogButton(
          child: Text("Next"),
          onPressed: () {
            enterNumPills(context);
          },
        ),
        DialogButton(
          child: Text("Exit"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  void enterNumPills(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    TextEditingController controller = TextEditingController();
    controller.text = (prefs.getInt('num_pills') ?? 0).toString();
    Alert(
      context: context,
      type: AlertType.info,
      title: "Pill count",
      desc: "Enter the number of pills to be loaded.",
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'Number of pills to store in bottle',
            ),
            controller: controller,
            keyboardType: TextInputType.number,
            onTap: () {
              controller.text = "";
            },
            onSubmitted: (String value) async {
              prefs.setInt('num_pills', int.parse(value));
            },
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text("Menu"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        DialogButton(
          child: Text("Next"),
          onPressed: () {
            Navigator.pop(context);
            confirmPillsLoaded(context);
          },
        ),
      ],
    ).show();
  }

  void confirmPillsLoaded(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Load bottle",
      desc: "Please load the bottle with the entered number of pills.",
      buttons: [
        DialogButton(
          child: Text("Confirm"),
          onPressed: () {
            Navigator.pop(context);
            enterPrescriptionSchedule(context);
          },
        ),
      ],
    ).show();
  }

  void enterPrescriptionSchedule(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    TextEditingController weekController = TextEditingController();
    TextEditingController dayController = TextEditingController();
    TextEditingController hourController = TextEditingController();
    TextEditingController minuteController = TextEditingController();

    weekController.text = (prefs.getInt('weeks') ?? 0).toString();
    dayController.text = (prefs.getInt('days') ?? 0).toString();
    hourController.text = (prefs.getInt('hours') ?? 0).toString();
    minuteController.text = (prefs.getInt('minutes') ?? 0).toString();

    Alert(
      context: context,
      type: AlertType.info,
      title: "Schedule",
      desc: "Enter the amount of time between doses\n"
          "This should be entered when the first dose of the medication is taken.",
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'Week(s)',
            ),
            controller: weekController,
            keyboardType: TextInputType.number,
            onTap: () {
              weekController.text = "";
            },
            onSubmitted: (String value) async {
              prefs.setInt('weeks', int.parse(value));
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Day(s)',
            ),
            controller: dayController,
            keyboardType: TextInputType.number,
            onTap: () {
              dayController.text = "";
            },
            onSubmitted: (String value) async {
              prefs.setInt('days', int.parse(value));
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Hour(s)',
            ),
            controller: hourController,
            keyboardType: TextInputType.number,
            onTap: () {
              hourController.text = "";
            },
            onSubmitted: (String value) async {
              prefs.setInt('hours', int.parse(value));
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Minute(s)',
            ),
            controller: minuteController,
            keyboardType: TextInputType.number,
            onTap: () {
              minuteController.text = "";
            },
            onSubmitted: (String value) async {
              prefs.setInt('minutes', int.parse(value));
            },
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text("Back"),
          onPressed: () {
            Navigator.pop(context);
            enterNumPills(context);
          },
        ),
        DialogButton(
          child: Text("Clear Schedule", style: TextStyle(fontSize: 14)),
          onPressed: () {
            int alarmID = 0;
            prefs.setInt('weeks', 0);
            prefs.setInt('days', 0);
            prefs.setInt('hours', 0);
            prefs.setInt('minutes', 0);
            AndroidAlarmManager.cancel(alarmID);
            Navigator.pop(context);
          },
        ),
        DialogButton(
          child: Text("Update Schedule", style: TextStyle(fontSize: 14)),
          onPressed: () async {
            int alarmID = 0;
            int weeks = prefs.getInt('weeks') ?? 0;
            int days = prefs.getInt('days') ?? 0;
            int hours = prefs.getInt('hours') ?? 0;
            int minutes = prefs.getInt('minutes') ?? 0;
            // Cancel previous alarm before creating a new one
            AndroidAlarmManager.cancel(alarmID);
            if (weeks > 0 || days > 0 || hours > 0 || minutes > 0) {
              await AndroidAlarmManager.periodic(
                  Duration(days: weeks * 7 + days, hours: hours, minutes: minutes),
                  alarmID, AlarmCallback.triggerAlarm, exact: true,
                  wakeup: true, rescheduleOnReboot: true);
            }
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }
}

/*
* ALARM CALLBACK CLASS
*/

class AlarmCallback {
  static final ReceivePort _uiport = ReceivePort();
  static BuildContext context;
  static bool alertFlag = false;

  static void setup(BuildContext buildContext) {
    IsolateNameServer.registerPortWithName(_uiport.sendPort, 'alarm');
    context = buildContext;
    _uiport.listen((alarmOn) {
      print("Callback reached");
      if (alarmOn) {
        FlutterRingtonePlayer.playAlarm();
        alarmAlert();
      }
    });
  }

  static Future<void> triggerAlarm() async {
    print("Start send");
    showNotification();
    SendPort uiPort = IsolateNameServer.lookupPortByName('alarm');
    uiPort.send(true);
  }

  static void alarmAlert() {
    if (!alertFlag) {
      alertFlag = true;
      Alert(
        context: context,
        type: AlertType.info,
        title: "Scheduled Dose Alert",
        desc: "It's time to take your pill bud.",
        buttons: [
          DialogButton(
            child: Text("Dismiss alarm"),
            onPressed: () {
              FlutterRingtonePlayer.stop();
              alertFlag = false;
              Navigator.pop(context);
            },
          ),
        ],
      ).show();
    }
  }
}

/*
* UTILITY ALARM AND NOTIFICATION FUNCTIONS
*/

void initAlarms(BuildContext context) async {
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  AlarmCallback.setup(context);
  await AndroidAlarmManager.initialize();
}

void showNotification() async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'Time to take your dose', 'Please tap to dismiss the alarm', platformChannelSpecifics,
      payload: 'item x');
}

Future selectNotification(String payload) async {
  FlutterRingtonePlayer.stop();
  print('Notification selected');
}