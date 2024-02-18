import 'package:ay_invoiving_app/pdfs/party_ledger_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartyTransactionList extends StatefulWidget {
  final Map _partyData;
  const PartyTransactionList(this._partyData, {super.key});
  @override
  // ignore: library_private_types_in_public_api
  _PartyTransactionListState createState() {
    return _PartyTransactionListState();
  }
}

class _PartyTransactionListState extends State<PartyTransactionList> {
  List _displayTransactionList = [];
  int fetchSize = 5;

  handleList() {
    List transactionList = [];
    double bal = double.parse(widget._partyData['openingBalance'].toString());

    _sortedPartyTransaction.forEach((transaction) {
      if (transaction['approved'] != null && transaction['approved']) {
        double amt = double.parse(transaction['amount'].toString());
        if (transaction['type'] == 'sale') {
          transactionList.insert(0, {
            'type': 'sale',
            'time': transaction['time'],
            'id': transaction['id'],
            'amount': amt,
            'balance': bal - amt
          });
          bal -= amt;
        }

        if (transaction['type'] == 'purchase') {
          transactionList.insert(0, {
            'type': 'Purchase',
            'time': transaction['time'],
            'id': transaction['id'],
            'amount': amt,
            'balance': bal + amt
          });

          bal += amt;
        }
        if (transaction['type'] == 'paymentin') {
          transactionList.insert(0, {
            'type': 'Payment in',
            'time': transaction['time'],
            'id': transaction['id'],
            'amount': amt,
            'balance': bal + amt
          });
          bal += amt;
        }
        if (transaction['type'] == 'paymentout') {
          transactionList.insert(0,{
            'type': 'Payment out',
            'time': transaction['time'],
            'id': transaction['id'],
            'amount': amt,
            'balance': bal - amt
          });

          bal -= amt;
        }
      }
    });
    

    setState(() {
      _displayTransactionList = transactionList;
      balance = bal;
    });
  }

  List _sortedPartyTransaction = [];
  int state = 0;
  double balance = 0;
  int _displayResult = 0;
  bool _dataRemaining = false;
  @override
  Widget build(BuildContext context) {
    if (state == 0) {
      setState(() {
        balance = double.parse(widget._partyData['openingBalance'].toString());
        _sortedPartyTransaction = widget._partyData['transactions'];
        _sortedPartyTransaction.sort((a, b) => a['time'].toDate().compareTo(b['time'].toDate()));
      });
      handleList();
      state++;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._partyData['partyName']),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PartyLedgerPdfPreview(data: {'party': widget._partyData['partyName'],'time': DateTime.now(),'item': _displayTransactionList})));
          }, icon: const Icon(Icons.share))
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('Opening Balance'),
                  Text(
                    "₹${NumberFormat("##,##,##0.00").format(double.parse(widget._partyData['openingBalance'].toString()))}",
                    style: TextStyle(
                        color:
                            double.parse(widget._partyData['openingBalance'].toString()) < 0
                                ? Colors.green
                                : Colors.red),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 60),
            height: MediaQuery.of(context).size.height - 60,
            child: ListView(
              children: _displayTransactionList.map<Widget>((transaction) {
                DateTime invoiceDate = transaction['time'].toDate();
                debugPrint(transaction.toString());
                return Container(
                  decoration: transaction['balance'] == 0 ? const BoxDecoration(border: Border(top: BorderSide(color: Colors.black,width: 0.9))) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                        
                            flex: 2,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(transaction['type'].toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15,),))),
                        const SizedBox(width: 6,),
                        Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction['id'].toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                Text(
                                    "${invoiceDate.day}/${invoiceDate.month}/${invoiceDate.year} | ${invoiceDate.hour}: ${invoiceDate.minute}")
                              ],
                            )),
                        Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    "₹${NumberFormat("##,##,##0.00").format(transaction['amount'])}"),
                                Text(
                                  "Bal:₹${NumberFormat("##,##,##0.00").format(transaction['balance'].abs())}",
                                  style: TextStyle(
                                      color: transaction['balance'] < 0
                                          ? Colors.green
                                          : Colors.red),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Net Balance: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${NumberFormat("##,##,##0.00").format(balance.abs())}",
                      style: TextStyle(
                          color: balance < 0 ? Colors.green : Colors.red),
                    )
                  ]),
            ),
          ),
        ],
      ),

    );
  }
}
