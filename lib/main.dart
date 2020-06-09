import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'temps.dart';
import 'package:codameteo/my_flutter_app_icons.dart';


void main() async{
  runApp(MyApp());
}

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
  String ville_du_client = "";

  Temps tempActuelle;


  @override
  void initState(){
     super.initState();
     obtenir();
     _currentPositionLocator();
    // appelApi();
  }

  void _currentPositionLocator() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    try {
      /* recuperation des coordonnées */
      /* convertion des coordonnées en address complete avec Geocoder */
      if (position != null) {
        final coordinates = new Coordinates(position.latitude, position.longitude);
        var adresse = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = adresse.first;
        //on a "mountain view" prck nous sommes sur un emulateur android. sur IOS c'est: cupertino
        setState(() {
           ville_du_client = first.locality;
         // print(ville_du_client);
          appelApi();
        });
      }
    } on PlatformException catch (e) {}
  }

  // Convertion de la ville du client en coordonnées
  void appelApi() async {
    String str;
    if(villeChoisit == null){
      str = ville_du_client;
    } else {
      str = villeChoisit;
    }
   List<Address> coord = await Geocoder.local.findAddressesFromQuery(str);
    print(coord);
    if (coord != null) {
    //  coord.forEach((Address) => print(Address.coordinates));
      final lat = coord.first.coordinates.latitude;
      final lon = coord.first.coordinates.longitude;
      String lang = Localizations.localeOf(context).languageCode;
      final key = "709bce50b88ae968ef15626b9e4a2007";

      String urlApi = "http://api.openweathermap.org/data/2.5/find?lat=$lat&lon=$lon&lang=$lang&units=metric&appid=$key";

      final response = await http.get(urlApi);
      if(response.statusCode == 200){
         print(response.body);
         Temps temps = new Temps();
         Map map = jsonDecode(response.body);
          temps.fromJSON(map);
         //print(mapdecode);
      /*   print(temps.message);
         print(temps.name);
         print(temps.temp);
         print(temps.humidity);
         print(temps.temp_min);
         print(temps.temp_max);
         print(temps.main);
         print(temps.description);
         print(temps.icon);*/

          setState(() {
           tempActuelle = temps;
           print(tempActuelle.name);
         });
      }
    }
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
                          onPressed: dialogAjouterVille
                        ),
                      ],
                    ),
                  );
                } else if(i == 1){
                  return new ListTile(
                    title: texteAvecStyle(ville_du_client),
                    onTap: (){
                      setState(() {
                        villeChoisit =  null;
                        appelApi();
                        Navigator.pop(context);
                      });
                    },
                  );
                } else {
                  String ville= villes[i-2];
                 return new ListTile(
                     title: texteAvecStyle(ville),
                     trailing: new IconButton(
                         icon: new Icon(Icons.delete, color: Colors.white),
                         onPressed: (() => supprimer(ville))
                     ),
                     onTap: (){
                       setState(() {
                         villeChoisit = ville;
                         appelApi();
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
      body: (tempActuelle == null)
      ? new Center(
          child: new Text(
              (villeChoisit == null) ? ville_du_client : villeChoisit,
            style: new TextStyle(color: Colors.black),
          ),
      ) : new Container(
         width: MediaQuery.of(context).size.width,
         height: MediaQuery.of(context).size.height,
         decoration: new BoxDecoration(
           image: new DecorationImage(
               image: new AssetImage(assetName()),
               fit: BoxFit.cover
           ),
         ),
        padding: EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            texteAvecStyle(tempActuelle.name),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                texteAvecStyle("${tempActuelle.temp.toInt()} °C", fontsize: 50.0),
                new Image.asset(assetIcon(), width: 100,)
              ],
            ),
            texteAvecStyle(tempActuelle.main),
            texteAvecStyle(tempActuelle.description),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Icon(MyFlutterApp.temperatire, color: Colors.white, size: 30.0),
                    texteAvecStyle("${tempActuelle.pressure}", fontsize: 20.0)
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new Icon(MyFlutterApp.up_big, color: Colors.white, size: 30.0),
                    texteAvecStyle("${tempActuelle.temp_max}", fontsize: 20.0)
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new Icon(MyFlutterApp.down_big, color: Colors.white, size: 30.0),
                    texteAvecStyle("${tempActuelle.temp_min}", fontsize: 20.0)
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new Icon(MyFlutterApp.water, color: Colors.white, size: 30.0),
                    texteAvecStyle("${tempActuelle.humidity}", fontsize: 20.0)
                  ],
                )
              ],
            )
          ],
        ),
      )
    );
  }
  
  String assetName(){
    if(tempActuelle.icon.contains("n")){
      print(tempActuelle.icon);
      return "assets/04.jpg";
    } else {
      if (tempActuelle.icon.contains("01") || tempActuelle.icon.contains("02") || tempActuelle.icon.contains("03") ) {
        print(tempActuelle.icon);
        return "assets/02.jpg";
      } else {
        print(tempActuelle.icon);
        return "assets/03.jpg";
      }
    }
  }

  String assetIcon() {
    if(tempActuelle.icon.contains("n") || tempActuelle.icon.contains("01n") || tempActuelle.icon.contains("02n")){
      print(tempActuelle.icon);
      return "assets/windy.png";
    } else {
      if (tempActuelle.icon.contains("01") || tempActuelle.icon.contains("02") || tempActuelle.icon.contains("03") ) {
        print(tempActuelle.icon);
        return "assets/rain.png";
      } else {
        print(tempActuelle.icon);
        return "assets/sun.png";
      }
    }
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

Future<Null> dialogAjouterVille() async {
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
                  ajouter(str);
                  Navigator.pop(buildcontext);
                },
              ),
            ],
          );
       }
    );
}

//Creation d'une function pour mes share preferenece associer a la liste villes
void obtenir() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> liste = await sharedPreferences.getStringList(key);
    if(liste != null){
      setState(() {
        villes = liste;
      });
    }
}

// Function d'ajout d'une ville dans la liste villes et persistence avec sharepreference
void ajouter(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.add(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
}

// Fonction de suppression d'une ville dans la liste villes
void supprimer(String str) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.remove(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
}

  
  
}
