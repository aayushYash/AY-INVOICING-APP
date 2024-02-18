import 'package:ay_invoiving_app/createItem.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Stock extends StatefulWidget {
  const Stock({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StockState();
  }
}
double pakkaStock = 0, actualStock = 0;
class _StockState extends State<Stock> {
  // firebase
  fetchStock() {
    return FirebaseFirestore.instance.collection('product').snapshots();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('STOCK'),
        elevation: 2,
      ),
      body: StreamBuilder<Object>(
          stream: fetchStock(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data.docs.length == 0){
                return const Center(child: Text("No data to show"),);
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: snapshot.data.docs
                        .map<Widget>((doc)  {

                          var incomplete = doc['hsn'].isEmpty;

                          return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          width: double.infinity,
                          child: Card(
                            elevation: 2,
                            color: incomplete ? const Color.fromARGB(255, 251, 149, 149) : Colors.white,
                            child: InkWell(
                            
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewItem(data: doc.data(), edit: true)));
                              },
                              child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc['itemName'],
                                          style: const TextStyle(
                                            
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("HSN: ${doc['hsn']}"),
                                            Text('Unit : ${doc['unit']}'),
                                            Text("₹${NumberFormat("##,##,##0.00").format(double.parse(doc['rate'].toString()))}",),
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        );
            })
                        .toList(),
                  ),
                ),
              );
            }
            return Loading();
          }),
      
      persistentFooterButtons: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(25)
          ),
          child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const NewItem(data: {},edit: false)));
              },
              icon: const Icon(Icons.add,color: Colors.white,)),
        )
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}
