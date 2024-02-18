import 'package:ay_invoiving_app/createParty.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/screens/PartyTransactionList.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class PartyList extends StatefulWidget{
  const PartyList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PartyListState();
  }
}


class _PartyListState extends State<PartyList>{


  final SearchController _searchParty = SearchController();
  String _partyToSearch = "";
  double balance=0;
  String lastSaleDate = '',lastPaymentDate = '';
  List dataTransaction = [];
  double lastSaleValue = 0,lastPaymentValue = 0;
  bool admin = false;
  int state = 0;

  @override
  Widget build(BuildContext context) {
    if(state == 0){
      setState(() {
        admin = context.watch<UserProvider>().admin;
      });
    }
  
    return Scaffold(
      appBar: AppBar(title: const Text('Parties'),),
      body: StreamBuilder<Object>(
        stream: _partyToSearch == "" ? FirebaseFirestore.instance.collection('party').snapshots() : FirebaseFirestore.instance.collection('party').where('partyName', isGreaterThanOrEqualTo: _partyToSearch,isLessThan: '${_partyToSearch}z').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          
          if(snapshot.hasData){
            if(snapshot.data.docs.isEmpty) {
              
              return Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 15),
                  child: SearchBar(
                    elevation: MaterialStateProperty.all(3),
                    hintText: 'Search Party',
                    hintStyle: MaterialStateProperty.all(const TextStyle(color: Colors.grey, fontWeight: FontWeight.w200,)),
                    controller: _searchParty,
                    trailing: [
                      TextButton(onPressed: (){
                        setState(() {
                          _partyToSearch = _searchParty.text.toUpperCase();
                        });
                      }, child: const Text("Search")),
                      _partyToSearch.isNotEmpty ? IconButton(onPressed: (){
                        setState(() {
                          _searchParty.clear();
                          _partyToSearch = "";
                        });
                      }, icon: const Icon(Icons.restart_alt_rounded,color: Colors.amber,)) :  const Text(''),
                    ],
                  
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Center(child: Text("No Result to show"),)
                  ]
                  ),
              ],
            );
            }
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 15),
                  child: SearchBar(
                    elevation: MaterialStateProperty.all(3),
                    hintText: 'Search Party',
                    hintStyle: MaterialStateProperty.all(const TextStyle(color: Colors.grey, fontWeight: FontWeight.w200,)),
                    controller: _searchParty,
                    trailing: [
                      TextButton(onPressed: (){
                        setState(() {
                          _partyToSearch = _searchParty.text.toUpperCase();
                        });
                      }, child: const Text("Search")),
                      _partyToSearch.isNotEmpty ? IconButton(onPressed: (){
                        setState(() {
                          _searchParty.clear();
                          _partyToSearch = "";
                        });
                      }, icon: const Icon(Icons.restart_alt_rounded,color: Colors.amber,)) :  const Text(''),
                    ],
                  
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data.docs.map<Widget>((party){
                      Map<String,dynamic> data = party.data();
                      balance = 0;
                      lastPaymentDate = "";
                      lastSaleDate = "";
                      lastSaleValue = 0;
                      lastPaymentValue = 0;
                      dataTransaction = data['transactions'];
                      dataTransaction.sort((a, b) => a['time'].toDate().compareTo(b['time'].toDate()));


                      dataTransaction.forEach((transaction){
                        DateTime transactionTime = transaction['time'].toDate();
                        if(transaction['type'] == 'sale') {
                          lastSaleValue = double.parse(transaction['amount'].toString());
                          lastSaleDate = "${transactionTime.day}/${transactionTime.month}/${transactionTime.year}";
                          balance -= double.parse(transaction['amount'].toString());
                        }
                        if(transaction['type'] == 'purchase') balance += double.parse(transaction['amount'].toString());
                        if(transaction['type'] == 'paymentin') {
                          lastPaymentDate = "${transactionTime.day}/${transactionTime.month}/${transactionTime.year}";
                          lastPaymentValue = double.parse(transaction['amount'].toString());
                          balance += double.parse(transaction['amount'].toString());
                        }
                        if(transaction['type'] == 'paymentout') balance -= double.parse(transaction['amount'].toString());
                      });
                      return Card(
                        elevation: 5,
                        child: InkWell(
                          onTap: (){
                            admin ? Navigator.push(context, MaterialPageRoute(builder: (context) => PartyTransactionList(data))) : null;
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [

                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(party['partyName'],style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold,),),),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text("GSTIN: ${party['gstin'].toString()}"),
                                    if(admin) Text("Bal: ₹${NumberFormat("##,##,#00.00").format(balance.abs())}",style: TextStyle(color: balance < 0 ? Colors.green : Colors.red),)
                                  ],
                                  
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Last Sale: $lastSaleDate| ₹${NumberFormat("##,##,#00.00").format(lastSaleValue)}"),
                                            Text("Last Payment $lastPaymentDate| ₹${NumberFormat("##,##,#00.00").format(lastPaymentValue)}")
                                          ],
                                        ),
                                        IconButton(onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => NewParty(data: data,edit: true,)));
                                            }, icon: const Icon(Icons.edit,size: 16,)),
                                      ],
                                    ),
                                  ),
                                  
                                 
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()
                    ),
                ),
              ],
            ),
            );
          }
          return Loading();
          
        }
      ),
    );
  }
}