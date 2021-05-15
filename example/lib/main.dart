import 'dart:math';

import 'package:flutter/material.dart';
import 'package:animated_rail/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  Widget _buildTest(String title) {
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

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: AnimatedRail(
          activeColor: Colors.purple,
          background: hexToColor('#8B77DD'),
          maxWidth: 300,
          width: 120,
          iconBackground: Colors.transparent,
          items: [
            RailItem(
                icon: Icon(Icons.home),
                label: 'Home',
                screen: _buildTest('Home')),
            RailItem(
                icon: Icon(Icons.message_outlined),
                label: 'Messages',
                screen: _buildTest('Messages')),
            RailItem(
                icon: Icon(Icons.notifications),
                label: 'Notification',
                screen: _buildTest('Notification')),
            RailItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                screen: _buildTest('Profile')),
            RailItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                screen: _buildTest('Profile')),
            RailItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                screen: _buildTest('Profile')),
            RailItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                screen: _buildTest('Profile')),
          ],
        ),
      ),
    );
  }
}
