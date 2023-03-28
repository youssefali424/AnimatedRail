import 'dart:math';

import 'package:flutter/material.dart';
import 'package:animated_rail/animated_rail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTest(String title) {
    return Container(
      color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NewCustomizations()));
                },
                child: Text('new customizations')),
          ],
        ),
      ),
    );
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: AnimatedRail(
        background: hexToColor('#8B77DD'),
        maxWidth: 275,
        width: 100,
        railTileConfig: RailTileConfig(
          iconSize: 30,
          iconColor: Colors.black,
          expandedTextStyle: TextStyle(fontSize: 20),
          collapsedTextStyle: TextStyle(fontSize: 12),
          activeColor: Colors.purple,
          iconBackground: Colors.white,
        ),
        items: [
          RailItem(
              icon: Icon(Icons.home),
              label: "Home",
              screen: _buildTest('Home')),
          RailItem(
              icon: Icon(Icons.message_outlined),
              label: 'Messages',
              screen: _buildTest('Messages')),
          RailItem(
              icon: Icon(Icons.notifications),
              label: "Notification",
              screen: _buildTest('Notification')),
          RailItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              screen: _buildTest('Profile')),
        ],
      )),
    );
  }
}

class NewCustomizations extends StatelessWidget {
  const NewCustomizations({Key? key}) : super(key: key);
  Widget _buildScreen(String title) {
    return Container(
      color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 40, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(),
        Expanded(
          child: AnimatedRail(
            background: Colors.indigo[300],
            maxWidth: 175,
            width: 60,
            railTileConfig: RailTileConfig(
              iconSize: 22,
              iconColor: Colors.white,
              expandedTextStyle: TextStyle(fontSize: 15),
              collapsedTextStyle: TextStyle(fontSize: 12, color: Colors.white),
              activeColor: Colors.indigo,
              iconPadding: EdgeInsets.symmetric(vertical: 5),
              hideCollapsedText: true,
            ),
            cursorSize: Size(70, 70),
            cursorActionType: CursorActionTrigger.clickAndDrag,
            items: [
              RailItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                  screen: _buildScreen('Home')),
              RailItem(
                  icon: Icon(Icons.message_outlined),
                  label: 'Messages',
                  screen: _buildScreen('Messages')),
              RailItem(
                  icon: Icon(Icons.notifications),
                  label: "Notification",
                  screen: _buildScreen('Notification')),
              RailItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                  screen: _buildScreen('Profile')),
            ],
          ),
        ),
      ],
    );
  }
}
