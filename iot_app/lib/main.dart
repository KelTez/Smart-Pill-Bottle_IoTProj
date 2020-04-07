
/*
* JUST A SIMPLE HELLO_WORLD APP, FOR EASE OF FLUTTER FUNCTIONALITY. TO BUILD OFF OF THIS BASE
*/

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
