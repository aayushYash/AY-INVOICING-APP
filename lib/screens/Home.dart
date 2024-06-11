import 'dart:io';
import 'package:ay_invoiving_app/logs.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/report_scree.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  var TileData = [
    {
      'title': 'ADD SALES',
      'color': 0xFF69D757,
      'goto': 'sales',
      'adminOnly': false,
    },
    {
      'title': 'ADD PURCHASE',
      'color': 0xFFF86262,
      'goto': 'addPurchase',
      'adminOnly': false,
    },
    {
      'title': 'PAYMENT-IN',
      'color': 0xFF4A359D,
      'goto': 'paymentIn',
      'adminOnly': false,
    },
    {
      'title': 'PAYMENT-OUT',
      'color': 0xFF14CBB5,
      'goto': 'paymentOut',
      'adminOnly': false,
    },
    
    {
      'title': 'ADD PARTY',
      'color': 0xFFB23DC5,
      'goto': 'addParty',
      'adminOnly': false,
    },
    {
      'title': 'ADD PRODUCT',
      'color': 0xFFFA3F3F,
      'goto': 'addProduct',
      'adminOnly': false,
    },
    {
      'title': 'PARTY LIST',
      'color': 0xFFFFD145,
      'goto': 'partyList',
      'adminOnly': false,
    },
    {
      'title': 'STOCKS',
      'color': 0xFFE87C34,
      'goto': 'stock',
      'adminOnly': false,
    },
    {
      'title': 'ATTENDANCE',
      'color': 0xFF077FFF,
      'goto': 'attendance',
      'adminOnly': false,
    },
    {
      'title': 'EXPENSE',
      'color': 0xFF3FFA87,
      'goto': 'expense',
      'adminOnly': false,
    },
    {
      'title': 'QUOTATION',
      'color': 0xFFA33FFA,
      'goto': 'quotation',
      'adminOnly': false,
    },
    {
      'title': 'PURCHASE ORDER',
      'color': 0xFFFA50B9,
      'goto': 'working',
      'adminOnly': false,
    },
  ];


  

  Home({super.key});
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<UserProvider>().admin;
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [

            Container(
              padding: EdgeInsets.all(12),
              width: MediaQuery.of(context).size.width,child: Text(DateTime.now().hour < 12 ? "Good Morning🌅, ${context.watch<UserProvider>().userName}" : DateTime.now().hour < 17 ? "Good Afternoon🌞, ${context.watch<UserProvider>().userName}" : "Good Evening🌛," " ${context.watch<UserProvider>().userName}", textAlign: TextAlign.left,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
            
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                    itemCount: TileData.length,
                    scrollDirection: Axis.vertical,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemBuilder: (context, index) => GridTile(
                          child: Card(
                            elevation: 5,
                            shadowColor: Color(TileData[index]['color'] as int),
                            color: Color(TileData[index]['color'] as int),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, "/${TileData[index]['goto']}");
                              },
                              child: Center(
                                  child: Text(
                                TileData[index]['title'].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                            ),
                          ),
                        )),
              ),
            )
          ],
        ),
      ),
      extendBody: true,
    );
  }
}
