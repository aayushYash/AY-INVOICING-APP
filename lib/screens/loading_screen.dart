import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
          Lottie.asset("assets/loading.json",height: 400,width: 400,fit: BoxFit.contain),
          Text('Loading...')
        ]),
      ),
    );
  }
}