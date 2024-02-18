import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddExpense extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AddExpenseState();
  }
}

class AddExpenseState extends State<AddExpense>{

  DateTime selectedDate = DateTime.now();

  TextEditingController _expenseFor = TextEditingController();
  TextEditingController expenseAmount= TextEditingController();
  TextEditingController description = TextEditingController();


  @override
  Widget build(BuildContext context) {
    String user = context.watch<UserProvider>().userName;
    bool admin = context.watch<UserProvider>().admin;
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: 120,
                height: 50,
                child: InkWell(
                  onTap: () async {
                    DateTime? result = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(3000));
              
                    if(result != null){
                      setState(() {
                        selectedDate = result;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Date"),
                      Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}")
                    ],
                  ),
                ),
              ),),
              TextFormField(
                controller: _expenseFor,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),isDense: true,hintText: 'Expense For'),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 5,),
                          TextFormField(
                controller: expenseAmount,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),isDense: true,hintText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5,),
          
                          TextFormField(
                controller: description,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),isDense: true,hintText: 'Description'),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.amber),
                        child: TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, child: const Text("Cancel",style: TextStyle(color: Colors.black),)),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.amber),
                        child: TextButton(
                          onPressed: (){
                            double expAmount = double.parse(expenseAmount.text);
                            String expFor = _expenseFor.text;
                            DateTime date = DateTime.now();
                            String desc = description.text;

                            List users = ['Aayush', 'Ashok', 'Raj'];

                            if(admin) users.remove(user);
                            
                            FirebaseFirestore.instance.collection('expense').add({
                              'amount': expAmount,
                              'expenseFor': expFor,
                              'date': date,
                              'description': desc,
                              'generatedBy': user,
                            });

                            FirebaseFirestore.instance.collection('log').add({
                              'title': 'Expense',
                              'subTitle': expFor,
                              'time': date,
                              'approved': true,
                              'data': 'Amount: $expAmount | Description: $desc',
                              'notSeen': users,
                              'generatedBy': user,
                            });

                            showDialog(context: context, builder: (context) => AlertDialog(
                              title: const Text('Successfully Added'),
                              actions: [
                                TextButton(onPressed: (){
                                  int i=0;
                                  Navigator.of(context).popUntil((route) => i++>=2);
                                }, child: const Text('Ok'))
                              ],
                            ));
                                    
                        }, child: const Text("Add",style: TextStyle(color: Colors.black),)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

