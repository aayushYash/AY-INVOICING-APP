import 'package:ay_invoiving_app/screens/update_paymentin.dart';
import 'package:ay_invoiving_app/screens/update_paymentout.dart';
import 'package:ay_invoiving_app/screens/update_purchase.dart';
import 'package:ay_invoiving_app/screens/update_sales.dart';
import 'package:flutter/material.dart';


class UpdateViewScreen extends StatelessWidget{


  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          height: 100,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(bottom: 1.5,left: 1.5,right: 1.5),
          child: Card(
            elevation: 5,
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateSales()));
              },
              child:const Center(child:  Text("View Last 15 Sales"))),
          ),
        ),
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(1.5),
          child: Card(
            elevation: 5,
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePurchase()));
              },
              child:const Center(child:  Text("View Last 15 Purchases"))),
          ),
        ),
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(1.5),
          child: Card(
            elevation: 5,
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePaymentIn()));
              },
              child:const Center(child:  Text("View Last 15 Payment-In"))),
          ),
        ),
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(1.5),
          child: Card(
            elevation: 5,
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePaymentOut()));
              },
              child:const Center(child:  Text("View Last 15 Payment-Out"))),
          ),
        )
      ]),
    );
  }

}

