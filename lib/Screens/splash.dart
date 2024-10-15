import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todoist_todo/Screens/todoapp.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  TodoT() ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      backgroundColor: Colors.blueGrey,
      body:  Center(
        child:  Text('Stay organized everyday',style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xffE0F7FA)
        ),),
      ),
    );
  }
}