import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Coda meteo'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<String> villes = ["Paris", "Bordeaux", "Marseilles"];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: new Container(
          child: new ListView.builder(
              itemCount: villes.length,
              itemBuilder: (context, i){
                  return new ListTile(
                    title: new Text(villes[i]),
                  );
              }
          ),
          color: Colors.blue,
        ),
      ),
      body: new Center(

      ),
    );
  }
}
