import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WorkingOnIt extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(children: [
        SizedBox(
          height: 200,
          child: Lottie.asset("assets/workingonit.mp4",height: 200,width: 200,fit: BoxFit.contain)),
        Text("Working On It!")
      ],)),
    );
  }
}