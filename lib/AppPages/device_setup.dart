import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:open_settings/open_settings.dart';
import 'package:pollutector_app_v1/Presentation/icons_custom_icons.dart';
import 'package:pollutector_app_v1/Setup/Animation/FadeAnimation.dart';

class DeviceSetup extends StatefulWidget {
  DeviceSetup({Key key, this.tier, this.userId, this.device})
      : super(key: key);

  final String userId;
  final String tier;
  final String device;

  @override
  State<StatefulWidget> createState() => new _DeviceSetupState();
}

class _DeviceSetupState extends State<DeviceSetup> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String userid;
  String tier;
  String device;
  String status;
  bool openWifiTap;
  bool openMobileTap;    
  bool statusRefreshed;
  int wificount;

  final database = Firestore.instance;
  
  @override
  void initState() {
    tier = '';
    userid = '';
    device = '';
    status = 'Offline';
    wificount = 0;
    openWifiTap = false;
    openMobileTap = false;
    statusRefreshed = false;
    retrieveData();
    super.initState();
  }

  showSnackBar(String copy) {
    final snackBar = new SnackBar(
      content: new Text('$copy copied To Clipboard'),
      backgroundColor: Colors.blue,
      elevation: 10,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
        title: new Text("$device WiFi Setup"),
        actions: <Widget>[Padding(
          padding: const EdgeInsets.all(15.0),
          child: showTier(),
        )],
      ),
      body: Container(
            child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: <Widget>[
              showCardSingle('1. Turn Off WiFi to enable Hotspot of the Mobile.', 1, width: 400),
              SizedBox(height:10),
              FadeAnimation(1.1, openWifiSetting()),
              SizedBox(height:10),
              showSecondStep(),
              showThirdStep(),
              SizedBox(height:10),
              showCardConnection()
              ],
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black54,
        backgroundColor: Colors.blue,
        elevation: 0,
        child: Icon(Icons.refresh),
        mini: true,
        onPressed: () {getStatus();},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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

  Widget showCard(String text, String param, double delay, {double width=375}) {
    return FadeAnimation(delay, Container(
      width: width,
      padding: EdgeInsets.all(8),
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
          Text(text, style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.right,),
          // SizedBox(width:50),
          Expanded(child: 
            Text(param, 
              style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w300, fontFamily: 'Roboto'), 
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,),
          ),
          IconButton(
            icon: Icon(Icons.content_copy, color: Colors.black,),
            color: Colors.black,
            padding: EdgeInsets.all(0),
            iconSize: 22,
            alignment: Alignment.center,
            onPressed: () {
              FlutterClipboardManager.copyToClipBoard(param);
              showSnackBar(param);
            } 
          ) 
        ],
      )
    ));
  }

  Widget showCardSingle(String text, double delay, {double width=375}) {
    return FadeAnimation(delay, Container(
      width: width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
        )]
      ),
      child: Text(text, style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.left,)
    ));
  }

  Widget openWifiSetting() {
    return new Container(
      child: FlatButton(
        onPressed: () {
          OpenSettings.openWIFISetting();
          openWifiTap = true;
          wificount+=1;
          setState(() {
            showSecondStep();
          });
          if (wificount >= 3) {
            getStatus();
          }
        },
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40)
        ),
        child: Container(
          height: 40,
          width: 200,
          // color: Colors.white,
          // margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
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
            child: Text('Open WiFi Settings', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),),
          ),
        ),
      ),
    );
  }

  Widget openMobileSetting() {
    return new Container(
      child: FlatButton(
        onPressed: () {
          OpenSettings.openMobileDataSetting();
          openMobileTap = true;
          wificount+=1;
          setState(() {
            showThirdStep();
          });          
        },
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50)
        ),
        child: Container(
          height: 40,
          width: 230,
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
            child: Text('Open Mobile Data Settings', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget showSecondStep() {
    if (openWifiTap) {
      return new Container(
        child: Column(
          children: <Widget>[
            showCardSingle('2. Turn on Mobile Data to enable network connectivity for the $device device.', 1.2, width: 400),
            SizedBox(height: 10),
            FadeAnimation(1.4, openMobileSetting()) 
          ],
        ),
      );
    } 
    return new Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showThirdStep() {
    if (openMobileTap) {
      return new Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            showCardSingle('3. Turn on a Mobile Hotspot with the following credentials. It is under the WiFi & Internet settings of your settings App.', 1.6, width: 400),
            SizedBox(height: 15),
            showCard('Hotspot Name', device.substring(0,11)+device.substring(14), 1.7),
            SizedBox(height: 15),
            showCard('Password', userid.substring(0,8), 1.8),
            SizedBox(height: 10),
            FadeAnimation(2, openWifiSetting()) 
          ],
        ),
      );
    } 
    return new Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showCardConnection() {
    if (!statusRefreshed || wificount !=3) {
      // print(wificount);
      return new Container(
        height: 0.0,
        width: 0.0,
      );
    }
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
    if (statusRefreshed || wificount == 3) {
      if (status == 'Online') {
        return new Icon(IconsCustom.onlinedevice);        
      }
      else if (status == 'Offline') {
        return new Icon(IconsCustom.offlinedevice); 
      }
    }
    return new Container(
      height: 0.0,
      width: 0.0,
    );
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
