
import 'package:ay_invoiving_app/addPurchase.dart';
import 'package:ay_invoiving_app/pdfs/pakka_invoice_pdf_preview.dart';
import 'package:ay_invoiving_app/provider/company.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PurchaseReportState();
  }
}

List<Map> company = [
  {'name': JRM().name, 'value': JRM().value},
  {'name': AYI().name, 'value': AYI().value}
];

List month = [
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

class PurchaseReportState extends State<PurchaseReport> {

  firebaseStream(){
    
  }

  Map selectedCompany = company.first;
  bool pakkaOnly = false;
  bool kachchaOnly = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  bool dateFilter = false;

  String transactionType = "";

  @override
  Widget build(BuildContext context) {
    print(startDate.toString()+"|"+endDate.toString());
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase Report")),
      body: StreamBuilder(
        stream: (pakkaOnly || kachchaOnly) && dateFilter
            ? FirebaseFirestore.instance
                .collection('purchase')
                .where('purchaseInCompany', isEqualTo: selectedCompany['value'])
                .where('transactionType', isEqualTo: transactionType)
                .orderBy('invoiceDate', descending: true).where('invoiceDate',  isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
                .snapshots()
            : (pakkaOnly || kachchaOnly) ? FirebaseFirestore.instance
                .collection('purchase')
                .orderBy('invoiceDate', descending: true)
                .where('purchaseInCompany', isEqualTo: selectedCompany['value'])
                .where('transactionType', isEqualTo: transactionType)
                .snapshots() :

                dateFilter ? FirebaseFirestore.instance
                .collection('purchase')
                .orderBy('invoiceDate', descending: true).where('purchaseInCompany', isEqualTo: selectedCompany['value']).where('invoiceDate',  isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
                .snapshots() :
                FirebaseFirestore.instance
                .collection('purchase')
                .where('purchaseInCompany', isEqualTo: selectedCompany['value'])
                .orderBy('invoiceDate', descending: true)
                .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            debugPrint(snapshot.data.docs.length.toString());
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10)),
                                child: DropdownButton<Map>(
                                    alignment: Alignment.center,
                                    isExpanded: true,
                                    dropdownColor: Colors.grey,
                                    value: selectedCompany,
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    items: company
                                        .map<DropdownMenuItem<Map>>((curr) {
                                      return DropdownMenuItem<Map>(
                                          value: curr,
                                          child: Text(curr['name']));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCompany = value!;
                                      });
                                    })),
                            dateFilter
                                ? SizedBox(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                              DateTimeRange? result = await showDateRangePicker(
                                                
                                                  context: context,
                                                  
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      31));
                                                                        
                                              setState(() {
                                                dateFilter = true;
                                                startDate = result!.start;
                                                endDate = result.end;
                                              });
                                            },
                                            child: Text("${startDate.day}-${month[startDate.month - 1]}-${startDate.year} TO ${endDate.day}-${month[endDate.month - 1]}-${endDate.year}")),
                                      ),
                                          IconButton(onPressed: (){
                                            setState(() {
                                              dateFilter = false;
                                            });
                                          }, icon: const Icon(Icons.clear,size: 18,color: Colors.amber,))
                                    ],
                                  ),
                                )
                                : TextButton.icon(
                                  icon: const Icon(Icons.date_range),
                                    onPressed: () async {
                                      DateTimeRange? result = await showDateRangePicker(
                                        
                                          context: context,
                                          
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              31));

                                      setState(() {
                                        dateFilter = true;
                                        startDate = result!.start;
                                        endDate = result.end;
                                      });
                                    },
                                    label: const Text("Select Date Range"))
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InputChip(
                            selectedColor: Colors.amber,
                            label: const Text('Pakka Only'),
                            onSelected: (value) {
                              setState(() {
                                pakkaOnly = value;
                                kachchaOnly = false;
                                transactionType = 'pakka';
                              });
                            },
                            selected: pakkaOnly,
                          ),
                          InputChip(
                            selectedColor: Colors.amber,
                            label: const Text('Kachcha Only'),
                            onSelected: (value) {
                              setState(() {
                                pakkaOnly = false;
                                kachchaOnly = value;
                                transactionType = 'kachcha';
                              });
                            },
                            selected: kachchaOnly,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                if (snapshot.data.docs.isNotEmpty)
                
                  Expanded(
                    child: ListView(
                      children: snapshot.data.docs
                          .map<Widget>((sale) => InkWell(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  padding: const EdgeInsets.all(8),
                                  child: Card(
                                    child: InkWell(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Purchase(data: sale.data(),edit: false,view: true,)));
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                //date
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Text(sale['invoiceDate']
                                                          .toDate()
                                                          .day
                                                          .toString()
                                                          .padLeft(2, '0')),
                                                      Text(month[
                                                          sale['invoiceDate']
                                                                  .toDate()
                                                                  .month -
                                                              1]),
                                                      Text(sale['invoiceDate']
                                                          .toDate()
                                                          .year
                                                          .toString()),
                                                    ],
                                                  ),
                                                ),
                                    
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(sale['invoiceNumber']),
                                                      Text(sale['customerName']),
                                                      Flex(
                                                        direction:
                                                            Axis.horizontal,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        children: sale[
                                                                'billedItem']
                                                            .map<Widget>((item) =>
                                                                Expanded(
                                                                    child: Text(item[
                                                                        'name'])))
                                                            .toList(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                      "₹${NumberFormat("##,##,#00.00").format(double.parse(sale['invoiceAmount'].toString()))}"),
                                                )
                                              ]),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Purchase(data: sale.data(),edit: true, view: false,)));
                                                  },
                                                  icon: const Icon(Icons.edit)),
                                              
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  )
                else
                  const Center(
                    child: Text("No Data to show"),
                  ),
              ],
            );
          }
          return Loading();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Purchase(data: {},edit: false,view: false,)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
