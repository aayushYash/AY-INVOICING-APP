import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../sales.dart';

class UpdateSales extends StatefulWidget {
  State createState() {
    return UpdateSalesState();
  }
}

List months = [
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

class UpdateSalesState extends State<UpdateSales> {

  build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text("Last 15 Sales")),
      body: StreamBuilder(
        stream: context.watch<UserProvider>().admin ? FirebaseFirestore.instance
            .collection('sales')
            .orderBy('timestamp', descending: true)
            .limit(15)
            .snapshots(): FirebaseFirestore.instance
            .collection('sales')
            .where('generatedBy',
                isEqualTo: context.watch<UserProvider>().userName)
            .orderBy('timestamp', descending: true)
            .limit(15)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.isNotEmpty) {

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                  child: Column(
                      children: snapshot.data.docs.map<Widget>((sale) {
                    DateTime saleInvoiceDate = sale['invoiceDate'].toDate();
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SalesWidget(edit: true,view: false,data: sale.data() ,)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${saleInvoiceDate.day}\n${months[saleInvoiceDate.month - 1]}\n${saleInvoiceDate.year}",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sale['invoiceNumber'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            sale['customerName'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                    NumberFormat("₹ ##,##,#00.##").format(
                                        double.parse(
                                            sale['invoiceAmount'].toString())),
                                    textAlign: TextAlign.right,
                                  )
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                ]),
                          ),
                        ),
                      ),
                    );
                  }).toList()),
                ),
              );
            }
            else{
              return const Center(child: Text("No data to show"),);
            }
          }
          return Loading();
        },
      ),
    );
  }
}
