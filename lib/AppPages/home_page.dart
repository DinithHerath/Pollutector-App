import 'package:flutter/material.dart';
import 'package:pollutector_app_v1/AppPages/continuous_mode.dart';
import 'package:pollutector_app_v1/AppPages/device_setup.dart';
import 'package:pollutector_app_v1/AppPages/discrete_mode.dart';
import 'package:pollutector_app_v1/Presentation/icons_custom_icons.dart';
import 'package:pollutector_app_v1/Services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollutector_app_v1/Setup/Animation/FadeAnimation.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'dart:async';
// import 'dart:math';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String userid;
  String _tier;
  String mail;
  String device;
  String status;
  bool continousmode;
  bool discretemode;

  bool datarefreshed;
  bool connectdevices;
  bool loadwifisetup;
  bool statusRefreshed; 
  
  final database = Firestore.instance;  

  @override
  void initState() {
    _tier = '';
    datarefreshed = false;
    loadwifisetup = false;
    connectdevices = false;
    statusRefreshed = false;
    continousmode = false;
    discretemode = false;
    status = 'Offline';
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (error) {
      print(error);
    }
  }

  Widget showUser() {
    if (widget.userId.length > 0) {
      return new Text(
        widget.userId,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.black,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new Scaffold(
      appBar: new AppBar(
        leading: showTier(),
        elevation: 20,
        centerTitle: true,
        title: new Text("Pollutector App"),
        actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 18.0, color: Colors.white)),
                onPressed: signOut)
          ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20,),
            _showData(),
            SizedBox(height: 20,),
            referesh(),
            SizedBox(height: 5,),
            FadeAnimation(1, showConnectDeviceButton()),
            SizedBox(height: 5,),
            connectDevice(),
            FadeAnimation(1, connectionStatusText()),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: setupMode(),
            )            
        ],
      ))
    );
  }

  Widget showConnectDeviceButton() {
    return new FlatButton(
        child: new Text(
            'Tap me to connect to your Pollutector Devices!',
            style: new TextStyle(color: Colors.black),),
        onPressed: () {
          getSatus();
          getMode();
          connectdevices = true;
          setState(() {
            connectDevice();
          }); 
        });
  }

  Widget referesh() {
    return new Container(
      child: RaisedButton(
        onPressed: () {retrieveData();},
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50)
        ),
        child: Container(
          height: 50,
          width: 200,
          // color: Colors.white,
          // margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [BoxShadow(
              color: Colors.grey[500],
              blurRadius: 20,
              offset: Offset(0, 10)
            )],
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ],
            ),
          ),
          padding: EdgeInsets.all(0.0),
          child: Center(
            child: Text('Referesh User Data', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
          ),
        ),
      ),
    );
  }

  Widget connectDevice() {
    if (!connectdevices) {
      return new Container(
        height: 0.0,
        width: 0.0,
        );
    }
    return new Container(
      child: new FlatButton(
        onPressed: () {
          // getSatus();
          if (status == 'Online') {
            setState(() {
              connectionStatusText();
            });            
          } 
          else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceSetup(
                userId: userid,
                tier: _tier,
                device: device,
              )),
            );
          }
        },
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        child: _showCardSingle('Setup $device Network', 0, width: 280),
      ),
    );
  }

  Widget connectionStatusText() {
    if(status == 'Online') {
      return Container(
        width: 400,
        padding: EdgeInsets.only(top: 15, left: 15, right: 5),
        alignment: Alignment.center,
        child: 
          new RichText(
          text: new TextSpan(
            style: new TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            children: <TextSpan>[
              new TextSpan(text: 'Your '),
              new TextSpan(text: '$device', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              new TextSpan(text: ' is '),
              new TextSpan(text: 'Online', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              new TextSpan(text: '. Please Select measurement Mode from below Options.'),
              ],
            ),
          ));
      } 
    return new Text('');    
  }

  Widget modeSelectDisable(String text) {
    return new Container(
      child: new FlatButton(
        padding: EdgeInsets.all(5),
        onPressed: null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        child: _showCardSingle(text, 1, width: 175, colortext: Colors.grey),
      ),
    );
  }

  Widget modeSelectContinous() {
    return new Container(
      child: new FlatButton(
        padding: EdgeInsets.all(5),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContinuousMode(
              userId: userid,
              tier: _tier,
              device: device,
            )),
          );
        },        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        child: _showCardSingle('Continous Mode', 1, width: 170),
      ),
    );
  }

  Widget modeSelectDiscrete() {
    return new Container(
      child: new FlatButton(
        padding: EdgeInsets.all(5),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiscreteMode(
              userId: userid,
              tier: _tier,
              device: device,
            )),
          );
        },        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        child: _showCardSingle('Discrete Mode', 1, width: 170),
      ),
    );
  }

  List<Widget> setupMode() {
    List<Widget> widgetsList = List();
    if (status == 'Offline') {
      widgetsList.add(new Container(
      height: 0.0,
      width: 0.0,
      ));
    } 
    else {
      if (continousmode) {
        widgetsList.add(modeSelectContinous());
      } else {
        widgetsList.add(modeSelectDisable('Continuous Mode'));
      }
      widgetsList.add(SizedBox(width: 15,));
      if (discretemode) {
        widgetsList.add(modeSelectDiscrete());
      } else {
        widgetsList.add(modeSelectDisable('Discrete Mode'));
      }
    }
    return widgetsList;
  }

  Widget _showData() {
    if (!datarefreshed) {
      retrieveData();
      return Center(child: CircularProgressIndicator());
    }      
    return new FadeAnimation(1, Container(
      child: Column(
        children: <Widget>[
          _showCard('Email', mail, 1.2),
          SizedBox(height: 20),  
          _showCard('Unique ID', userid, 1.3),
          SizedBox(height: 20),  
          _showCard('Device ID', device, 1.4),
        ],
      )
    ));
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

  Widget _showCardSingle(String text, double delay, {Color colortext = Colors.black , double width = 375}) 
  {
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
      child: Text(text, style: TextStyle(color: colortext, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.center,)
    ));
  }

  void updateData() {
    try {
      database
          .collection('Users')
          .document(widget.userId)
          .updateData({'Tier': 'pro'});
    } catch (error) {
      print(error.toString());
    }
  }

  void deleteData() {
    try {
      database
          .collection('Users')
          .document('delete me')
          .delete();
    } catch (error) {
      print(error.toString());
    }
  }

  Widget showTier() {
    if (_tier.length == 0) {
      retrieveTier();
    }
    if (_tier == 'pro') {
      return new Icon(IconsCustom.pro);
    } else if (_tier == 'plus') {
      return new Icon(IconsCustom.plus);
    } else if (_tier == 'basic') {
      return new Icon(IconsCustom.basic);
    } else {
      return Icon(Icons.not_interested);
    }
  }

  void retrieveTier() async 
  {
    DocumentSnapshot snapshot = await database.collection('Users').document(widget.userId).get();
    if (snapshot.data['Tier'].isNotEmpty) {
      setState(() {
        _tier = snapshot.data['Tier'].toString();
      });
    }
    
  }

  void retrieveData() async 
  {
    DocumentSnapshot snapshot = await database.collection('Users').document(widget.userId).get();
    if (snapshot.data != null) {
      setState(() {
        _tier = snapshot.data['Tier'].toString();
        userid = widget.userId;
        mail = snapshot.data['Email'].toString();
        device = snapshot.data['Device'].toString();
      });    
    }
    datarefreshed = true;
  }

  void refereshData() async
  {
    datarefreshed = false;
    retrieveData();
  }

  void getSatus() async 
  {
    DocumentSnapshot snapshot = await database.collection('Users').document(userid).get();
    if (snapshot.data != null) {
      setState(() {
        status = snapshot.data['Connection Status'].toString();
      });    
    }
    statusRefreshed = true;
  }

  void getMode() async 
  {
    DocumentSnapshot snapshot = await database.collection('Users').document(userid).get();
    if (snapshot.data != null) {
      setState(() {
        continousmode = snapshot.data['Continuous Mode'];
        discretemode = snapshot.data['Discrete Mode'];
      });    
    }
    statusRefreshed = true;
  }

}

// class Record {
//   final String mail;
//   final String _tier;
//   final DocumentReference reference;

//   Record.fromMap(Map<String, dynamic> map, {this.reference})
//       : assert(map['Email'] != null),
//         assert(map['Tier'] != null),
//         mail = map['Email'],
//         _tier = map['Tier'];

//   Record.fromSnapshot(DocumentSnapshot snapshot)
//       : this.fromMap(snapshot.data, reference: snapshot.reference);

//   @override
//   String toString() => "Record<$mail:$_tier>";
// }




