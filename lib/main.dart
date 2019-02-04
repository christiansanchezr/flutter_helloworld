import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'package:apphello/home.dart';

void main() => runApp(MyApp());

ThemeData buildTheme() {
  final ThemeData base = ThemeData();
  return base.copyWith(
    hintColor: Colors.deepPurple,
    primaryColor: Colors.white,
    textSelectionColor: Colors.black,
    accentColor: Colors.black, 
    inputDecorationTheme: InputDecorationTheme(
      
      hintStyle: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.6),
      ),
      labelStyle: TextStyle(
        color: Colors.white,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white)
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white)
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white)
      ),
      fillColor: Colors.white,
    ),
  );
}

class MyApp extends StatelessWidget {



   _loadData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
   }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildTheme(),
      home: (_loadData("usrtkn") == 0? Home(): Login()),
      debugShowCheckedModeBanner: true,
    );
  }
}


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  _saveData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, 1);
   }
  

  int usrtkn;

  var _loading = false;

  var _btnIndicator = SizedBox(width: 16.0, height: 16.0, child: CircularProgressIndicator(),);
  var _btnChild = Text("Iniciar sesion");

  Future<dynamic> post(String url,var body)async{

    if (body['username'] != '' && body['password'] != '') {
    setState(() {
          _loading = true;
        });
    return await http
      .post(Uri.encodeFull(url), body: body, headers: {"Accept":"application/json"})
      .then((http.Response response) {
        final int statusCode = response.statusCode;
        setState(() {
          _loading = false;
        });
        print(response.statusCode);
        if (statusCode < 200 || statusCode > 400) {
          print(statusCode); 
        } else if (statusCode == 200) {     
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          return print((response.body).toString());
        } else if (statusCode == 400) {
          _alert(Text("El usuario o contrasena son incorrectos"));
        }
      })
      .catchError((err) {
        setState(() {
          _loading = false;
        });
        print("ERROR" + err);
        _alert(Text("HUbo un error al conectar con el servidor"));
      });
    }
  }

    void _alert(content) {
    AlertDialog alerta = AlertDialog(
      content: content,
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        )
      ],
    );

    showDialog(context: context, builder: (BuildContext context) => alerta);
  }

  String username = "";
  String password = "";

  void _usernameValue(String val) {
    setState(() {
          username = val;
        });
  }

  void _passwordValue(String val) {
    setState(() {
          password = val;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        padding: EdgeInsets.only(left: 32.0, right: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Iniciar sesion", style: TextStyle(fontSize: 32.0, color: Colors.white),),
            Padding(
              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Ingresa tu username",
                labelText: "Username",
                prefixIcon: Icon(
                  Icons.person
                )
              ),
              style: new TextStyle(color: Colors.white),
              onChanged: ((val) => _usernameValue(val)),
            ),
            Padding(padding: EdgeInsets.only(bottom: 12.0, top: 12.0),),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Ingresa tu password",
                prefixIcon: Icon(
                  Icons.lock
                ),
                labelText: "Password",
              ),
              style: new TextStyle(color: Colors.white),
              onChanged: ((val) => _passwordValue(val)),
              
            ),
            Padding(padding: EdgeInsets.only(top: 12.0),),
            RaisedButton(
              child: (_loading) ? _btnIndicator : _btnChild,
              onPressed: () => (_loading) ? null : post("http://18.213.31.247:8000/api-auth/", {'username': username, 'password': password}),
            ),
          ],
        ),
      ),
    );
  }
}