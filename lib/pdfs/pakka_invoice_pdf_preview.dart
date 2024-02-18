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
        
        pdfFileName: data['invoiceNumber'] != null ? data['invoiceNumber'].toString().replaceAll("/", "_") : "${data['customerName']}${data['quotationNumber']}",
        build: (context) => makeInvoicePdf(data)),
    );
  }
}