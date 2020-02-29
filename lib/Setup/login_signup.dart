import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pollutector_app_v1/Services/authentication.dart';
import 'Animation/FadeAnimation.dart';

var headingtext = new RichText(
  text: new TextSpan(
    style: new TextStyle(
      fontSize: 14,
      color: Colors.white,
    ),
    children: <TextSpan>[
      new TextSpan(text: 'App of the real time air quality detector '),
      new TextSpan(text: 'Pollutector', style: new TextStyle(fontWeight: FontWeight.bold)),
    ],
  ),
);

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      // _isLoading = true;
    });
    if (validateAndSave()) {
      _isLoading = true;
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          // widget.auth.sendEmailVerification();
          // _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _isLoginForm) {
          widget.loginCallback();
        }
      } catch (error) {
        print('Error: $error');
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new Scaffold(
        body: Stack(
          children: <Widget>[
            _showColor(),
            _showCircularProgress(),
          ],
        ),
    );
  }

  Widget _showColor() {
    return new Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.red[900],
              // Colors.blue[800],
              Colors.blue[800],
              Colors.blue[500],
            ]
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeAnimation(1, Text("Hi there,", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),)),
                  SizedBox(height: 5,),
                  FadeAnimation(1.1, Text("Welcome to the Pollutector App.", style: TextStyle(color: Colors.white, fontSize: 15),)),
                  SizedBox(height: 5,),
                  FadeAnimation(1.2, headingtext),
                  SizedBox(height: 10,),
                ],
              ),
            ),
            Expanded(child: _showWhite())
          ],
      )
    );
  }

  Widget _showWhite() {
    return new Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            SizedBox(height: 15,),
            FadeAnimation(1.3, Container(
              width: 350,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(
                  color: Color.fromRGBO(2, 55, 227, 0.5),
                  blurRadius: 20,
                  offset: Offset(0, 10)
                )]
              ),
              child: Column(
                children: <Widget>[
                  // FadeAnimation(1.1, Text("Enter the credentials provided.", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),)),
                  _showForm()],
              )
            )),
            showOtherSignin(),
            FadeAnimation(1.8, showSecondaryButton()),
          ],
        ),
      ),
    );
  }

  Widget showOtherSignin() {
    return new Container(
      // width: double.infinity,
      child: Column(
        children: <Widget>[      
          SizedBox(height: 10,),
          FadeAnimation(1.3, showForgotPasswordButton()),
          SizedBox(height: 10,),
          FadeAnimation(1.4, Container(
            child: FlatButton(
              onPressed: validateAndSubmit,
              padding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)
              ),
              child: Container(
                height: 50,
                width: 250,
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
                  child: Text(_isLoginForm ? 'Login' : 'Create an account', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
                ),
              ),
            ),
          )),
          SizedBox(height: 30,),
          FadeAnimation(1.5, Text("or Continue with Social Media.", style: TextStyle(color: Colors.black),)),
          SizedBox(height: 25,),
          Row(
            children: <Widget>[
              Expanded(
                child: FadeAnimation(1.6, Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color.fromRGBO(59, 89, 152, 1),
                    boxShadow: [BoxShadow(
                      color: Color.fromRGBO(59, 89, 152, 0.5),
                      blurRadius: 20,
                      offset: Offset(0, 10)
                    )],
                  ),
                  child: Center(
                    child: Text("Facebook", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                  ),
                )),
              ),
              SizedBox(width: 30,),
              Expanded(
                child: FadeAnimation(1.6, Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color.fromRGBO(222, 82, 70, 1),
                    boxShadow: [BoxShadow(
                      color: Color.fromRGBO(222, 82, 70, 0.5),
                      blurRadius: 20,
                      offset: Offset(0, 10)
                    )],
                  ),
                  child: Center(
                    child: Text("Google", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                  ),
                )),
              ),
            ],
          ),
          SizedBox(height: 10,),
        ],
      )
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
        onPressed: toggleFormMode);
  }

  Widget showForgotPasswordButton() {
    return new FlatButton(
        child: new Text(
            'Forgot Password again? Tap me',
            style: new TextStyle(color: Colors.black),),
        onPressed: () {});
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showEmailInput(),
              showPasswordInput(),
              showErrorMessage(),
            ],
          ),
        )
    );
  }

}