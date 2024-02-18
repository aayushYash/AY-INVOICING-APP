import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/screens/add_expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';


class Expense extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ExpenseState();
  }
}

final months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

class ExpenseState extends State<Expense>{
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userName;
    final admin = context.watch<UserProvider>().admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      body: StreamBuilder(
        stream: admin ? FirebaseFirestore.instance.collection('expense').snapshots() : FirebaseFirestore.instance.collection('expense').where('generatedBy',isEqualTo: user).snapshots(),
        builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            if(snapshot.data.docs.isEmpty){
              return const Center(child: Text("No Expenses!"),);
            }
            return ListView(children: snapshot.data.docs.map<Widget>((exp){
                    DateTime date = exp['date'].toDate();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                      child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        width: double.infinity,
                        height: 75,
                        child:
                      Row(
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          Text(date.day.toString()),
                          Text(months[date.month-1]),
                          Text(date.year.toString())
                        ],),
                        const SizedBox(width: 15,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(exp['expenseFor'].toString().trim(),style: const TextStyle(fontWeight: FontWeight.bold),),
                            Text(exp['description'].toString().trim()),
                            Text(NumberFormat("₹##,##,##0.00").format(exp['amount']))
                          ],),
                        )
                      ],)
                      ),
                    ));
                  }).toList());
                
              
            
          }
          return Loading(); 
        },

      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpense()));
      },child: const Icon(Icons.add),),
    );
  }
}