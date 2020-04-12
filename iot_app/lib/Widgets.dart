import 'package:flutter/material.dart';

/*
TITLES
*/
class Titles extends StatefulWidget{
  Titles({Key key, this.title,this.hexColor,this.size}) : super(key: key);
  final String title;
  final int hexColor; //hex
  final double size;
  @override
  _TitlesState createState() => _TitlesState();
}

class _TitlesState extends State<Titles>{
Widget build(BuildContext context){
  return Container(
    child:Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:Text(
            widget.title,
            style: TextStyle(color: new Color(widget.hexColor), fontWeight:FontWeight.bold, fontSize:widget.size),
          ),
        ),
      ],
    ),
  );
  }
}

/*
DATABOXES
*/
class DataBoxes extends StatefulWidget{
  DataBoxes({Key key, this.title,this.data}) : super(key: key);
  final int data;
  final String title;
  @override
  _DataBoxesState createState() => _DataBoxesState();
}

class _DataBoxesState extends State<DataBoxes>{

  Widget build(BuildContext context){
    return Stack(

      children: <Widget>[
        Container(
          width: 500,
          height: 90,
          child:Center(
            child:Text(
              widget.data.toString(),
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
              color: Colors.grey[50], //background...
              child: Text(
                widget.title,
                style: TextStyle(color: Colors.black, fontSize: 15,fontWeight:FontWeight.bold),
              ),
            )),
      ],
    );
  }
}






