import 'package:ay_invoiving_app/pdfs/pakka_invoice_pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PakkaInvoicePdfPreview extends StatelessWidget{

  Map data;
  PakkaInvoicePdfPreview({super.key, required this.data});
  
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice Preview"),
      ),
      body: PdfPreview(
        initialPageFormat: PdfPageFormat.a4,
        onShared: (context) => print("Shared"),
        allowSharing: true,
        pdfFileName: data['invoiceNumber'] != null ? data['invoiceNumber'].toString().replaceAll("/", "_")+".pdf" : "${data['customerName']}${data['quotationNumber']}.pdf",
        build: (context) => makeInvoicePdf(data)),
    );
  }
}