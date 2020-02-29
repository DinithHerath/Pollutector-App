import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pollutector_app_v1/Chart%20Pages/aqi.dart';
import 'package:pollutector_app_v1/Chart%20Pages/gasvalue.dart';
import 'package:pollutector_app_v1/Chart%20Pages/humidity.dart';
import 'package:pollutector_app_v1/Chart%20Pages/temperature.dart';
import 'package:pollutector_app_v1/Presentation/icons_custom_icons.dart';
import 'package:pollutector_app_v1/Setup/Animation/FadeAnimation.dart';

class ContinuousMode extends StatefulWidget {
  ContinuousMode({Key key, this.tier, this.userId, this.device})
      : super(key: key);

  final String userId;
  final String tier;
  final String device;

  @override
  State<StatefulWidget> createState() => new _ContinuousModeState();
}

class _ContinuousModeState extends State<ContinuousMode> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var pmtext = new RichText(
    text: new TextSpan(
      style: new TextStyle(
        fontSize: 17,
        color: Colors.black,
      ),
      children: <TextSpan>[
        new TextSpan(text: 'PM', style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(text: '2.5', style: new TextStyle(fontSize: 12)),
        new TextSpan(text: ' Value', style: new TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  String userid;
  String device;
  String tier;
  DateTime time;
  int aqi;
  double temp;
  double humidity;
  double gasvalue;
  double pm25;

  final database = Firestore.instance;

  Timer timer;

  @override
  void initState() {
    userid = '';
    device = '';
    tier = '';
    time = DateFormat("yyyy-MM-dd HH:mm:ss").parse("2020-01-01 0:00:00");
    aqi = 0;
    pm25 = 0;
    temp = 0;
    humidity = 0;
    gasvalue = 0;
    retrieveData();
    getData();
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (timer) => getData(showsnackbar: true));
  }

  showSnackBar(String copy) {
    final snackBar = new SnackBar(
      content: new Text('Data Refreshed at $copy'),
      backgroundColor: Colors.blue,
      elevation: 10,
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        automaticallyImplyLeading: true,
        elevation: 20,
        centerTitle: true,
        title: new Text('Continuous Mode'),
        actions: <Widget>[Padding(
          padding: const EdgeInsets.all(15.0),
          child: showTier(),
        )],
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10,),
              _showCard('Device', device, 1),
              SizedBox(height:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    padding: EdgeInsets.all(6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Temperature(
                          userId: userid,
                          tier: tier,
                          device: device,
                        )),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: _showValue('Temperature', temp.toString() + ' \u2103', 1.2)),
                  SizedBox(width: 2),
                  FlatButton(
                    padding: EdgeInsets.all(6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Humidity(
                          userId: userid,
                          tier: tier,
                          device: device,
                        )),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: _showValue('Humidity', humidity.toString() + '%', 1.2))
                ],
              ),
              SizedBox(height:15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    padding: EdgeInsets.all(6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AQI(
                          userId: userid,
                          tier: tier,
                          device: device,
                        )),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: _showValue('AQI', aqi.toString(), 1.4)),
                  SizedBox(width: 2),
                  FlatButton(
                    padding: EdgeInsets.all(6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GasSensor(
                          userId: userid,
                          tier: tier,
                          device: device,
                        )),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: _showValue('Gas Sensor', gasvalue.toString(), 1.4))
                ],
              ),
              SizedBox(height:20),
              _showCardPM(1.6),
              SizedBox(height:20),
              _showCard('Last Update', DateFormat("yyyy-MM-dd HH:mm:ss").format(time), 1.8)
            ],
          ),
        ),
      ),
    );
  }


  Widget _showCard(String text, String param, double delay, {double width=375}) {
    return FadeAnimation(delay, Container(
      width: width,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
        )]
      ),
      child: Row(
        children: <Widget>[
          Text(text, style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.left,),
          SizedBox(width:50),
          Expanded(child: 
            Text(param, 
              style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w300, fontFamily: 'Roboto'), 
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,),
          ) 
        ],
      )
    ));
  }

  Widget _showCardPM(double delay) {
    return FadeAnimation(delay, Container(
      width: 375,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
        )]
      ),
      child: Row(
        children: <Widget>[
          pmtext,
          SizedBox(width:50),
          Expanded(child: 
            Text('$pm25 ppm', 
              style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w300, fontFamily: 'Roboto'), 
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,),
          ) 
        ],
      )
    ));
  }

  Widget _showValue(String text, String param, double delay, {double width=180}) {
    return FadeAnimation(delay, Container(
      width: width,
      height: 150,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
        )]
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height:10),
          Text(text, style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.left,),
          SizedBox(height:30),
          Expanded(child: 
            Text(param, 
              style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w300, fontFamily: 'Roboto'), 
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,),
          ) 
        ],
      )
    ));
  }

  Widget showTier() {
    if (tier == 'pro') {
      return new Icon(IconsCustom.pro);
    } else if (tier == 'plus') {
      return new Icon(IconsCustom.plus);
    } else if (tier == 'basic') {
      return new Icon(IconsCustom.basic);
    } else {
      return Icon(Icons.not_interested);
    }
  }

  void getData({bool showsnackbar = false}) async 
  {
    DocumentSnapshot snapshot = await database.collection(device).document('Continuous Mode').get();
    if (snapshot.data != null) {
      setState(() {
        aqi = snapshot.data['AQI'];
        gasvalue = snapshot.data['Gas Value'];
        humidity = snapshot.data['Humidity'];
        temp = snapshot.data['Temperature'];
        time = snapshot.data['Time'].toDate();
        pm25 = snapshot.data['PM2.5'];
      });    
    }
    if (showsnackbar) {
      showSnackBar(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));
    }
  }

  void retrieveData() async 
  {
    setState(() {
      tier = widget.tier;
      userid = widget.userId;
      device = widget.device;
    });    
  }

}