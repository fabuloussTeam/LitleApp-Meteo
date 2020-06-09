class Temps {
  String message;
  String name;
  String main;
  String description;
  String icon;
  var temp;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;


  Temps();

  void fromJSON(Map map){

    this.message = map["message"];


    // Notre objet contient une List "list:" qui contien
    // un seul objet, et cet objet contient l'objet "main" et une List "weather"
    List list = map["list"];
    Map mapList = list[0];

    this.name = mapList["name"];

    Map main = mapList["main"];
    this.temp = main["temp"];
    this.pressure = main["pressure"];
    this.humidity = main["humidity"];
    this.temp_min = main["temp_min"];
    this.temp_max = main["temp_max"];

    List weather = mapList["weather"];
    Map mapWeather = weather[0];
    this.main = mapWeather["main"];
    this.description = mapWeather["description"];
    this.icon = mapWeather["icon"];

   /* String monIcone = mapWeather["icon"];
   // print(monIcone);
    this.icon = "assets/${monIcone.replaceAll("d", "").replaceAll("n", "")}.j";*/
  }
}