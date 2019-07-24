import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyHomePage());

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Declaramos variables
  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';

  //Instanciamos firebase messanging
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  //Instanciamos flutter local notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  //Cuando cargue la aplicacion es lo primero que inicie
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    // va a comprobar la aplicacion la plataforma
    var platform = InitializationSettings(android,ios);
    //Pasamos algunos atributos a firebase messanging
    flutterLocalNotificationPlugin.initialize(platform);
    //Mapeo de los mensajes recibidos desde firebase
    firebaseMessaging.configure(onLaunch: (Map<String,dynamic> msg){
      //Uso de notificaciones de permisos
      print("onLaunch called ${(msg)}");
    },
    onResume: (Map<String,dynamic> msg){
      print("onResume called ${(msg)}");
    },
    onMessage: (Map<String,dynamic> msg){
      print("onMessage called ${(msg)}");
      //Termina el mapeo del mensaje
      mymap=msg;
      showNotification(msg);
    }
    );
    //Notificaciones de permisos para iOS
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound:true,alert: true,badge: true)
    );
    //Esas configuraciones los almacene el dispositivo ios
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting){
      print("onIosSettingRegistered");
    });
    //Uso del token
    firebaseMessaging.getToken().then((token){
      update(token);
    });
  }
  showNotification(Map<String,dynamic> msg) async{
    var android = AndroidNotificationDetails('1','channeIName','channeIDescription');
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android,ios);

    //Le pasamos una llave y un valor
    //Titulo del mensaje y el cuerpo
    msg.forEach((k,v){
      title = k;
      body=v;
      setState(() {});
      
    });
    await flutterLocalNotificationPlugin.show(0,"${body.keys}","${body.values}",platform);
  }
  // fcm token firebase cloud messaging
  //referenciar el token
  update(String token){
    print(token);
    //Referenciar la base de datos
    DatabaseReference databaseReference = FirebaseDatabase().reference();
    //Referenciar a la tabla
    databaseReference.child('fcm-token/$token').set({"token":token});
    mytoken = token;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Messaging App"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'My Messaging'
              ),
              Text(
                '$mytoken',
                style: TextStyle(fontSize: 15.0,color: Colors.blueAccent),
              )
            ],
          ),
        ),
      ),
    );
  }
}
