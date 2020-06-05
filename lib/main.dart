import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      debugShowCheckedModeBanner: false,
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
  String key = "villes";
  List<String> villes = [];
  String villeChoisit;

  @override
  void initState(){
     super.initState();
     obtenir();
  }

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
              itemCount: villes.length + 2,
              itemBuilder: (context, i){
                if(i == 0){
                  return DrawerHeader(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        texteAvecStyle("Mes villes", fontsize: 22.0),
                        new RaisedButton(
                          color: Colors.white,
                          elevation: 8.0,
                          child: texteAvecStyle("Ajouter une ville", color: Colors.blue),
                          onPressed: ajouterVille
                        )
                      ],
                    ),
                  );
                } else if(i == 1){
                  return new ListTile(
                    title: texteAvecStyle("Ma ville actuelle", ),
                    onTap: (){
                      setState(() {
                        villeChoisit = null;
                        Navigator.pop(context);
                      });
                    },
                  );
                } else {
                  String ville= villes[i - 2];
                 return new ListTile(
                     title: texteAvecStyle(ville),
                     onTap: (){
                       setState(() {
                         villeChoisit = ville;
                         Navigator.pop(context);
                       });
                     }
                 );
               }

              }
          ),
          color: Colors.blue,
        ),
      ),
      body: new Center(
          child: new Text(
              (villeChoisit == null) ? "Ville actuelle": villeChoisit,
            style: new TextStyle(color: Colors.black),
          ),
      ),
    );
  }

  
  // Function Text personnalité
  Text texteAvecStyle(String data, {color: Colors.white, fontsize: 20.0, fontStyle: FontStyle.italic,}){
    return new Text(
        data,
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: color,
          fontSize: fontsize,
          fontStyle: fontStyle,
        ),
    );
  }
  
  // Function simple dialog

Future<Null> ajouterVille() async {
    return showDialog(
       barrierDismissible: true,
       context: context,
       builder: (BuildContext buildcontext) {
          return new SimpleDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: texteAvecStyle("Ajouter une ville", fontsize: 22.0, color: Colors.blue),
            children: <Widget>[
              new TextField(
                decoration: new InputDecoration(labelText: "ville"),
                onSubmitted: (String str) {
                  Navigator.pop(buildcontext);
                },
              ),
            ],
          );
       }
    );
}

//Creation d'une function pour mes share preferenece

void obtenir() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> liste = await sharedPreferences.getStringList(key);
    if(liste != null){
      setState(() {
        villes = liste;
      });
    }

}
  
  
}
