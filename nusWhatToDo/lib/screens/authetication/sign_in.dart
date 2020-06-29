import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:orbital/screens/home/home.dart';
import 'package:orbital/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital/screens/authetication/sign_up.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(
          'Welcome!',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset("images/logo.png", fit: BoxFit.fill)),
              SizedBox(height: 30),
              TextFormField(
                validator: (input) {
                  if (input.isEmpty) {
                    return 'Provide an email';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    icon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                onSaved: (input) => _email = input,
              ),
              TextFormField(
                validator: (input) {
                  if (input.isEmpty) {
                    return 'Provide a password';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.vpn_key),
                ),
                onSaved: (input) => _password = input,
                obscureText: true,
              ),
              SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: _signIn,
                child: Text('Log in'),
              ),
              SizedBox(height: 30),
              CupertinoButton.filled(
                  onPressed: navigateToSignUp, child: Text('Sign Up')),
            ],
          )),
    );
  }

  void navigateToSignUp() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpPage(), fullscreenDialog: true));
  }

  void _signIn() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushNamed(context, '/explore');
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  content: Text('Incorrect email or password. \nTry again.'),
                  actions: <Widget>[
                    FlatButton(
                        child: Text('OK'),
                        onPressed: () =>
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (Route<dynamic> route) => false);
                            }))
                  ]);
            });
      }
    }
  }
}