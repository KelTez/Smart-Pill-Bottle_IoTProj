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
  final String data;
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
          height: 80,
          child:Center(
            child:Text(
              widget.data,
              style:TextStyle(fontSize:20.0),
            ),
          ),
          margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
          padding: EdgeInsets.only(bottom: 2,left: 10, right: 10),
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


/*
DATABOXES
*/

class TimerBody extends StatefulWidget{
  TimerBody({Key key, this.days,this.hours,this.minutes,this.size, this.title}) : super(key: key);
    final int days;
    final int hours;
    final int minutes;
    final double size;
    final String title;

  @override
  _TimerBodyState createState() => _TimerBodyState();
}

class _TimerBodyState extends State<TimerBody>{

  Widget build(BuildContext context){
    return Stack(

      children: <Widget>[
        Container(
          width: 5000,
          height: 90,
            child: Timer(days:widget.days,hours:widget.hours,minutes:widget.minutes,size:widget.size),

          margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
          padding: EdgeInsets.only(bottom: 2),
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

/*
* CLOCK BODY
*/

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({
    Key key,
    int secondsRemaining,
    this.countDownTimerStyle,
    this.whenTimeExpires,
    this.countDownFormatter,
  })  : secondsRemaining = secondsRemaining,
        super(key: key);

  final int secondsRemaining;
  final Function whenTimeExpires;
  final Function countDownFormatter;
  final TextStyle countDownTimerStyle;

  State createState() => new _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Duration duration;

  String get timerDisplayString {
    Duration duration = _controller.duration * _controller.value;
    return widget.countDownFormatter != null
        ? widget.countDownFormatter(duration.inSeconds)
        : formatWWDDHHMMSS(duration.inSeconds);
    // In case user doesn't provide formatter use the default one
    // for that create a method which will be called formatHHMMSS or whatever you like
  }

  String formatWWDDHHMMSS(int seconds) {
    int weeks = (seconds / 604800).truncate();
    seconds = (seconds % 604800).truncate();
    int days = (seconds / 86400).truncate();
    seconds = (seconds % 86400).truncate();
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String weeksStr = (weeks).toString().padLeft(2, '0');
    String daysStr = (days).toString().padLeft(2, '0');
    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if(weeks == 0){
      return "$daysStr" + "days:" + "$hoursStr" + "hrs:" + "$minutesStr" + "mins:" + "$secondsStr" + "s";
    }else if (days == 0){
      return "$hoursStr" + "hrs:" + "$minutesStr" + "mins:" + "$secondsStr" + "s";
    }else if (hours == 0) {
      return "$minutesStr" + "mins:" + "$secondsStr" + "s";
    }

    return "$weeksStr" + "wks:" + "$daysStr" + "days:" + "$hoursStr" + "Hrs:" + "$minutesStr" + "mins:" + "$secondsStr" + "s";
  }

  @override
  void initState() {
    super.initState();
    duration = new Duration(seconds: widget.secondsRemaining);
    _controller = new AnimationController(
      vsync: this,
      duration: duration,
    );
    _controller.reverse(from: widget.secondsRemaining.toDouble());
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        widget.whenTimeExpires();
      }
    });
  }

  @override
  void didUpdateWidget(CountDownTimer oldWidget) {
    if (widget.secondsRemaining != oldWidget.secondsRemaining) {
      setState(() {
        duration = new Duration(seconds: widget.secondsRemaining);
        _controller.dispose();
        _controller = new AnimationController(
          vsync: this,
          duration: duration,
        );
        _controller.reverse(from: widget.secondsRemaining.toDouble());
        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.whenTimeExpires();
          } else if (status == AnimationStatus.dismissed) {
            print("Animation Complete");
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: AnimatedBuilder(
            animation: _controller,
            builder: (_, Widget child) {
              return Text(
                timerDisplayString,
                style: widget.countDownTimerStyle,
              );
            }));
  }
}
class Timer extends StatefulWidget{
  Timer({Key key, this.days,this.hours,this.minutes,this.size,this.hexColor}) : super(key: key);
  final int days;
  final int hours; //hex
  final int minutes;
  final double size;
  final int hexColor;
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer>{
  Widget build(BuildContext context){
    return Container(
      width: 60.0,
      padding: EdgeInsets.only(top: 3.0, right: 4.0),
      child: CountDownTimer(
        secondsRemaining: widget.days*86400 + widget.hours*3600 + widget.minutes*60,
        whenTimeExpires: () {
          //do something?
        },
        countDownTimerStyle: TextStyle(
            fontSize: widget.size,
            height: 1.2),
      ),
    );
  }
}




