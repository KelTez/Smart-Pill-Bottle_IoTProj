import 'package:flutter/material.dart';


class Titles{

  static final Widget adherence=Container(
    child:Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:Text(
            'Adherence',
            style: TextStyle(
              color: new Color(0xff622f74), //currently purple, for testing purposes
              fontWeight:FontWeight.bold,
              fontSize:30.0,
            ),
          ),
        ),
      ],
    ),
  );

  static final Widget alarm=Container(
    child:Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:Text(
            'Alarm',
            style: TextStyle(color: new Color(0xff622f74), fontWeight:FontWeight.bold, fontSize:30.0),
          ),
        ),
      ],
    ),
  );

}

class Boxes{
//for now, have very similar widgets except text different, currenrtly cant figure out how to add arguments
  static final Widget consumedBox= Stack(

      children: <Widget>[

        Container(
          width: 500,
          height: 100,
          child:Center(
            child:Text(
              'Data To be added here one day...',
              style:TextStyle(fontSize:20.0),
            ),
          ),
          margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
          padding: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color: Color.fromARGB(255, 51, 204, 255), width: 1),
            borderRadius: BorderRadius.circular(5),
            shape: BoxShape.rectangle,
          ),
        ),
        Positioned(
            left: 50,
            top: 12,
            child: Container(
              padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
              color: Colors.white, //background...
              child: Text(
                'Pills Consumed',
                style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
              ),
            )),
      ],
    );

  static final Widget releasedBox= Stack(

    children: <Widget>[

      Container(
        width: 500,
        height: 100,
        child:Center(
          child:Text(
            'Data To be added here one day...',
            style:TextStyle(fontSize:20.0),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 51, 204, 255), width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            color: Colors.white, //background...
            child: Text(
              'Pills Released',
              style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
            ),
          )),
    ],
  );

  static final Widget overrideBox= Stack(

    children: <Widget>[

      Container(
        width: 500,
        height: 100,
        child:Center(
          child:Text(
            'Data To be added here one day...',
            style:TextStyle(fontSize:20.0),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 51, 204, 255), width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            color: Colors.white, //background...
            child: Text(
              'Manual Overrides Done',
              style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
            ),
          )),
    ],
  );


  static final Widget lastConsumedBox= Stack(

    children: <Widget>[

      Container(
        width: 500,
        height: 100,
        child:Center(
          child:Text(
            'Data To be added here one day...',
            style:TextStyle(fontSize:20.0),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 51, 204, 255), width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            color: Colors.white, //background...
            child: Text(
              'Last Date/Time Consumed Pills',
              style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
            ),
          )),
    ],
  );

  static final Widget lastReleasedBox= Stack(

    children: <Widget>[

      Container(
        width: 500,
        height: 100,
        child:Center(
          child:Text(
            'Data To be added here one day...',
            style:TextStyle(fontSize:20.0),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 51, 204, 255), width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            color: Colors.white, //background...
            child: Text(
              'Last Date/Time Released Pills',
              style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
            ),
          )),
    ],
  );

  static final Widget alarmBox= Stack(

    children: <Widget>[

      Container(
        width: 500,
        height: 100,
        child:Center(
          child:Text(
            'Data To be added here one day...',
            style:TextStyle(fontSize:20.0),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(255, 51, 204, 255), width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 50,
          top: 12,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            color: Colors.white, //background...
            child: Text(
              'Time Until Next Alarm',
              style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
            ),
          )),
    ],
  );
}


