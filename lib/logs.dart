import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/purchaseReport.dart';
import 'package:ay_invoiving_app/sales.dart';
import 'package:ay_invoiving_app/salesReport.dart';
import 'package:ay_invoiving_app/screens/attendance.dart';
import 'package:ay_invoiving_app/screens/expense.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:ay_invoiving_app/screens/update_paymentin.dart';
import 'package:ay_invoiving_app/screens/update_paymentout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Logs extends StatefulWidget {
  @override
  _LogState createState() {
    return _LogState();
  }
}

class _LogState extends State<Logs> {
  updateFirebaseLog(user) async {
    await FirebaseFirestore.instance
        .collection('log')
        .where('notSeen', arrayContains: user)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((log) async {
          await FirebaseFirestore.instance
              .collection('log')
              .doc(log.id)
              .update({'notSeen': FieldValue.arrayRemove([user])});
        });
      }
    });
  }

  bool check = false;
  DateTime headerDate = DateTime(1999);
  int state = 0;
  bool notDisplayedYet = true;

  @override
  Widget build(context) {
    var user = context.watch<UserProvider>().userName;
    if (state == 0) {
      setState(() {
        updateFirebaseLog(user);
        state++;
      });
    }

    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('log')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              }
              if (snapshot.hasData) {
                if (snapshot.data.docs.length == 0) {
                  return const Center(
                    child: Text("No data to show"),
                  );
                }
                int index = 1;
                bool last = index == snapshot.data.docs.length;
                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(10.0),
                  children: snapshot.data.docs
                      .map<Widget>((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    if (last)
                      check = true;
                    else if (DateUtils.isSameDay(
                        snapshot.data.docs[index]['time'].toDate(),
                        data['time'].toDate())) {
                      check = false;
                    } else {
                      check = true;
                    }
                    index++;
                    if (index == snapshot.data.docs.length) {
                      index--;
                      last = true;
                    }
                    return Column(
                      children: [
                        if (check)
                          Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.amberAccent),
                              child: Text(DateFormat.yMMMEd()
                                          .format(data['time']?.toDate()) ==
                                      DateFormat.yMMMEd().format(DateTime.now())
                                  ? 'Today'
                                  : DateFormat.yMMMEd()
                                              .format(data['time']?.toDate()) ==
                                          DateFormat.yMMMEd().format(
                                              DateTime.now().subtract(
                                                  const Duration(days: 1)))
                                      ? 'Yesterday'
                                      : DateFormat.yMMMEd()
                                          .format(data['time']?.toDate()))),
                          if(data['notSeen'].contains(user) && notDisplayedYet) Text('Unseen Msgs'),
                        Card(
                          borderOnForeground: true,
                          shadowColor: data['title'].toString().toLowerCase().contains('sale') || data['title'].toLowerCase().contains('purchase') || data['title'].toLowerCase().contains('payment')
                              ? Color.fromARGB(255, 175, 76, 76)
                              : Color.fromARGB(255, 239, 222, 91),
                          elevation: 10,
                          surfaceTintColor: Colors.blue,
                          child: InkWell(
                            onTap: () {
                              if (data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains("sale")) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SalesReport()));
                              } else if (data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains("purchase")) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PurchaseReport()));
                              }
                              else if (data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains("expense")) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Expense()));
                              }
                              else if (data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains("payment in")) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UpdatePaymentIn()));
                              }
                              else if (data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains("payment out")) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UpdatePaymentOut()));
                              }
                              else if (data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains("staff")) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Attendance()));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(data['generatedBy'],
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          )),
                                      Row(
                                        children: [
                                          Text(DateFormat.yMMMMd()
                                              .format(data['time']?.toDate())
                                              .toString()),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(DateFormat.jm()
                                              .format(data['time']?.toDate())
                                              .toString())
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    data['title'].toString(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data['subTitle'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(data['data'].toString()),
                                  
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }).toList(),
                );
              }

              // Map<String,dynamic> data = snapshot.data!.;
              // if (headerDate !=
              //           DateFormat.yMd().format(snapshot.data?['time'])) {
              //         print(headerDate);
              //         headerDate =
              //             DateFormat.yMd().format(logList[index]['createdAt']);
              //         print(headerDate);
              //           }

              // return Card(
              //   borderOnForeground: true,
              //   shadowColor: logList[index]['approved']
              //       ? Colors.green
              //       : Colors.redAccent,
              //   elevation: 5,
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           mainAxisSize: MainAxisSize.max,
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text(logList[index]['createdBy'],
              //                 style: const TextStyle(
              //                   color: Colors.black87,
              //                 )),
              //             Row(
              //               children: [
              //                 Text(DateFormat.yMMMMd()
              //                     .format(logList[index]['createdAt'])
              //                     .toString()),
              //                 const SizedBox(
              //                   width: 10,
              //                 ),
              //                 Text(DateFormat.jm()
              //                     .format(logList[index]['createdAt'])
              //                     .toString())
              //               ],
              //             ),
              //           ],
              //         ),
              //         Text(
              //           logList[index]['TransactionType'],
              //           style: const TextStyle(
              //               fontSize: 20, fontWeight: FontWeight.bold),
              //         ),
              //         Text(logList[index]['details']),
              //         logList[index]['approved']
              //             ? const Text(
              //                 'Approved',
              //                 style: TextStyle(color: Colors.green),
              //               )
              //             : Row(
              //                 mainAxisAlignment:
              //                     MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   const Text('Not Approved'),
              //                   Row(
              //                     children: [
              //                       IconButton(
              //                           onPressed: () {
              //                             showDialog(
              //                                 context: context,
              //                                 builder:
              //                                     (BuildContext context) {
              //                                   return AlertDialog(
              //                                     title:
              //                                         const Text('Approve ??'),
              //                                     content: const Text(
              //                                         'Are you sure want to approve this transaction.'),
              //                                     actions: [
              //                                       IconButton(
              //                                         onPressed: () {
              //                                           // close popup
              //                                           Navigator.pop(
              //                                               context);
              //                                         },
              //                                         icon: const Icon(
              //                                             Icons.cancel),
              //                                         color: Colors.red,
              //                                       ),
              //                                       IconButton(
              //                                         onPressed: (
              //                                             // Implement confirm approval
              //                                             ) {},
              //                                         icon: const Icon(
              //                                             Icons.check),
              //                                         color: Colors.green,
              //                                       ),
              //                                     ],
              //                                   );
              //                                 });
              //                           },
              //                           icon: const Icon(
              //                             Icons.check,
              //                             color: Colors.green,
              //                           )),
              //                       IconButton(
              //                           onPressed: () {
              //                             showDialog(
              //                                 context: context,
              //                                 builder:
              //                                     (BuildContext context) {
              //                                   return AlertDialog(
              //                                     title:
              //                                         const Text('Reject ??'),
              //                                     content: const Text(
              //                                         'Are you sure want to reject this transaction.'),
              //                                     actions: [
              //                                       IconButton(
              //                                         onPressed: () {
              //                                           // close popup
              //                                           Navigator.pop(
              //                                               context);
              //                                         },
              //                                         icon: const Icon(
              //                                             Icons.cancel),
              //                                         color: Colors.red,
              //                                       ),
              //                                       IconButton(
              //                                         onPressed: (
              //                                             // Implement confirm approval
              //                                             ) {},
              //                                         icon: const Icon(
              //                                             Icons.check),
              //                                         color: Colors.green,
              //                                       ),
              //                                     ],
              //                                   );
              //                                 });
              //                           },
              //                           icon: const Icon(
              //                             Icons.cancel,
              //                             color: Colors.red,
              //                           ))
              //                     ],
              //                   ),
              //                 ],
              //               )
              //       ],
              //     ),
              //   ),
              // );

              return Text('');
            }));
  }
}
