import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WorkingOnIt extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        SizedBox(
          height: 200,
          child: Lottie.asset("assets/working2.json",height: 200,width: 200,fit: BoxFit.contain)),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Working On It!\nReturn 🔙",style: TextStyle(fontSize: 18, color: Colors.blueAccent),)
          ),
      ],)),
    );
  }
}