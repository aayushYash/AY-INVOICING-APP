import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:ay_invoiving_app/pdfs/party_ledger.dart';


class PartyLedgerPdfPreview extends StatelessWidget{

  final Map data;
  const PartyLedgerPdfPreview({super.key, required this.data});

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Ledger Preview"),
      ),
      body: PdfPreview(
        pdfFileName: "${data['party']}_${data['time'].day}_${data['time'].month}_${data['time'].year}",
        build: (context) => makePdf(data),
        ),
    );
  }
}