import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pollutector_app_v1/Presentation/icons_custom_icons.dart';
import 'package:pollutector_app_v1/Setup/Animation/FadeAnimation.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_charts/charts.dart';

class Temperature extends StatefulWidget {
  Temperature({Key key, this.tier, this.userId, this.device})
      : super(key: key);

  final String userId;
  final String tier;
  final String device;

  @override
  State<StatefulWidget> createState() => new _TemperatureState();
}

class _TemperatureState extends State<Temperature> {
  
  String tier;
  String userid;
  String device;
  bool statusRefreshed;
  String status;  

  final database = Firestore.instance;

  Timer timer;

  @override
  void initState() {
    userid = '';
    device = '';
    tier = '';
    status = 'Offline';
    statusRefreshed = false;
    getStatus();
    retrieveData();
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (timer) => getStatus());
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

  // List<charts.Series> _chartData;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton( 
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back),
          ),
        elevation: 20,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: new Text('Temperature' , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: showTier(),
          ),
          IconButton(icon: Icon(Icons.home , color: Colors.black,), onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
          }),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(context) {
    return StreamBuilder<QuerySnapshot>(
      stream: database
      .collection('$device/Continuous Mode/Continuous Data')
      .where('Time', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(Duration(seconds: 60))))
      .snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        else {
          List<TemperatureData> temp = snapshot.data.documents.map((documentSnapshot) => TemperatureData.fromMap(documentSnapshot.data)).toList();
          return _buildChart(context, temp);
        }
      }
    );
  }

  // static List<charts.Series<TemperatureData, DateTime>> _createData(List<TemperatureData> temp) {
  //   return [
  //     new charts.Series<TemperatureData, DateTime>(
  //       id: 'Temperature',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (TemperatureData tempData, _) => tempData.time,
  //       measureFn: (TemperatureData tempData, _) => tempData.temp,
  //       data: temp,
  //     )
  //   ];
  // }

  Widget _buildChart(BuildContext context, List<TemperatureData> temp) {
    // _chartData = _createData(temp);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget> [
              SizedBox(height: 20),
              Text('Temperature of $device', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
              SizedBox(height: 20),
              FadeAnimation(1, Container(
                  // height: 400,
                  // child: charts.TimeSeriesChart(
                  //   _chartData,
                  //   animate: true,
                  //   animationDuration: Duration(seconds: 2),
                  // ),
                  height: 400,
                  child: SfCartesianChart(
                    legend: Legend(
                      isVisible: true,
                      ), 
                    tooltipBehavior: TooltipBehavior(
                      enable: true
                    ),
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat.Hms()
                    ),
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value} \u2103',
                      minimum: 15,
                      maximum: 40
                    ),
                    series: <ChartSeries>[
                      SplineSeries<TemperatureData, DateTime>(
                        dataSource: temp,
                        splineType: SplineType.monotonic,
                        // cardinalSplineTension: 0.9,
                        xValueMapper: (TemperatureData humidData, _) => humidData.time,
                        yValueMapper: (TemperatureData humidData, _) => humidData.temp,
                        name: 'Temperature',
                        animationDuration: 2000,
                        color: Colors.blue[600],
                        markerSettings: MarkerSettings(
                          isVisible: true),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: false
                        ),
                        enableTooltip: true, 
                      )
                    ]
                  )
                ),
              ),
              SizedBox(height:10),
              showCardConnection(),
            ]
          )
        )
      ),
    );
  }

  Widget showCardConnection() {
    // if (!statusRefreshed) {
    //   return new Container(
    //     height: 0.0,
    //     width: 0.0,
    //   );
    // }
    return FadeAnimation(1, Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          // alignment: Alignment.bottomLeft,
          width: 260,
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
              Text('Connection Status', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.left,),
              SizedBox(width: 60),
              Expanded(child: 
                showStatus()
              ) 
            ],
          )
        ),
      ],
    ));
  }

  Widget showStatus() {
    if (statusRefreshed) {
      if (status == 'Online') {
        return new Icon(IconsCustom.onlinedevice);        
      }
      else if (status == 'Offline') {
        return new Icon(IconsCustom.offlinedevice); 
      }
    }
    return new Icon(Icons.network_check);
  }
 
  Widget showTier() {
    if (tier == 'pro') {
      return new Icon(IconsCustom.pro , color: Colors.black,);
    } else if (tier == 'plus') {
      return new Icon(IconsCustom.plus , color: Colors.black,);
    } else if (tier == 'basic') {
      return new Icon(IconsCustom.basic , color: Colors.black,);
    } else {
      return Icon(Icons.not_interested , color: Colors.black,);
    }
  }

  void getStatus() async 
  {
    DocumentSnapshot snapshot = await database.collection('Users').document(userid).get();
    if (snapshot.data != null) {
      setState(() {
        status = snapshot.data['Connection Status'].toString();
        tier = snapshot.data['Tier'].toString();
      });    
    }
    statusRefreshed = true;
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

class TemperatureData {
  final DateTime time;
  final double temp;

  TemperatureData(this.time, this.temp);

  TemperatureData.fromMap(Map<String, dynamic> map)
  :assert(map['Temperature'] != null),
  assert(map['Time'] != null),
    temp = map['Temperature'],
    time = map['Time'].toDate();

  @override
   String toString() => "Record<$temp:$time>";

}



