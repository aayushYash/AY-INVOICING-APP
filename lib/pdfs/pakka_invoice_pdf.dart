import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:indian_currency_to_word/indian_currency_to_word.dart';
import 'package:intl/intl.dart';
import 'package:number_to_character/number_to_character.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:collection/collection.dart';

Future<Uint8List> makeInvoicePdf(data) async {
  Map<String,dynamic>? party;

  await FirebaseFirestore.instance
      .collection('party')
      .doc(data['customerName'])
      .get()
      .then((value) {
     party = value.data() as Map<String,dynamic>;
  });

  Map ayi = {
    'name': "A Y Industries",
    'address': 'Patel Nagar, Bhurkunda, Ramgarh',
    'pin': '829106',
    'state': 'Jharkhand',
    'gstin': '20BEWPY6192L1ZI',
    'bankName': "Bank Of Maharashtra",
    'accountNo': '60435213554',
    'IFSC': 'MAHB0002136',
    'branch': 'Ratu Road, Ranchi',
    'phoneNumber': '9523933708  7258090619',
    'email': 'sales.ayindustries22@gmail.com'
  };

  Map jrm = {
    'name': "Jharkhand Refractory and Minerals",
    'address': 'Sunder Nagar, Bhurkunda, Ramgarh',
    'pin': '829105',
    'state': 'Jharkhand',
    'gstin': '20BHCPS0036C1Z6',
    'bankName': "BANK OF BARODA",
    'accountNo': '54770200000174',
    'IFSC': 'BARB0BHURKU',
    'branch': 'BHURKUNDA, RAMGARH',
    'phoneNumber': '9523933708',
    'email': 'jrm_ramgarh@rediffmail.com'
  };
  var company;

  List invoice = ['Original For Recipient', 'Duplicate For Transaporter'];

  var converter = AmountToWords();

  if (data['billingCompany'] == 'ayi') {
    company = ayi;
  } 
  if(data['billingCompany'] == 'jrm') {
    company = jrm;
  }

  bool sameState = party?['gstin'].length <= 2
      ? true
      : party?['gstin'].substring(0, 2) == '20';

  final pdf = Document(compress: true);


  int index = 0;
  const double itemContentFontSize = 9;
  const double itemFooterHeaderFontSize = 10;
  const double companyFontSize = 13.5;
  double totalTaxableAmount = 0, totalTaxAmount = 0, totalInvoiceAmount = 0,totalcgst = 0,totalDiscount = 0;

  final qrcode = MemoryImage((await rootBundle.load('assets/qrcode.jpg')).buffer.asUint8List());

 


  if(data['transactionType'] == 'kachcha'){

    //pdf format for kachcha invoice
    pdf.addPage(

    MultiPage(
      header: (context) => Container(alignment: Alignment.center,child: Text(data['invoiceNumber'] !=null? 'Bill Of Service' : "Quotation")),
      footer: (context) => Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide())),
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text("Office Address: ",style: TextStyle(font: Font.timesBold(),fontSize: 9)),
          Text(company['address'],style: TextStyle(font: Font.times(),fontSize: 9)),
          Text("${company['state']} ${company['pin']}",style: TextStyle(font: Font.times(),fontSize: 9))
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          Text("Contacts: ",style: TextStyle(font: Font.timesBold(),fontSize: 9)),
          Text(company['phoneNumber'],style: TextStyle(font: Font.times(),fontSize: 9)),
          Text(company['email'],style: TextStyle(font: Font.times(),fontSize: 9)),
        ])
      ])),
      pageFormat: PdfPageFormat.a4,
      theme: ThemeData(
        defaultTextStyle: TextStyle(font: Font.times(), fontSize: 11),
      ),
      margin: const EdgeInsets.all(16),

      build: (context) => [Column(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: PdfColors.black)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: companyFontSize +1,font: Font.timesBold())),
                            Text(company['address'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: companyFontSize)),
                            Row(children: [
                              Text(company['state'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: companyFontSize)),
                                      SizedBox(width: 5),
                              Text(company['pin'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: companyFontSize)),
                            ]),
                            Text("GSTIN: ${company['gstin']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: companyFontSize)),
                          ]),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            child:
                                Text(data['invoiceNumber'] != null ? "Invoice No.: ${data['invoiceNumber'] }" : "Quotation No.: ${data['quotationNumber'] }")),
                        Container(
                            child: Text(data['invoiceDate'] != null?
                                "Date: ${data['invoiceDate'].toDate().day}/${data['invoiceDate'].toDate().month}/${data['invoiceDate'].toDate().year}" : "Date: ${data['quotationDate'].toDate().day}/${data['quotationDate'].toDate().month}/${data['quotationDate'].toDate().year}")),
                        if(data['ewaybillNumber'].toString().isNotEmpty) Row(children: [Text("Ewaybill No: "),
                        Text(data['ewaybillNumber'])
                        ]),
                        if(data['vehicleNumber'].toString().isNotEmpty) Row(children: [Text("Vehicle No: "), Text(data['vehicleNumber'])]),
                        if(data['transportName'].toString().isNotEmpty)Row(children: [Text("Transport Name: "),Text(data['transportName']),]),
                        if(data['shippingAddress'].toString().isNotEmpty) Row(children: [Text('Place of Delivery: '),Text(data['shippingAddress'])]),
                        if(data['powo'].toString().isNotEmpty) Row(children: [Text("PO/WO: "),Text(data['powo'].toString())]),
                        // if(!data['po'].isNull && data['po'].isNotEmpty) Text("PO/WO: $data['po']"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: PdfColors.black)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Billing Address:"),
                          SizedBox(height: 5),
                          Text(data['customerName'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: companyFontSize,font: Font.timesBold())),
                          Text(party?['billingAddress']),
                          Text("GSTIN: " + party?['gstin']),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: PdfColors.black)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shipping Address:"),
                          SizedBox(height: 5),
                          Text(data['customerName'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: companyFontSize,font: Font.timesBold())),
                          Text(party?['shippingAddress']),
                          Text("GSTIN: " + party?['gstin']),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            alignment: Alignment.center,
            child: Text("Billed Products"),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            height: 150,
            child: Table(
                border: TableBorder.all(color: PdfColors.black),
                children: [
                  TableRow(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                      decoration: const BoxDecoration(color: PdfColors.grey200),
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Sl.',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Product Name',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Qnty.',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Unit',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Rate',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Amount',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize)))
                      ]),
                  ...data['billedItem'].map((item) {
                    var rate = item['rate'];

                    double amount = double.parse((rate * item['quantity']).toStringAsFixed(2));



                    double discount = double.parse((amount * (item['discount'] * 0.01)).toStringAsFixed(2));

                    totalInvoiceAmount = amount - discount;


                    totalDiscount +=discount;

                    totalInvoiceAmount = double.parse(totalInvoiceAmount.toStringAsFixed(2));


                    index++;
                    return TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text("$index",style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['name'].toString(),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['quantity'].toString(),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['unit'].toString(),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(rate.toStringAsFixed(2),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['discount'] == 0 ? NumberFormat("##,##,###.00")
                                  .format(amount) : NumberFormat("##,##,###.00").format(amount) +" - " + NumberFormat("##,##,###.00").format(discount)  + " (${item['discount']}%)\n" + NumberFormat("##,##,###.00").format(amount-discount),style: const TextStyle(fontSize: itemContentFontSize),textAlign: TextAlign.right)),

                        ]);
                  }),
                  TableRow(
                      decoration: const BoxDecoration(color: PdfColors.grey200),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("Total")),

                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(NumberFormat(" ##,##,###.00")
                                .format(totalInvoiceAmount),style: const TextStyle(fontSize: itemFooterHeaderFontSize),textAlign: TextAlign.right)),

                      
                      
                      ]),
                ]),
          ),
          Table(
              border: TableBorder.all(
                color: PdfColors.black,
              ),
              children: [
                TableRow(
                  
                    decoration: const BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: PdfColors.black))),
                    children: [
                      Container(
                          width: 170,
                          height: 55,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Text("Total Amount:\n(in words)",softWrap: true,
                                maxLines: 2,
                                    textAlign: TextAlign.left),
                              ),
                              Expanded(child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Text(converter.convertAmountToWords(totalInvoiceAmount.roundToDouble()).toUpperCase().replaceAll("  ", " "),overflow: TextOverflow.clip,
                                maxLines: 4,
                                    textAlign: TextAlign.left,style: const TextStyle(fontSize: 11.5)),
                              )),
                            ],
                          ),
                        ),
                    
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        height: 62, 
                        width: 120,
                        child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        Text("Total Discount"),
                        Text("Rounding Off"),

                      ])),
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        width: 85,
                        height: 62, child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        Text(NumberFormat("-##,##,##0.00").format(totalDiscount)),
                        Text(totalInvoiceAmount - totalInvoiceAmount.roundToDouble() > 0 ? NumberFormat("-#0.00").format(totalInvoiceAmount - totalInvoiceAmount.roundToDouble().abs()):  NumberFormat("+#0.00").format(totalInvoiceAmount - totalInvoiceAmount.roundToDouble().abs())),
                      ]))
                    ]),
                    TableRow(

                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                        border: Border.symmetric(
                            vertical: BorderSide(color: PdfColors.black))),
                            verticalAlignment: TableCellVerticalAlignment.full,
                    children: [
                      Expanded(child: Container(
                          width: 250,
                          margin: const EdgeInsets.all(10),
                          child: 
                          Column(   
                            children: [
                                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Column(
                                crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                  children: [
                              Text("Bank Details",textAlign: TextAlign.left,style: TextStyle(decoration: TextDecoration.underline,decorationStyle: TextDecorationStyle.solid,fontWeight: FontWeight.bold,)),
                              SizedBox(height: 3),
                                    Row(children: [
                                      Text('Bank Name: '),
                                      Text(company['bankName'])
                                    ]),
                                    Row(children: [
                                      Text('Account Number: '),
                                      Text(company['accountNo'])
                                    ]),
                                    Row(children: [
                                    Text("IFSC: "),
                                  
                                      Text(company['IFSC'])
                                    ]),
                                    Row(children: [
                                    Text("Branch Name: "),
                                  
                                      Text(company['branch'])
                                    ]),
                                  ]),
                                Column(
                                  children: [
                                    Text("Pay Directly On UPI:",style: TextStyle(fontSize: 7.4)),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      height: 70,
                                      width: 70,
                                      child: Image(qrcode)),
                                    
                                  ]
                                )
                            ],),

                          ],
                          
                        )),
                        ),
                    
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text("Total Amount",textAlign: TextAlign.right),),
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        width: 75,
                        child: Text(NumberFormat("##,##,###.00").format(totalInvoiceAmount.roundToDouble()),textAlign: TextAlign.right))
                    ]),
              ]),
                    Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                          width: 358.4,
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              
                              Expanded(child: Container(
                                height: 160,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Expanded(child: Text("Terms & Conditions:\n1. No replacement/exchange/refund against this Invoice.\n2. Our responsibility ceases when goods leaves our godown.\n3. Interest @24% P.A will be charged on delayed payments.\n4. All disputes are subject to Ramgarh (JHARKHAND) Jurisdiction.\n5. Hence, as per the generally accepted norms in steel trade, any variation of weight on either side(+/-) upto 0.5% of challan quantity shall not be considered and payment shall be made for the despatch quantity mentioned on Invoice",overflow: TextOverflow.clip,
                                maxLines: 8,
                                    textAlign: TextAlign.left,style: const TextStyle(fontSize: 10.5)),
                              ))),
                            ],
                          ),
                        ),
                    
                     
                      Container(
                        height: 110,
                        decoration: BoxDecoration(border: Border.all()),
                        padding: const EdgeInsets.only(right: 10,top: 5,bottom: 5),
                        width: 205,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("For, ${company['name']}",textAlign: TextAlign.right),
                          Text("Authorized Signatory")
                          ]))
                    ])
        ],
      ),]
    ),
  );
  
  return pdf.save();
  }

  // pdf format for pakka invoice
  for (var inv in invoice) {

    pdf.addPage(

    MultiPage(
      header: (context) => Container(alignment: Alignment.center,child: Text(data['invoiceNumber'] !=null? 'Tax Invoice' : "Quotation")),
      footer: (context) => Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide())),
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text("Office Address: ",style: TextStyle(font: Font.timesBold(),fontSize: 9)),
          Text(company['address'],style: TextStyle(font: Font.times(),fontSize: 9)),
          Text("${company['state']} ${company['pin']}",style: TextStyle(font: Font.times(),fontSize: 9))
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          Text("Contacts: ",style: TextStyle(font: Font.timesBold(),fontSize: 9)),
          Text(company['phoneNumber'],style: TextStyle(font: Font.times(),fontSize: 9)),
          Text(company['email'],style: TextStyle(font: Font.times(),fontSize: 9)),
        ])
      ])),
      pageFormat: PdfPageFormat.a4,
      theme: ThemeData(
        defaultTextStyle: TextStyle(font: Font.times(), fontSize: 11),
      ),
      margin: const EdgeInsets.all(16),

      build: (context) => [Column(
        children: [
          Container(alignment: Alignment.centerRight, child: Text(inv)),
          Container(
            height: 100,
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: PdfColors.black)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: companyFontSize +1,font: Font.timesBold())),
                            Text(company['address'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: companyFontSize)),
                            Row(children: [
                              Text(company['state'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: companyFontSize)),
                                      SizedBox(width: 5),
                              Text(company['pin'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: companyFontSize)),
                            ]),
                            Text("GSTIN: ${company['gstin']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: companyFontSize)),
                          ]),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            child:
                                Text(data['invoiceNumber'] != null ? "Invoice No.: ${data['invoiceNumber'] }" : "Quotation No.: ${data['quotationNumber'] }")),
                        Container(
                            child: Text(
                                data['invoiceDate'] != null?
                                "Date: ${data['invoiceDate'].toDate().day}/${data['invoiceDate'].toDate().month}/${data['invoiceDate'].toDate().year}" : "Date: ${data['quotationDate'].toDate().day}/${data['quotationDate'].toDate().month}/${data['quotationDate'].toDate().year}")),
                        if(data['ewaybillNumber'].toString().isNotEmpty) Row(children: [Text("Ewaybill No: "),
                        Text(data['ewaybillNumber'])
                        ]),
                        if(data['vehicleNumber'].toString().isNotEmpty) Row(children: [Text("Vehicle No: "), Text(data['vehicleNumber'])]),
                        if(data['transportName'].toString().isNotEmpty)Row(children: [Text("Transport Name: "),Text(data['transportName']),]),
                        if(data['shippingAddress'].toString().isNotEmpty) Row(children: [Text('Place of Delivery: '),Text(data['shippingAddress'])]),
                        if(data['powo'].toString().isNotEmpty) Row(children: [Text("PO/WO: "),Text(data['powo'].toString())]),
                        // if(!data['po'].isNull && data['po'].isNotEmpty) Text("PO/WO: $data['po']"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 95,
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: PdfColors.black)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Billing Address:"),
                          SizedBox(height: 5),
                          Text(data['customerName'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: companyFontSize,font: Font.timesBold())),
                          Text(party?['billingAddress']),
                          Text("GSTIN: " + party?['gstin']),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: PdfColors.black)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shipping Address:"),
                          SizedBox(height: 5),
                          Text(data['customerName'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: companyFontSize,font: Font.timesBold())),
                          Text(party?['shippingAddress']),
                          Text("GSTIN: " + party?['gstin']),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            alignment: Alignment.center,
            child: Text("Billed Products"),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: PdfColors.black),
                  left: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black)),
            ),
            height: 150,
            child: Table(
                border: TableBorder.all(color: PdfColors.black),
                children: [
                  TableRow(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                      decoration: const BoxDecoration(color: PdfColors.grey200),
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Sl.',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Product Name',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Qnty.',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Unit',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Rate',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                            Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Discount',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Taxable\nAmt.',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        sameState
                            ? SizedBox(
                              width: 100,
                              height: 40,
                              child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                  Expanded(child: Container(
                                      child: (Text('CGST',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))))),
                                      VerticalDivider(),

                                  Expanded(child: Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text('SGST',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))))
                                ]))
                            : Container(
                                padding: const EdgeInsets.all(5),
                                child: Text('IGST',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text('Amount',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: itemFooterHeaderFontSize)))
                      ]),
                  ...data['billedItem'].map((item) {
                    var rate = item['inclTax']
                        ? double.parse(
                            (item['rate'] / (1 + (item['gst'] / 100)))
                                .toStringAsFixed(2))
                        : item['rate'];

                    double taxableAmount = double.parse((rate * item['quantity']).toStringAsFixed(2));

                    double discount = double.parse((taxableAmount * (item['discount'] * 0.01)).toStringAsFixed(2));

                    taxableAmount = taxableAmount - discount;

                    double taxAmount = double.parse((taxableAmount * (item['gst'] * 0.01)).toStringAsFixed(2));

                    double totalAmount = taxAmount + taxableAmount;

                    double cgst = double.parse((taxAmount / 2).toStringAsFixed(2));



                    totalTaxAmount += taxAmount;
                    totalInvoiceAmount += totalAmount;
                    totalTaxableAmount += taxableAmount;
                    totalcgst += cgst;
                    totalDiscount +=discount;

                    totalTaxAmount = double.parse(totalTaxAmount.toStringAsFixed(2));
                    totalInvoiceAmount = double.parse(totalInvoiceAmount.toStringAsFixed(2));
                    totalTaxableAmount = double.parse(totalTaxableAmount.toStringAsFixed(2));


                    index++;
                    return TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text("$index",style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['name'].toString()+"\n"+item['hsn'].toString(),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['quantity'].toString(),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(item['unit'].toString(),style: const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(rate.toStringAsFixed(2),style: const TextStyle(fontSize: itemContentFontSize))),
                              Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(NumberFormat("##,##,##0.00").format(discount) +"\n ${item['discount']}%"
                                  ,style:const TextStyle(fontSize: itemContentFontSize))),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(NumberFormat("##,##,###.00")
                                  .format(taxableAmount),style: const TextStyle(fontSize: itemContentFontSize),textAlign: TextAlign.right)),
                          sameState
                              ? SizedBox(
                                height: 30,
                                width: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                      Expanded(child: Container(
                                          child: Text(
                                              "${NumberFormat(" ##,##,###.00").format(cgst)}\n${item['gst']}%",style: const TextStyle(fontSize: itemContentFontSize),textAlign: TextAlign.right))),
                                      VerticalDivider(),
                                      Expanded(child: Container(
                                        padding: EdgeInsets.only(right: 5),
                                        width: 52.5,
                                          child: Text(
                                              "${NumberFormat(" ##,##,###.00").format(cgst)}\n${item['gst']}%",style: const TextStyle(fontSize: itemContentFontSize),textAlign: TextAlign.right)))
                                    ]))
                              : Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      "${NumberFormat(" ##,##,###.00").format(taxAmount)}\n${item['gst']}%",style: const TextStyle(fontSize: itemContentFontSize),textAlign: TextAlign.right)),
                          Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(NumberFormat("##,##,##0.00").format(totalAmount),style: const TextStyle(fontSize: itemContentFontSize),textAlign: TextAlign.right))
                        ]);
                  }),
                  TableRow(
                      decoration: const BoxDecoration(color: PdfColors.grey200),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5), child: Text("")),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text("Total",style: const TextStyle(fontSize: itemFooterHeaderFontSize))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(NumberFormat(" ##,##,###.00")
                                .format(totalTaxableAmount),style: const TextStyle(fontSize: itemFooterHeaderFontSize),textAlign: TextAlign.right)),
                        sameState
                            ? SizedBox(
                              width: 100,
                              height: 24,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                    Expanded(child: Container(
                                      
                                        child: Text(NumberFormat(" ##,##,###.00")
                                            .format(totalcgst),style: const TextStyle(fontSize: itemFooterHeaderFontSize),textAlign: TextAlign.right))),
                                      VerticalDivider(),

                                    Expanded(child: Container(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Text(NumberFormat(" ##,##,###.00")
                                            .format(totalcgst),style: const TextStyle(fontSize: itemFooterHeaderFontSize),textAlign: TextAlign.right)))
                                  ]))
                            : Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(NumberFormat("##,##,###.00")
                                    .format(totalTaxAmount),style: const TextStyle(fontSize: itemFooterHeaderFontSize),textAlign: TextAlign.right)),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(NumberFormat("##,##,###.00")
                                .format(totalInvoiceAmount),style: const TextStyle(fontSize: itemFooterHeaderFontSize),textAlign: TextAlign.right))
                      
                      
                      ]),
                ]),
          ),
          Table(
              border: TableBorder.all(
                color: PdfColors.black,
              ),
              children: [
                TableRow(
                  
                    decoration: const BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: PdfColors.black))),
                    children: [
                      Container(
                          width: 170,
                          height: 55,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Text("Total Amount:\n(in words)",softWrap: true,
                                maxLines: 2,
                                    textAlign: TextAlign.left),
                              ),
                              Expanded(child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Text(converter.convertAmountToWords(totalInvoiceAmount.roundToDouble()).toUpperCase().replaceAll("  ", " "),overflow: TextOverflow.clip,
                                maxLines: 4,
                                    textAlign: TextAlign.left,style: const TextStyle(fontSize: 11.5)),
                              )),
                            ],
                          ),
                        ),
                    
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        height: 62, 
                        width: 120,
                        child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        Text("Taxabale Amount"),
                        Text("Total Tax"),
                        Text("Total Discount"),
                        Text("Rounding Off"),

                      ])),
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        width: 85,
                        height: 62, child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        Text(NumberFormat("##,##,###.00").format(totalTaxableAmount)),
                        Text(NumberFormat("##,##,###.00").format(totalTaxAmount)),
                        Text(NumberFormat("-##,##,##0.00").format(totalDiscount)),
                        Text(totalInvoiceAmount - totalInvoiceAmount.roundToDouble() > 0 ? "-${NumberFormat("#0.00").format(totalInvoiceAmount - totalInvoiceAmount.roundToDouble())}" :  NumberFormat("#0.00").format(totalInvoiceAmount - totalInvoiceAmount.roundToDouble())),
                      ]))
                    ]),
                    TableRow(

                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                        border: Border.symmetric(
                            vertical: BorderSide(color: PdfColors.black))),
                            verticalAlignment: TableCellVerticalAlignment.full,
                    children: [
                      Expanded(child: Container(
                          width: 250,
                          margin: const EdgeInsets.all(10),
                          child: 
                          Column(   
                            children: [
                              Text("Bank Details",
                                  textAlign: TextAlign.left,style: TextStyle(decoration: TextDecoration.underline,decorationStyle: TextDecorationStyle.solid,fontWeight: FontWeight.bold,)),
                              SizedBox(height: 3),
                              Column(
                                crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(children: [
                                      Text('Bank Name: '),
                                      Text(company['bankName'])
                                    ]),
                                    Row(children: [
                                      Text('Account Number: '),
                                      Text(company['accountNo'])
                                    ]),
                                    Row(children: [
                                    Text("IFSC: "),
                                  
                                      Text(company['IFSC'])
                                    ]),
                                    Row(children: [
                                    Text("Branch Name: "),
                                  
                                      Text(company['branch'])
                                    ]),
                                  ]),
                            ],
                          ),
                          
                          
                        ),
                        ),
                    
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text("Total Amount",textAlign: TextAlign.right),),
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        width: 75,
                        child: Text(NumberFormat("##,##,###.00").format(totalInvoiceAmount.roundToDouble()),textAlign: TextAlign.right))
                    ]),
              ]),
                    Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                          width: 358.4,
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              
                              Expanded(child: Container(
                                height: 160,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Expanded(child: Text("Terms & Conditions:\n1. No replacement/exchange/refund against this Invoice.\n2. Our responsibility ceases when goods leaves our godown.\n3. Interest @24% P.A will be charged on delayed payments.\n4. All disputes are subject to Ramgarh (JHARKHAND) Jurisdiction.\n5. Hence, as per the generally accepted norms in steel trade, any variation of weight on either side(+/-) upto 0.5% of challan quantity shall not be considered and payment shall be made for the despatch quantity mentioned on Invoice",overflow: TextOverflow.clip,
                                maxLines: 8,
                                    textAlign: TextAlign.left,style: const TextStyle(fontSize: 10.5)),
                              ))),
                            ],
                          ),
                        ),
                    
                     
                      Container(
                        height: 110,
                        decoration: BoxDecoration(border: Border.all()),
                        padding: const EdgeInsets.only(right: 10,top: 5,bottom: 5),
                        width: 205,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("For, ${company['name']}",textAlign: TextAlign.right),
                          Text("Authorized Signatory")
                          ]))
                    ])
        ],
      ),]
    ),
  );
    
  } 

  return pdf.save();
}
