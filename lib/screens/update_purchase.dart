import 'package:ay_invoiving_app/addPurchase.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdatePurchase extends StatefulWidget {
  State createState() {
    return UpdatePurchaseState();
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

class UpdatePurchaseState extends State<UpdatePurchase> {

  build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text("Last 15 Purchases")),
      body: StreamBuilder(
        stream: context.watch<UserProvider>().admin ? FirebaseFirestore.instance
            .collection('purchase')
            .orderBy('timestamp', descending: true)
            .limit(15)
            .snapshots(): FirebaseFirestore.instance
            .collection('purchase')
            .where('generatedBy',
                isEqualTo: context.watch<UserProvider>().userName)
            .orderBy('timestamp', descending: true)
            .limit(15)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.isNotEmpty) {
              debugPrint(snapshot.data.docs.toString());

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
                  child: Column(
                      children: snapshot.data.docs.map<Widget>((purchase) {
                    DateTime purchaseInvoiceDate = purchase['invoiceDate'].toDate();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0,vertical: 2),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Purchase(data: purchase.data(),edit: true,view: false,)));
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
                                        "${purchaseInvoiceDate.day}\n${months[purchaseInvoiceDate.month - 1]}\n${purchaseInvoiceDate.year}",
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
                                            purchase['invoiceNumber'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            purchase['customerName'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                    NumberFormat("₹ ##,##,#00.##").format(
                                        double.parse(
                                            purchase['invoiceAmount'].toString())),
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
