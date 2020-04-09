/*
* JUST A SIMPLE HELLO_WORLD APP, FOR EASE OF FLUTTER FUNCTIONALITY. TO BUILD OFF OF THIS BASE
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'Widgets.dart';

void main() {
  runApp(MaterialApp(
    title: 'Smart Pill App',
    home: MainPage(),
  ));
}

class MainPage extends StatelessWidget {

  @override
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





/* EXAMPLE BELOW IS SIMPLE HELLO WORLD, TO HELP YOU UNDERSTAND HOW STUFF WORKS. UNCOMMENT IT, AND COMMENT MAIN TO SEE
// Use arrow notation for one-line functions or methods
void main() => runApp(MyApp());

//The app extends StatelessWidget which makes the app itself a widget. In Flutter, almost everything is a widget, including alignment, padding, and layout.
class MyApp extends StatelessWidget { //
  @override
  //A widget’s main job is to provide a build() method that describes how to display the widget in terms of other, lower level widgets.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      //The Scaffold widget, from the Material library, provides a default app bar, title, and a body property that holds the widget tree for the home screen.
      //The widget subtree can be quite complex.
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        // The body for this example consists of a Center widget containing a Text child widget. The Center widget aligns its widget subtree to the center of the screen.
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }

}
*/