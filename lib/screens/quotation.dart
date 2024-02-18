import 'package:ay_invoiving_app/pdfs/pakka_invoice_pdf_preview.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/sales.dart';
import 'package:ay_invoiving_app/screens/add_quotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';

class Quotation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return QuotationState();
  }
}

class QuotationState extends State<Quotation> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userName;
    final admin = context.watch<UserProvider>().admin;
    return Scaffold(
      appBar: AppBar(title: const Text("Quotation")),
      body: StreamBuilder(
        stream: admin
            ? FirebaseFirestore.instance.collection('quotation').snapshots()
            : FirebaseFirestore.instance
                .collection('quotation')
                .where('generatedBy', isEqualTo: user)
                .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.isEmpty) {
              return const Center(
                child: Text("Empty"),
              );
            }

            return Padding(
              padding:
                  const EdgeInsets.only(top: 3, left: 5, right: 5, bottom: 60),
              child: ListView(
                children: snapshot.data.docs.map<Widget>((quotation) {
                  DateTime date = quotation['quotation'] != null ? quotation['quotation'].toDate() : quotation['quotationDate'].toDate();
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesWidget(
                                      data: quotation.data(),
                                      edit: false,
                                      view: false,
                                    )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(quotation['quotationNumber']),
                            Text("${date.day}/${date.month}/${date.year}"),
                          ],
                        ),
                        Text(quotation['customerName']),
                        Text(NumberFormat("₹##,##,##0.00").format(quotation['invoiceAmount'])),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                          IconButton(icon: Icon(Icons.share),onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PakkaInvoicePdfPreview(data: quotation.data())));
                          }),
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SalesWidget(edit: false, view: false, data: quotation.data())));
                          }, child: const Text("Convert to sale"))
                        ],)
                      ]),
                    ),
                  ));
                }).toList(),
              ),
            );
          }
          return Loading();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddQuotation(
                        data: {},
                        edit: false,
                        view: false,
                      ))),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
