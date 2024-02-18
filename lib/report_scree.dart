import 'package:ay_invoiving_app/purchaseReport.dart';
import 'package:ay_invoiving_app/salesReport.dart';
import 'package:ay_invoiving_app/screens/expense.dart';
import 'package:ay_invoiving_app/screens/update_paymentin.dart';
import 'package:ay_invoiving_app/screens/update_paymentout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReportState();
  }
}

List reports= [
{
  'title': 'Monthly Summary Report',
  'widget': SalesReport(),
},
{
  'title': 'Stock Report',
  'widget': SalesReport(),
},
{
  'title': 'Monthly Summary Report',
  'widget': SalesReport(),
},
{
  'title': 'Stock Report',
  'widget': SalesReport(),
},
{
  'title': 'Monthly Summary Report',
  'widget': SalesReport(),
},
{
  'title': 'Stock Report',
  'widget': SalesReport(),
},
{
  'title': 'Monthly Summary Report',
  'widget': SalesReport(),
},
{
  'title': 'Stock Report',
  'widget': SalesReport(),
}
];


class ReportState extends State<Report> {
  int noOfsalesPakka = 0;
  int noOfsalesKachcha = 0;
  double pakkaSalesValue = 0;
  double kachchaSalesValue = 0;

  int noOfpurchasePakka = 0;
  int noOfpurchaseKachcha = 0;
  double pakkaPurchaseValue = 0;
  double kachchaPurchaseValue = 0;

  int totalnoOfpaymentin = 0;
  double totalPaymentinAmount = 0;

  int totalnoOfpaymentout = 0;
  double totalPaymentoutAmount = 0;

  int totalExpenses = 0;
  double totalExpenseAmount = 0;

  firebaseHandler() {
    DateTime today = DateTime.now();

    DateTime startDate = DateTime(today.year, today.month, 1);
    DateTime endDate = DateTime(today.year, today.month + 1, 0);

    FirebaseFirestore.instance
        .collection('sales')
        .where('invoiceDate',
            isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
        .get()
        .then((sales) {
      int kchcha = 0;
      int pakka = 0;
      double kchchaValue = 0;
      double pakkaValue = 0;
      sales.docs.forEach((sale) {
        if (sale['transactionType'] == 'kachcha') {
          kchcha++;
          kchchaValue += sale['invoiceAmount'];
        } else {
          pakka++;
          pakkaValue += sale['invoiceAmount'];
        }
      });

      setState(() {
        noOfsalesKachcha = kchcha;
        noOfsalesPakka = pakka;
        kachchaSalesValue = kchchaValue;
        pakkaSalesValue = pakkaValue;
      });
    });
    FirebaseFirestore.instance
        .collection('purchase')
        .where('invoiceDate',
            isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
        .get()
        .then((purchases) {
      int kchcha = 0;
      int pakka = 0;
      double kchchaValue = 0;
      double pakkaValue = 0;
      purchases.docs.forEach((purchase) {
        if (purchase['transactionType'] == 'kachcha') {
          kchcha++;
          kchchaValue += purchase['invoiceAmount'];
        } else {
          pakka++;
          pakkaValue += purchase['invoiceAmount'];
        }
      });

      setState(() {
        noOfpurchaseKachcha = kchcha;
        noOfpurchasePakka = pakka;
        kachchaPurchaseValue = kchchaValue;
        pakkaPurchaseValue = pakkaValue;
      });
    });

    FirebaseFirestore.instance
        .collection('paymentin')
        .where('date',
            isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
        .get()
        .then((paymentins) {
      int noOfpaymentin = paymentins.docs.length;
      double paymentInamount = 0;
      paymentins.docs.forEach((paymentin) {
        paymentInamount += paymentin['amount'];
      });

      setState(() {
        totalPaymentinAmount = paymentInamount;
        totalnoOfpaymentin = noOfpaymentin;
      });
    });

    FirebaseFirestore.instance
        .collection('paymentout')
        .where('date',
            isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
        .get()
        .then((paymentouts) {
      int noOfpaymentout = paymentouts.docs.length;
      double paymentOutamount = 0;
      paymentouts.docs.forEach((paymentout) {
        paymentOutamount += double.parse(paymentout['amount']);
      });

      setState(() {
        totalPaymentoutAmount = paymentOutamount;
        totalnoOfpaymentout = noOfpaymentout;
      });
    });

    FirebaseFirestore.instance.collection('expense').where('date',isGreaterThanOrEqualTo: startDate,isLessThanOrEqualTo: endDate).get().then((expense){
      int noOfExpense = expense.docs.length;
      double totalExpenseAmt = 0;
      expense.docs.forEach((exp) {
        totalExpenseAmt += exp['amount'];
      });
      setState(() {
        totalExpenseAmount = totalExpenseAmt;
        totalExpenses = noOfExpense;
      });
    });

  }

  bool once = true;

  @override
  Widget build(BuildContext context) {
    if (once) {
      firebaseHandler();
      setState(() {
        once = false;
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
          // Stats for current month
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
            child: Text("Summary Report For ${DateFormat('yMMMM').format(DateTime.now())}",style: const TextStyle(fontWeight: FontWeight.bold),),
          ),
          Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // sales
              Card(
                      elevation: 4,
                    color: Colors.red.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SalesReport()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sales",
                            textAlign: TextAlign.left,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // pakka
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pakka: $noOfsalesPakka'),
                                  Text(NumberFormat("₹##,##,##0.00").format(pakkaSalesValue))
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('kachcha: $noOfsalesKachcha'),
                                  Text(NumberFormat("₹##,##,##0.00").format(kachchaSalesValue))
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total: ${noOfsalesKachcha + noOfsalesPakka}'),
                                  Text(NumberFormat("₹##,##,##0.00").format(kachchaSalesValue + pakkaSalesValue)
                                      )
                                ],
                              ),
                            ],
                          )
                        ]),
                  ),
                ),
              ),
              Card(
                      elevation: 4,
                    color: Colors.blue.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseReport()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Purchase",
                            textAlign: TextAlign.left,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // pakka
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pakka: $noOfpurchasePakka'),
                                  Text(NumberFormat("₹##,##,##0.00").format(pakkaPurchaseValue))
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('kachcha: $noOfpurchaseKachcha'),
                                  Text(NumberFormat("₹##,##,##0.00").format(kachchaPurchaseValue))
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Total: ${noOfpurchaseKachcha + noOfpurchasePakka}'),
                                  Text(NumberFormat("₹##,##,##0.00").format(pakkaPurchaseValue + kachchaPurchaseValue)
                                      )
                                ],
                              ),
                            ],
                          )
                        ]),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                          color: Colors.green.shade300,
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePaymentIn()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Payment In: $totalnoOfpaymentin"),
                                Text(NumberFormat("₹##,##,##0.00").format(totalPaymentinAmount)),
                                
                              ]),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Color.fromARGB(255, 248, 235, 90),

                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePaymentOut()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment Out: $totalnoOfpaymentout",
                                  textAlign: TextAlign.left,
                                ),
                                    Text(NumberFormat("₹##,##,##0.00").format(totalPaymentoutAmount)),
                                
                              ]),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
              Row(
                children: [
                  
                  Expanded(
                    child: Card(
                      elevation: 4,
                        color: Color.fromARGB(255, 200, 118, 255),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Expense()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expenses: $totalExpenses",
                                  textAlign: TextAlign.left,
                                ),
                                    Text(NumberFormat("₹##,##,##0.00").format(totalExpenseAmount)),
                                
                              ]),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                          color: Color.fromARGB(255, 255, 150, 118),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        onTap: (){},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Balance: ",
                                  textAlign: TextAlign.left,
                                ),
                                    Text(NumberFormat("₹##,##,##0.00").format(totalPaymentinAmount+pakkaPurchaseValue+kachchaPurchaseValue -pakkaSalesValue-kachchaSalesValue-totalPaymentoutAmount-totalExpenseAmount)),
                                
                              ]),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ]),
          ),
        
          const Padding(
            padding:  EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: Divider(thickness: 1),),
              Text("Other Reports 👇"),
              Expanded(child: Divider(thickness: 1,))
            ],),
          ),
          const Padding(
            padding:  EdgeInsets.all(2.0),
            child: Row(children: [
              Expanded(child: Icon(Icons.keyboard_double_arrow_left_sharp)),
              Text("Scroll"),
              Expanded(child: Icon(Icons.keyboard_double_arrow_right_sharp))
            ],),
          ),
          SizedBox(
            height: 200,
            child: Scrollbar(
              child: GridView(
            
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                primary: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.5,),children: reports.map<Widget>((report){
                return Card(
                  elevation: 5,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => report['widget']));
                    },
                    child: Center(child: Text(report['title'],maxLines: 2,textAlign: TextAlign.center,))),
                );
              }).toList(),),
            ),
          ),
        ]),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
