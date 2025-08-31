import 'dart:io';

import 'package:ay_invoiving_app/logs.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/report_scree.dart';
import 'package:ay_invoiving_app/screens/Home.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:ay_invoiving_app/screens/update_view_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';


class TopNavigator extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
  bool admin =context.watch<UserProvider>().admin;
    return WillPopScope(child: DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: StreamBuilder<Object>(
        stream: FirebaseFirestore.instance.collection('log').where('notSeen', arrayContains: context.watch<UserProvider>().userName).snapshots(),
        builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            int unread = snapshot.data.docs.length;
            return Scaffold(
            appBar: AppBar(title: const Text('AY Invoicing App'), bottom: TabBar(tabs: [
              const Tab(icon: Icon(Icons.dashboard,),text: 'Dashboard'),
              if(admin)const Tab(icon: FaIcon(FontAwesomeIcons.receipt),text: 'Reports',),
              if(admin)Tab(icon: unread != 0  ? Badge(label: Text("$unread"), child: const FaIcon(FontAwesomeIcons.message),): const FaIcon(FontAwesomeIcons.message), text: 'Logs',),
              const Tab(icon: FaIcon(FontAwesomeIcons.list),text: 'View',),
            ]), 
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: (){
                    FirebaseAuth.instance.signOut();
                  },
                  child: const Icon(Icons.logout)),
              )
            ],
            leading: const Icon(Icons.home), ),
            body: TabBarView(children: [
              Home(),
              Report(),
              Logs(),
              UpdateViewScreen()
            ]),
          );
          }
        return Loading();
        }
        
      ),
      
      
      ), onWillPop: (){
        exit(0);
      });
  }
}