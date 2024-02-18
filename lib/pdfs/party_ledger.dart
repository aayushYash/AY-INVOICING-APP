import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';



Future<Uint8List> makePdf(data) async {

  // List<Widget> widget = ;

  final pdf = Document();


  
  pdf.addPage(
    MultiPage(
      maxPages: 3,
      build: (context)  {
      return [
        Column(
        children: [
           Container(alignment: Alignment.center,
          child: Text(data['party'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))
          ),
          Container(alignment: Alignment.center,
          child: Text('Party Ledger',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16))
          ),
          Container(alignment: Alignment.center,
          child: Text("As on ${data['time'].day}/${data['time'].month}/${data['time'].year}",style: TextStyle(fontSize: 14))
          ),

          SizedBox(height: 10),

          Table(border: TableBorder.all(color: PdfColors.black),
          children: [
            TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(20),
              child: Text("Date",
              textAlign: TextAlign.center),
              ),
              Padding(padding: const EdgeInsets.all(20),
              child: Text("Transaction",
              textAlign: TextAlign.center),
              ),
              Padding(padding: const EdgeInsets.all(20),
              child: Text("Reference",
              textAlign: TextAlign.center),
              ),
              Padding(padding: const EdgeInsets.all(20),
              child: Text("Amount",
              textAlign: TextAlign.center),
              ),
              Padding(padding: const EdgeInsets.all(20),
              child: Text("Balance",
              textAlign: TextAlign.center),
              ),
            ]
          ),

          
          ...data['item'].map((item) {

            print(item.toString());
            String str = item['balance']<0 ? "Cr." : "Dr.";
            DateTime time = item['time'].toDate();
            return TableRow(children: [
            
            Padding(padding: const EdgeInsets.all(2),child: Text("${time.day}/${time.month}/${time.year}")),
            Padding(padding: const EdgeInsets.all(2),child: Text(item['type'].toString())),
            Padding(padding: const EdgeInsets.all(2) , child: Text(item['id'].toString())),
            Padding(padding: const EdgeInsets.all(2),child: Text(NumberFormat("##,##,#00.00").format(item['amount'].abs()),textAlign: TextAlign.right)),
            Padding(padding: const EdgeInsets.all(2),child: Text("${NumberFormat("##,##,#00.00").format(item['balance'].abs())} $str",textAlign: TextAlign.right)),

          ]);
          }
          ),
          ]
          ),

        ]
      )
      ];
    })
  );

  return pdf.save();
}
