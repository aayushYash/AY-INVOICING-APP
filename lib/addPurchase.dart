import 'package:ay_invoiving_app/helper/input_validator.dart';
import 'package:ay_invoiving_app/ledger.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

import 'components/AddItemScreen.dart';

class Purchase extends StatefulWidget {
  var data, edit, view;
  Purchase({super.key, this.data, this.edit, this.view});
  @override
  State<StatefulWidget> createState() {
    return PurchaseState();
  }
}

enum Company { jrm, ayi }

enum TransactionType { kachcha, pakka }

int AddTotalAmount(List items) {
  int grandTotal = 0;
  items.forEach((item) {
    double subtotal = (item['quantity'] * item['rate']);
    String discount = (subtotal * item['discount'] / 100).toStringAsFixed(2);
    String gst = ((subtotal - double.parse(discount)) * item['gst'] / 100)
        .toStringAsFixed(2);
    int total = (subtotal + double.parse(gst) - double.parse(discount)).round();
    grandTotal = grandTotal + total;
  });

  return grandTotal;
}

double AddTotalTax(List items) {
  double totalTax = 0;
  items.forEach((item) {
    double subtotal = (item['quantity'] * item['rate']);
    String discount = (subtotal * item['discount'] / 100).toStringAsFixed(2);
    String gst = ((subtotal - double.parse(discount)) * item['gst'] / 100)
        .toStringAsFixed(2);
    totalTax = totalTax + double.parse(gst);
  });

  return totalTax;
}

double AddTotalDiscount(List items) {
  double totalDiscount = 0;
  items.forEach((item) {
    double subtotal = (item['quantity'] * item['rate']);
    String discount = (subtotal * item['discount'] / 100).toStringAsFixed(2);
    totalDiscount = totalDiscount + double.parse(discount);
  });

  return totalDiscount;
}

class PurchaseState extends State<Purchase> {
  updatepurchaseHandler(data, admin, user, dateChanged) {
    List users = ["Aayush", "Ashok", "Raj"];

    List newbilledItems = data['billedItem'];
    List oldbilledItems = widget.data['billedItem'];

    if (admin) users.remove(user);

    bool needtoUpdate = false;

    widget.data['invoiceDate'] = widget.data['invoiceDate'].toDate();

    String changedData = "";

    bool notLoop = true;

    if (!listEquals(oldbilledItems, newbilledItems)) {
      changedData = "Products Updated";
    }

    if (listEquals(newbilledItems, oldbilledItems)) {
      widget.data.forEach((key, value) {
        if (key != 'timestamp' &&
            key != 'generatedBy' &&
            key != 'approved' &&
            key != 'billedItem') {
          if (data[key] != widget.data[key]) {
            needtoUpdate = true;
            changedData = "$changedData $key";
            notLoop = false;
          }
        }
      });
      if (!needtoUpdate) {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Nothing to update!!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          int count = 0;

                          Navigator.of(context)
                              .popUntil((route) => count++ >= 2);
                        },
                        child: const Text("Ok"))
                  ],
                ));
      }
    }

    if (notLoop) {
      widget.data.forEach((key, value) {
        if (key != 'timestamp' &&
            key != 'generatedBy' &&
            key != 'approved' &&
            key != 'billedItem') {
          print("$key ${data[key] == widget.data[key]}");
          if (data[key] != widget.data[key]) {
            changedData = "$changedData $key";
          }
        }
      });
    }

    oldbilledItems.forEach((item) {
      print(item['name']);
      String monthRef =
          "${widget.data['invoiceDate'].month}${widget.data['invoiceDate'].year}";

      if (widget.data['transactionType'] == 'kachcha') {
        FirebaseFirestore.instance
            .collection('product')
            .doc(item['name'])
            .collection('stock')
            .doc(monthRef)
            .update({
          'actual': FieldValue.increment(-item['quantity']),
        });
      } else {
        FirebaseFirestore.instance
            .collection('product')
            .doc(item['name'])
            .collection('stock')
            .doc(monthRef)
            .update({
          'actual': FieldValue.increment(-item['quantity']),
          'pakka': FieldValue.increment(-item['quantity']),
        });
      }
    });

    newbilledItems.forEach((item) {
      String monthRef =
          "${data['invoiceDate'].month}${data['invoiceDate'].year}";
      var stockRef = FirebaseFirestore.instance
          .collection('product')
          .doc(item['name'])
          .collection('stock')
          .doc(monthRef);

      stockRef.get().then((itemStock) {
        if (itemStock.exists) {
          if (data['transactionType'] == 'kachcha') {
            stockRef.update({
              'actual': FieldValue.increment(item['quantity']),
            });
          } else {
            stockRef.update({
              'actual': FieldValue.increment(item['quantity']),
              'pakka': FieldValue.increment(item['quantity']),
            });
          }
        } else {
          if (data['transactionType'] == 'kachcha') {
            stockRef.set({
              'actual': item['quantity'],
            });
          } else {
            stockRef
                .set({'actual': item['quantity'], 'pakka': item['quantity']});
          }
        }
      });
    });

    FirebaseFirestore.instance
        .collection('party')
        .doc(data['customerName'])
        .update({
      'transactions': FieldValue.arrayRemove([
        {
          'approved': widget.data['approved'],
          'id': widget.data['invoiceNumber'],
          'time': widget.data['invoiceDate'],
          'type': 'purchase',
          'amount': widget.data['invoiceAmount'],
        }
      ])
    });

    FirebaseFirestore.instance
        .collection('party')
        .doc(data['customerName'])
        .update({
      'transactions': FieldValue.arrayUnion([
        {
          'approved': admin,
          'id': data['invoiceNumber'],
          'time': data['invoiceDate'],
          'type': 'purchase',
          'amount': data['invoiceAmount'],
        }
      ])
    });

    FirebaseFirestore.instance
        .collection('purchase')
        .doc(data['invoiceNumber'].toString().replaceAll('/', ':'))
        .update(data);

    FirebaseFirestore.instance.collection('log').add({
      'approved': admin,
      'data':
          "Invoice Value: ${data['invoiceAmount']} | Invoice No: ${data['invoiceNumber']} Data Changed: $changedData",
      'generatedBy': user,
      'notSeen': users,
      'subTitle': data['customerName'],
      'time': DateTime.now(),
      'title': 'Purchase Updated',
    });

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Purchase Updated'),
              actions: [
                TextButton(
                    onPressed: () {
                      int count = 0;
                      return Navigator.of(context)
                          .popUntil((_) => count++ >= 2);
                    },
                    child: const Text("OK"))
              ],
            ));
  }

  handleFirebase(data, user, admin) {
    print(data.toString());
    List users = ['Aayush', 'Ashok', 'Raj'];

    if (admin) users.remove(user);

    try {
      var purchaseRef = FirebaseFirestore.instance
          .collection('purchase')
          .doc(data['invoiceNumber'].toString().replaceAll('/', ':'));

      purchaseRef.get().then((doc) {
        if (doc.exists) {
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("${data['invoiceNumber']} already exists"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          },
                          child: const Text("Ok"))
                    ],
                  ));
        } else {
          purchaseRef.set(data).then((purchaseDoc) async {
            FirebaseFirestore.instance.collection('log').add({
              'title': "Purchase",
              'subTitle': data['customerName'],
              'approved': admin,
              'generatedBy': user,
              'data':
                  "Invoice: ${data['invoiceNumber']} | Amount: ₹${NumberFormat("##,##,#00.0").format(data['invoiceAmount'])}",
              'time': DateTime.now(),
              'notSeen': users,
            });

            var partyRef = FirebaseFirestore.instance
                .collection('party')
                .doc(data['customerName']);

            partyRef.get().then((partyDoc) {
              if (partyDoc.exists) {
                partyRef.update({
                  'transactions': FieldValue.arrayUnion([
                    {
                      'amount': data['invoiceAmount'],
                      'approved': admin,
                      'id': data['invoiceNumber'],
                      'time': data['invoiceDate'],
                      'type': 'purchase'
                    }
                  ])
                });
              } else {
                partyRef.set({
                  'billingAddress': '',
                  'contactPerson': '',
                  'gstin': '',
                  'openingBalance': 0,
                  'partyName': data['customerName'],
                  'shippingAddress': '',
                  'transactions': [
                    {
                      'amount': data['invoiceAmount'],
                      'approved': admin,
                      'id': data['invoiceNumber'],
                      'time': data['invoiceDate'],
                      'type': 'purchase'
                    }
                  ]
                });
              }
            });

            data['billedItem'].forEach((item) async {
              var docRef = FirebaseFirestore.instance
                  .collection('product')
                  .doc(item['name']);

              docRef.get().then((doc) {
                if (doc.exists) {
                  if (data['transactionType'] == "kachcha") {
                    var monthStockRef = docRef.collection('stock').doc(
                        "${data['invoiceDate'].month}${data['invoiceDate'].year}");

                    monthStockRef.get().then((value) {
                      if (value.exists) {
                        if (data['transactionType'] == "kachcha") {
                          monthStockRef.update({
                            'actual': FieldValue.increment(item['quantity'])
                          });
                        } else {
                          monthStockRef.update({
                            'actual': FieldValue.increment(item['quantity'])
                          });
                          monthStockRef.update({
                            'pakka': FieldValue.increment(item['quantity'])
                          });
                        }
                      } else {
                        if (data['transactionType'] == "kachcha") {
                          monthStockRef.set({});
                        } else {
                          monthStockRef.set({
                            'actual': item['quantity'],
                            'pakka': item['quantity']
                          });
                        }
                      }
                    });
                  }
                } else {
                  docRef.set({
                    'description': '',
                    'gst': item['gst'],
                    'hsn': '',
                    'itemName': item['name'],
                    'rate': item['rate'],
                    'unit': item['unit'],
                    'openingActualStock': 0,
                    'openingPakkaStock': 0,
                  });

                  if (data['transactionType'] == "kachcha") {
                    docRef
                        .collection('stock')
                        .doc(
                            "${data['invoiceDate'].month}${data['invoiceDate'].year}")
                        .set({'actual': item['quantity'], 'pakka': 0});
                  } else {
                    docRef
                        .collection('stock')
                        .doc(
                            "${data['invoiceDate'].month}${data['invoiceDate'].year}")
                        .set({
                      'actual': item['quantity'],
                      'pakka': item['quantity']
                    });
                  }
                }
              });
            });
          });
        }
      }).whenComplete(() {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Purchase Add"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          int count = 0;
                          Navigator.of(context)
                              .popUntil((route) => count++ >= 2);
                        },
                        child: const Text("Ok"))
                  ],
                ));
      });
    } on FirebaseException catch (e) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.code.toString().replaceAll('-', " ")),
              ));
    }
  }

  fetchPartyList() {
    List<String> list = [];
    FirebaseFirestore.instance.collection('party').get().then((parties) {
      for (var element in parties.docs) {
        list.add(element.id);
      }
    });

    setState(() {
      PartyNameList = list;
    });
  }

  TextEditingController invoiceNumber = TextEditingController();
  TextEditingController powo = TextEditingController();
  DateTime invoiceDate = DateTime.now();
  Company? _company = Company.jrm;
  TransactionType? _transactionType = TransactionType.kachcha;
  // ignore: non_constant_identifier_names
  List<String> PartyNameList = [];
  String customerName = '';
  final TextEditingController _ewaybillNumber = TextEditingController();
  TextEditingController shippingAddress = TextEditingController();
  TextEditingController transportName = TextEditingController();
  TextEditingController vehicleNumber = TextEditingController();
  final TextEditingController _description = TextEditingController();
  // ignore: non_constant_identifier_names
  List<Map> BillingItems = [];
  double totalDiscount = 0;
  double totalTaxAmount = 0;
  double grandTotal = 0;
  int state = 0;
  // ignore: prefer_typing_uninitialized_variables
  var user, admin;
  final _formKey = GlobalKey<FormState>();
  String invoiceNumberError = "";

  @override
  Widget build(BuildContext context) {
    if (state == 0) {
      setState(() {
        user = context.watch<UserProvider>().userName;
        admin = context.watch<UserProvider>().admin;

        if (widget.edit || widget.view) {
          List<Map> billedItemData = [];
          widget.data['billedItem'].forEach((item) {
            billedItemData.add(item);
          });

          _company = widget.data['purchaseInCompany'] == 'ayi'
              ? Company.ayi
              : Company.jrm;
          invoiceNumber.text = widget.data['invoiceNumber'];
          invoiceDate = widget.data['invoiceDate'].toDate();
          _transactionType = widget.data['transactionType'] == 'pakka'
              ? TransactionType.pakka
              : TransactionType.kachcha;
          customerName = widget.data['customerName'];
          _ewaybillNumber.text = widget.data['ewaybillNumber'];
          BillingItems = billedItemData;
          transportName.text = widget.data['transportedName'];
          vehicleNumber.text = widget.data['vehicleNumber'];
          _description.text = widget.data['description'];
          shippingAddress.text = widget.data['shippingAddress'];
          powo.text = widget.data['powo'].toString();
        }

        fetchPartyList();
        state++;
      });
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.view
              ? 'View Purchase'
              : widget.edit
                  ? 'Update Purchase'
                  : 'Add Purchase')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0.5))),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: widget.edit || widget.view
                            ? null
                            : () {
                                showModalBottomSheet(

                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Padding(
                                          padding: MediaQuery.of(context).viewInsets,
                                          child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            height: 100,
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20))),
                                            child: TextFormField(
                                              validator: (text) =>
                                                  inputValidator(text!),
                                              keyboardType: TextInputType.text,
                                              controller: invoiceNumber,
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Done'))
                                        ],
                                      ),);
                                    });
                              },
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.black, width: 0.5))),
                          child: Column(
                            children: [
                              const Text('Invoice Number'),
                              Text(
                                invoiceNumberError.isNotEmpty &&
                                        invoiceNumber.text.isEmpty
                                    ? invoiceNumberError
                                    : invoiceNumber.text,
                                style: TextStyle(
                                    color: invoiceNumberError.isNotEmpty &&
                                            invoiceNumber.text.isEmpty
                                        ? Colors.red
                                        : Colors.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: widget.view
                            ? null
                            : () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: invoiceDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(3000),
                                );

                                if (selectedDate != null) {
                                  setState(() {
                                    invoiceDate = selectedDate;
                                  });
                                }
                              },
                        child: Column(
                          children: [
                            const Text('Date'),
                            Text(DateFormat.yMMMd().format(invoiceDate))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: InputDecorator(
                        expands: false,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          label: const Text(
                            'Purchase in',
                            style: TextStyle(
                                leadingDistribution:
                                    TextLeadingDistribution.even),
                          ),
                          labelStyle: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: ListTile(
                                horizontalTitleGap: 0,
                                title: const Text(
                                  'JRM',
                                  style: TextStyle(fontSize: 14),
                                ),
                                leading: Radio<Company>(
                                  activeColor: const Color(0xFFFB9D2F),
                                  value: Company.jrm,
                                  groupValue: _company,
                                  onChanged: (Company? value) {
                                    setState(() {
                                      _company = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: ListTile(
                                horizontalTitleGap: 0,
                                title: const Text(
                                  'A Y Industries',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                leading: Radio<Company>(
                                  visualDensity:
                                      const VisualDensity(vertical: 1),
                                  activeColor: const Color(0xFFFB9D2F),
                                  value: Company.ayi,
                                  groupValue: _company,
                                  onChanged: (Company? value) {
                                    setState(() {
                                      _company = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width - 30,
                      child: InputDecorator(
                        expands: false,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          label: const Text(
                            'Transaction Type',
                            style: TextStyle(
                                leadingDistribution:
                                    TextLeadingDistribution.even),
                          ),
                          labelStyle: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: ListTile(
                                horizontalTitleGap: 0,
                                title: const Text(
                                  'Kachcha',
                                  style: TextStyle(fontSize: 14),
                                ),
                                leading: Radio<TransactionType>(
                                  activeColor: const Color(0xFFFB9D2F),
                                  value: TransactionType.kachcha,
                                  groupValue: _transactionType,
                                  onChanged: (TransactionType? value) {
                                    setState(() {
                                      _transactionType = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: ListTile(
                                horizontalTitleGap: 0,
                                title: const Text(
                                  'Pakka',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                leading: Radio<TransactionType>(
                                  visualDensity:
                                      const VisualDensity(vertical: 1),
                                  activeColor: const Color(0xFFFB9D2F),
                                  value: TransactionType.pakka,
                                  groupValue: _transactionType,
                                  onChanged: (TransactionType? value) {
                                    setState(() {
                                      _transactionType = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: RawAutocomplete(
                          initialValue: TextEditingValue(text: customerName),
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return PartyNameList.where((option) {
                              return option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (option) {
                            setState(() {
                              customerName = option.toString();
                            });
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextFormField(
                              onTap: null,
                              readOnly: widget.edit || widget.view,
                              validator: (value) => inputValidator(value!),
                              focusNode: focusNode,
                              controller: textEditingController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 8, 5, 5),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  labelText: 'Customer Name'),
                            );
                          },
                          optionsViewBuilder: (BuildContext context,
                              void Function(String) onSelected,
                              Iterable<String> options) {
                            return Material(
                              color: Colors.white,
                              child: SizedBox(
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  child: Column(
                                      children: options.map((opt) {
                                    return InkWell(
                                        onTap: () {
                                          onSelected(opt);
                                        },
                                        child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.only(
                                                right: 40),
                                            child: Card(
                                                color: Colors.amber,
                                                child: Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Text(opt),
                                                ))));
                                  }).toList()),
                                ),
                              ),
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_transactionType.toString().split('.')[1] == 'pakka')
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          child: TextFormField(
                            controller: _ewaybillNumber,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 10),
                                labelText: 'Ewaybill Number',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          )),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.amber),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: Text(
                    'Billing Items',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 0, maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                      children: BillingItems.mapIndexed((index, item) {
                    if (index == 0) {
                      totalDiscount = 0;
                      totalTaxAmount = 0;
                      grandTotal = 0;
                    }
                    double r = item['rate'];
                    if (_transactionType.toString().split('.')[1] ==
                        'kachcha') {
                      item['gst'] = 0.0;
                    } else if (item['inclTax']) {
                      r = double.parse(
                          (item['rate'] / (1 + (item['gst'] * 0.01)))
                              .toStringAsFixed(2));
                    }
                    double subtotal = (item['quantity'] * r);
                    double discount = (subtotal  * item['discount'] * 0.01);
                    double gst = (subtotal - discount) * (item['gst'] * 0.01);
                    totalTaxAmount += gst;

                    totalDiscount += discount;
                    double total = (subtotal + gst - discount);
                    grandTotal += total;

                    return InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => AddItemWidget(
                                      _transactionType
                                              .toString()
                                              .split('.')[1] ==
                                          'pakka',
                                      item,
                                      true))));
                          setState(() {
                            BillingItems[index] = result;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black12,
                              border:
                                  Border.all(width: 1, color: Colors.blueGrey)),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 230, 229, 229),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.blueGrey)),
                                        child: Text(
                                          '# ${index + 1}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12),
                                        )),
                                    Container(
                                      margin: const EdgeInsets.only(left: 13),
                                      child: Text(item['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("\u{20B9} $total",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15)),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          BillingItems.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Item Subtotal'),
                                Text(
                                    "${NumberFormat("##,##,#00.00").format(item['quantity'])} ${item['unit']} x \u{20B9} ${NumberFormat("##,##,#00.00").format(r)} = \u{20B9} ${NumberFormat("##,##,#00.00").format(subtotal)}")
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Discount(%): ${item['discount'].toInt()}"),
                                Text(
                                    "\u{20B9} ${NumberFormat("##,##,#00.00").format(discount)}")
                              ],
                            ),
                            if (_transactionType.toString().split('.')[1] ==
                                'pakka')
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tax GST@ ${item['gst']}%"),
                                  Text(
                                      "\u{20B9} ${NumberFormat("##,##,#00.00").format(gst)}")
                                ],
                              )
                          ]),
                        ));
                  }).toList()),
                ),
              ),
              if (BillingItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Discount Amount:'),
                        Text(
                          '\u{20B9}${NumberFormat("##,##,#00.00").format(totalDiscount)}',
                          textAlign: TextAlign.right,
                        )
                      ],
                    ),
                    if (_transactionType.toString().split('.')[1] == 'pakka')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Tax Amount:'),
                          Text(
                            '\u{20B9}${NumberFormat("##,##,#00.00").format(totalTaxAmount)}',
                            textAlign: TextAlign.right,
                          )
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Invoice Amount'),
                        Text(
                            '\u{20B9}${NumberFormat("##,##,#00.00").format(grandTotal.roundToDouble())}')
                      ],
                    )
                  ]),
                ),
              OutlinedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: widget.view
                      ? null
                      : () async {
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => AddItemWidget(
                                      _transactionType
                                              .toString()
                                              .split('.')[1] ==
                                          'pakka',
                                      null,
                                      false))));
                          setState(() {
                            if (result != null) {
                              BillingItems.add(result);
                            }
                          });
                        },
                  child: const Icon(Icons.add)),
              const Text(
                'Other Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PO/WO'),
                    SizedBox(
                      width: 150,
                      height: 25,
                      child: TextFormField(
                        controller: powo,
                        decoration: const InputDecoration(
                          focusColor: Colors.amber,
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.amber,
                                  style: BorderStyle.solid)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 15),
                color: Colors.white,
                child: Column(
                  children: [
                    const Text(
                      'Transportion Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 3),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Place of Delivery'),
                              SizedBox(
                                width: 150,
                                height: 25,
                                child: TextFormField(
                                  controller: shippingAddress,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    focusColor: Colors.amber,
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amber,
                                            style: BorderStyle.solid)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Transport Name'),
                              SizedBox(
                                width: 150,
                                height: 25,
                                child: TextFormField(
                                  controller: transportName,
                                  decoration: const InputDecoration(
                                    focusColor: Colors.amber,
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amber,
                                            style: BorderStyle.solid)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Vehicle Number'),
                              SizedBox(
                                width: 150,
                                height: 25,
                                child: TextFormField(
                                  controller: vehicleNumber,
                                  decoration: const InputDecoration(
                                    focusColor: Colors.amber,
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amber,
                                            style: BorderStyle.solid)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ]),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 260,
                            child: TextField(
                              controller: _description,
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 8, 5, 5),
                                  alignLabelWithHint: true,
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ),
        widget.view
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFB9D2F)),
                width: MediaQuery.of(context).size.width / 2 - 20,
                child: TextButton(
                  onPressed: () {
                    if (invoiceNumber.text.isEmpty) {
                      setState(() {
                        invoiceNumberError = "Can't be empty";
                      });
                    }

                    if (_formKey.currentState!.validate()) {
                      Map<String, dynamic> data = {
                        'invoiceNumber': invoiceNumber.text,
                        'invoiceDate': invoiceDate,
                        'purchaseInCompany':
                            _company.toString().split('.').last,
                        'transactionType':
                            _transactionType.toString().split('.').last,
                        'customerName': customerName,
                        'ewaybillNumber': _ewaybillNumber.text,
                        'billedItem': BillingItems,
                        'shippingAddress': shippingAddress.text,
                        'transportedName': transportName.text,
                        'vehicleNumber': vehicleNumber.text,
                        'description': _description.text,
                        'invoiceAmount': grandTotal,
                        'generatedBy': user,
                        'powo': powo.text,
                        'url': '',
                        'timestamp': DateTime.now()
                      };

                      widget.edit
                          ? updatepurchaseHandler(
                              data,
                              admin,
                              user,
                              widget.data['invoiceDate']
                                      .toDate()
                                      .compareTo(data['invoiceDate']) ==
                                  0)
                          : handleFirebase(data, user, admin);
                    }
                  },
                  child: Text(
                    widget.edit ? 'Update' : 'Save',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
      ],
      resizeToAvoidBottomInset: true,
    );
  }
}
