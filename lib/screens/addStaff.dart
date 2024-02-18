import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStaff extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AddStaffState();
  }
}

class AddStaffState extends State<AddStaff>{
  TextEditingController staffName = TextEditingController();
  TextEditingController salary = TextEditingController();
  TextEditingController openingBalance = TextEditingController();
  bool dailyBasis = false;
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userName;
    final admin = context.watch<UserProvider>().admin;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Staff"),
      ),
      body: Padding(padding: const EdgeInsets.all(8),child: Column(children: [
      TextFormField(
        controller: staffName,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),labelText: 'Staff Name',isDense: true),
      ),
      const SizedBox(height: 6,),
      Row(children: [
        Expanded(child: TextFormField(
          
          controller: salary,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),isDense: true,labelText: 'Salary'),
        )),
        const SizedBox(width: 6,),
        InputChip(
          selectedColor: Colors.amber,
          label: const Text('Daily Basis'),selected: dailyBasis,onSelected: (value) => setState(() {
          dailyBasis = value;
        }),)
      ],),
      const SizedBox(height: 6,),
      TextFormField(
        controller: openingBalance,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),labelText: 'Opening Balance',isDense: true),
      ),
      ]),),
      persistentFooterButtons: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Container(
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Cancel",style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
          ),)),
        TextButton(onPressed: (){
          List users = ['Aayush','Raj','Ashok'];
          if(admin) users.remove(user);
          String name = staffName.text;
          double sal = double.parse(salary.text);
          bool dailybasis = dailyBasis;
          double openingbalance = double.parse(openingBalance.text);
          FirebaseFirestore.instance.collection('staff').doc(name).set({
            'name': name,
            'salary': sal,
            'dailyBasis': dailybasis,
            'openingBalance': openingbalance,
            'today': DateTime(2000),
            'payments': []
          }).then((value){
            FirebaseFirestore.instance.collection('log').add({
              'title': 'Staff Added',
              'subTitle': name,
              'time': DateTime.now(),
              'approved': true,
              'data': "Openning Balance: $openingbalance",
              'notSeen': users,
              'generatedBy': user,
            });
          });

        }, child: Container(
          width: 120,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.amber),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Add",style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
          )))
      ],
    );
  }
}