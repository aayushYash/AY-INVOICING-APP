import 'package:ay_invoiving_app/components/AddItemScreen.dart';
import 'package:ay_invoiving_app/helper/input_validator.dart';
import 'package:ay_invoiving_app/provider/company_data.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesWidget extends StatefulWidget {
  bool edit, view;
  Map data;
  SalesWidget(
      {Key? key, required this.edit, required this.view, required this.data})
      : super(key: key);

  @override
  _SalesWidgetState createState() {
    return _SalesWidgetState();
  }
}

enum Company { jrm, ayi }

enum TransactionType { pakka, kachcha }

class _SalesWidgetState extends State<SalesWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();
  String invoiceNumber = "";
  Company? _company = Company.jrm;
  TransactionType? _transactionType = TransactionType.kachcha;
  String customerName = '';

  final TextEditingController _ewaybillNumber = TextEditingController();
  TextEditingController shippingAddress = TextEditingController();
  TextEditingController transportName = TextEditingController();
  TextEditingController vehicleNumber = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController powo = TextEditingController();

  List<String> PartyNameList = [];
  List<Map> BillingItems = [];
  double totalDiscount = 0;
  double totalTaxAmount = 0;
  double grandTotal = 0;
  int stateUpdated = 0;
  bool customerError = false;

  final _formKey = GlobalKey<FormState>();
  bool _billingItemError = false;
  List data = [];

  updateInvoiceNumber() {
    var i = _company == Company.ayi ? 0 : 1;
    var ii = _transactionType.toString().split('.')[1];
    if (ii == "kachcha") {
      setState(() {
        invoiceNumber =
            "${_company.toString().split('.')[1].toUpperCase()}/${data[i][ii] + 1}";
      });
    } else {
      setState(() {
        invoiceNumber =
            "${_company.toString().split('.')[1].toUpperCase()}/24-25/${data[i][ii] + 1}";
      });
    }
  }

  fetchInvoiceNumber() {
    FirebaseFirestore.instance.collection('company').get().then((value) {
      value.docs.forEach((element) {
        data = [...data, element.data()];
      });
      var i = _company == Company.ayi ? 0 : 1;
      var ii = _transactionType.toString().split('.')[1];
      if (!widget.edit || !widget.view) {
        if (ii == "kachcha") {
          setState(() {
            invoiceNumber =
                "${_company.toString().split('.')[1].toUpperCase()}/${data[i][ii] + 1}";
          });
        } else {
          setState(() {
            invoiceNumber =
                "${_company.toString().split('.')[1].toUpperCase()}/23-24/${data[i][ii] + 1}";
          });
        }
      }
    });
  }

  updateSaleHandler(data, admin, user, time, dateChanged) {
    List users = ["Aayush", "Ashok", "Raj"];
    if (admin) users.remove(user);

    List newbilledItems = data['billedItem'];
    List oldbilledItems = widget.data['billedItem'];

    Map widgetData = widget.data;
    DateTime widgetDate = widget.data['invoiceDate'].toDate();
    widgetData['invoiceDate'] = widgetDate;

    bool needToUpdate = false;
    bool notLoop = true;
    String changedData = "";
    if (!listEquals(oldbilledItems, newbilledItems)) changedData = "BilledItem";
    if (listEquals(newbilledItems, oldbilledItems)) {
      widgetData.forEach((key, value) {
        if (key != 'timestamp' &&
            key != 'generatedBy' &&
            key != 'approved' &&
            key != 'billedItem') {
          print("$key ${data[key] == widget.data[key]}");
          if (data[key] != widget.data[key]) {
            needToUpdate = true;
            notLoop = false;
            changedData = "$changedData $key";
          }
        }
      });
      if (!needToUpdate) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Nothing to update!!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          int count = 0;

                          Navigator.of(context)
                              .popUntil((route) => count++ >= 2);
                        },
                        child: Text("Ok"))
                  ],
                ));

        return;
      }
    }

    if (notLoop) {
      widgetData.forEach((key, value) {
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
      String monthRef =
          "${widget.data['invoiceDate'].month}${widget.data['invoiceDate'].year}";

      if (dateChanged) {
        FirebaseFirestore.instance
            .collection('product')
            .doc(item['name'])
            .collection('stock')
            .doc(monthRef)
            .update({
          'actual': FieldValue.increment(item['quantity']),
        });
      } else {
        FirebaseFirestore.instance
            .collection('product')
            .doc(item['name'])
            .collection('stock')
            .doc(monthRef)
            .update({
          'actual': FieldValue.increment(item['quantity']),
          'pakka': FieldValue.increment(item['quantity']),
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
      if (dateChanged) {
        stockRef.get().then((itemStock) {
          if (itemStock.exists) {
            stockRef.update({
              'actual': FieldValue.increment(-item['quantity']),
              'pakka': FieldValue.increment(-item['quantity'])
            });
          } else {
            stockRef
                .set({'actual': -item['quantity'], 'pakka': -item['quantity']});
          }
        });
      } else {
        stockRef.update({
          'actual': FieldValue.increment(-item['quantity']),
          'pakka': FieldValue.increment(-item['quantity'])
        });
      }
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
          'type': 'sale',
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
          'type': 'sale',
          'amount': data['invoiceAmount'],
        }
      ])
    });

    FirebaseFirestore.instance
        .collection('sales')
        .doc(data['invoiceNumber'].toString().replaceAll('/', ':'))
        .update(data);

    FirebaseFirestore.instance.collection('log').add({
      'approved': admin,
      'data':
          "Invoice Value: ${data['invoiceAmount']} | Invoice No: ${data['invoiceNumber']} Changed Data: $changedData",
      'generatedBy': user,
      'notSeen': users,
      'subTitle': data['customerName'],
      'time': DateTime.now(),
      'title': 'Sale Updated',
    });

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Sale Updated'),
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

    return;
  }

  FirebaseHandler(Map<String, dynamic> data, user, admin, time) {
    List users = ["Aayush", "Ashok", "Raj"];

    if (admin) users.remove(user);

    FirebaseFirestore.instance
        .collection('sales')
        .doc(data['invoiceNumber'].toString().replaceAll('/', ':'))
        .set(data)
        .then((value) {
      FirebaseFirestore.instance.collection('log').add({
        'title': 'Sale Generated',
        'time': DateTime.now(),
        'subTitle': data['customerName'],
        'generatedBy': user,
        'approved': admin,
        'data':
            "Invoice No:${data['invoiceNumber']} | Invoice Amount: ${data['invoiceAmount']}",
        'notSeen': users
      });

      data['billedItem']!.forEach((item) {
        var docRef =
            FirebaseFirestore.instance.collection('product').doc(item['name']);

        docRef.get().then((doc) {
          if (doc.exists) {
            if (data['transactionType'] == "kachcha") {
              var monthStockRef = docRef.collection('stock').doc(
                  "${data['invoiceDate'].month}${data['invoiceDate'].year}");

              monthStockRef.get().then((value) {
                if (value.exists) {
                  if (data['transactionType'] == "kachcha") {
                    monthStockRef.update(
                        {'actual': FieldValue.increment(-item['quantity'])});
                  } else {
                    monthStockRef.update(
                        {'actual': FieldValue.increment(-item['quantity'])});
                    monthStockRef.update(
                        {'pakka': FieldValue.increment(-item['quantity'])});
                  }
                } else {
                  if (data['transactionType'] == "kachcha") {
                    monthStockRef.set({});
                  } else {
                    monthStockRef.set({
                      'actual': -item['quantity'],
                      'pakka': -item['quantity']
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
                  .set({'actual': -item['quantity'], 'pakka': 0});
            } else {
              docRef
                  .collection('stock')
                  .doc(
                      "${data['invoiceDate'].month}${data['invoiceDate'].year}")
                  .set({
                'actual': -item['quantity'],
                'pakka': -item['quantity']
              });
            }
          }
        });

        var partyRef = FirebaseFirestore.instance
            .collection('party')
            .doc(data['customerName']);

        partyRef.get().then((party) {
          if (party.exists) {
            partyRef.update({
              'transactions': FieldValue.arrayUnion([
                {
                  'approved': admin,
                  'id': data['invoiceNumber'],
                  'time': DateTime(
                      data['invoiceDate'].year,
                      data['invoiceDate'].month,
                      data['invoiceDate'].day,
                      time.hour,
                      time.minute),
                  'type': 'sale',
                  'amount': data['invoiceAmount'],
                }
              ]),
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
                  'approved': admin,
                  'id': data['invoiceNumber'],
                  'time': DateTime(
                      data['invoiceDate'].year,
                      data['invoiceDate'].month,
                      data['invoiceDate'].day,
                      time.hour,
                      time.minute),
                  'type': 'sale',
                  'amount': data['invoiceAmount'],
                }
              ]
            });
          }
        });

        FirebaseFirestore.instance
            .collection('company')
            .doc(data['billingCompany'])
            .update({data['transactionType']: FieldValue.increment(1)});
      });
    }).whenComplete(() {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Invoice Generated'),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          stateUpdated = 0;
                        });
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                      child: const Text('OK'))
                ],
              ));
    });
    // Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<Map> billedItemData = [];
    widget.data['billedItem']?.forEach((item) {
      billedItemData.add(item);
    });

    if(widget.edit || widget.view){
    _company =
        widget.data['billingCompany'] == 'ayi' ? Company.ayi : Company.jrm;
    // invoiceNumber = widget.data['invoiceNumber'] == null ? fetchInvoiceNumber(): widget.data['invoiceNumber'];
    selectedDate = widget.data['invoiceDate'] == null ? DateTime.now(): widget.data['invoiceDate'].toDate();
    selectedTime = widget.data['invoiceDate'] == null ? TimeOfDay.now(): TimeOfDay(
        hour: widget.data['invoiceDate'].toDate().hour,
        minute: widget.data['invoiceDate'].toDate().minute);
    _transactionType = widget.data['transactionType'] == 'pakka'
        ? TransactionType.pakka
        : TransactionType.kachcha;
    customerName = widget.data['customerName'];
    _ewaybillNumber.text = widget.data['ewaybillNumber'];
    BillingItems = billedItemData;
    transportName.text = widget.data['transportName'];
    vehicleNumber.text = widget.data['vehicleNumber'];
    description.text = widget.data['description'];
    shippingAddress.text = widget.data['shippingAddress'];
    powo.text = widget.data['powo'].toString();

    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(stateUpdated.toString());
    final comData = context.watch<CompanyDataProvider>().data;
    final user = context.watch<UserProvider>().userName;
    final admin = context.watch<UserProvider>().admin;
    if (stateUpdated == 0) {
      if (widget.edit || widget.view) {
        List<Map> billedItemData = [];
        widget.data['billedItem']!.forEach((item) {
          billedItemData.add(item);
        });

        setState(() {
          _company = widget.data['billingCompany'] == 'ayi'
              ? Company.ayi
              : Company.jrm;
          invoiceNumber = widget.data['invoiceNumber'];
          selectedDate = widget.data['invoiceDate'].toDate();
          selectedTime = TimeOfDay(
              hour: widget.data['invoiceDate'].toDate().hour,
              minute: widget.data['invoiceDate'].toDate().minute);
          _transactionType = widget.data['transactionType'] == 'pakka'
              ? TransactionType.pakka
              : TransactionType.kachcha;
          customerName = widget.data['customerName'];
          _ewaybillNumber.text = widget.data['ewaybillNumber'];
          BillingItems = billedItemData;
          transportName.text = widget.data['transportName'];
          vehicleNumber.text = widget.data['vehicleNumber'];
          description.text = widget.data['description'];
          shippingAddress.text = widget.data['shippingAddress'];
          powo.text = widget.data['powo'].toString();
        });
      }

      if (!widget.edit && !widget.view) fetchInvoiceNumber();
      setState(() {
        FirebaseFirestore.instance.collection('party').get().then((value) {
          for (var element in value.docs) {
            PartyNameList = [element.id, ...PartyNameList];
          }
        });

        stateUpdated++;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Column(
                          children: [
                            const Text(
                              'Invoice Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Text(invoiceNumber)
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Date
                  Expanded(
                    child: InkWell(
                      onTap: widget.view ||
                              (widget.edit &&
                                  widget.data['transactionType'] == 'pakka')
                          ? null
                          : () async {
                              final DateTime? dateTime = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(3000));
                              if (dateTime != null) {
                                setState(() {
                                  selectedDate = dateTime;
                                });
                              }
                            },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.calendar_month, size: 18),
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Time
                  Expanded(
                    child: InkWell(
                      onTap: widget.view ||
                              (widget.edit &&
                                  widget.data['transactionType'] == 'pakka')
                          ? null
                          : () async {
                              TimeOfDay? newTime = await showTimePicker(
                                  context: context, initialTime: selectedTime!);
                              if (newTime != null) {
                                setState(() {
                                  selectedTime = newTime;
                                });
                              }
                            },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.access_time, size: 18),
                                  Text(
                                    "Time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              Text(
                                  '${selectedTime?.hour.toString()}:${selectedTime?.minute.toString()} '),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Billing Company

              Container(
                margin: const EdgeInsets.fromLTRB(10, 12, 10, 3),
                child: InputDecorator(
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(width: 1)),
                      labelText: 'Billing Company',
                      labelStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
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
                              if (widget.edit || widget.view) return;
                              setState(() {
                                _company = value;
                              });
                              updateInvoiceNumber();
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
                            visualDensity: const VisualDensity(vertical: 1),
                            activeColor: const Color(0xFFFB9D2F),
                            value: Company.ayi,
                            groupValue: _company,
                            onChanged: (Company? value) {
                              if (widget.edit || widget.view) return;
                              setState(() {
                                _company = value;
                              });
                              updateInvoiceNumber();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction Type
              Container(
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 3),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputDecorator(
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 8, 5, 5),
                            alignLabelWithHint: true,
                            labelText: 'Transaction Type',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15)),
                            labelStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900)),
                        child: Row(
                          children: [
                            Flexible(
                              child: ListTile(
                                horizontalTitleGap: 0,
                                title: const Text(
                                  'Kachcha',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                leading: Radio<TransactionType?>(
                                  activeColor: const Color(0xFFFB9D2F),
                                  value: TransactionType.kachcha,
                                  groupValue: _transactionType,
                                  onChanged: (TransactionType? value) {
                                    if (widget.edit || widget.view) return;
                                    setState(() {
                                      _transactionType = value;
                                    });
                                    updateInvoiceNumber();
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
                                leading: Radio<TransactionType?>(
                                  activeColor: const Color(0xFFFB9D2F),
                                  value: TransactionType.pakka,
                                  groupValue: _transactionType,
                                  onChanged: (TransactionType? value) {
                                    if (widget.edit || widget.view) return;
                                    setState(() {
                                      _transactionType = value;
                                    });
                                    updateInvoiceNumber();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              ),

              // Customer name👇👇

              Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 2),
                  child: RawAutocomplete(
                      initialValue: TextEditingValue(text: customerName),
                      optionsBuilder: (textEditingValue) {
                        // var party = [];

                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return PartyNameList.where((option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
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
                          readOnly: (widget.edit || widget.view),
                          validator: (text) => inputValidator(text!),
                          focusNode: focusNode,
                          controller: textEditingController,
                          onChanged: (value) {
                            setState(() {
                              customerName = value;
                              if (value.isNotEmpty) customerError = false;
                            });
                          },
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
                          child: SizedBox(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: options.map((opt) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 4),
                                      child: InkWell(
                                          onTap: () {
                                            onSelected(opt);
                                          },
                                          child: Card(
                                              color: Colors.amber,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(opt),
                                              ))),
                                    );
                                  }).toList()),
                            ),
                          ),
                        );
                      })),
              if (_transactionType.toString().split('.')[1] == 'pakka')
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _ewaybillNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'Ewaybill Number',
                    ),
                  ),
                ),
              if (customerError)
                const Text("Can't be empty",
                    style: TextStyle(color: Colors.red)),
              // Billing Items section
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

              // Each entered Items.
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
                    double discount = (subtotal * item['discount'] * 0.01);
                    double gst = (subtotal - discount) * (item['gst'] * 0.01);
                    totalTaxAmount += gst;

                    totalDiscount += discount;
                    double total = (subtotal + gst - discount).roundToDouble();
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
                                    Text("\u{20B9} ${total.round()}",
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
              if (BillingItems.length != 0)
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Discount Amount:'),
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
                          Text('Total Tax Amount:'),
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

              // add new billing item button
              OutlinedButton(
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

              if (BillingItems.isEmpty && _billingItemError)
                const Text(
                  "Add atleast one item",
                  style: TextStyle(color: Colors.red),
                ),
              const Divider(
                height: 5,
                thickness: 2,
                indent: 10,
                endIndent: 10,
                color: Colors.amber,
              ),
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
              const Text(
                'Transportion Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 3),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping Address'),
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
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: description,
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
              )
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ),
        if (!widget.view)
          Container(
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFFFB9D2F))),
              onPressed: () {
                // debugPrint(context.watch<CompanyDataProvider>().data.toString());
                if (customerName.isEmpty) {
                  setState(() {
                    customerError = true;
                  });
                }

                if (_formKey.currentState!.validate()) {
                  Map<String, dynamic> data = {
                    'invoiceDate': DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime!.hour,
                        selectedTime!.minute),
                    // 'invoiceTime': selectedTime,
                    'invoiceNumber': invoiceNumber,
                    'billingCompany': _company.toString().split('.')[1],
                    'transactionType':
                        _transactionType.toString().split('.')[1],
                    'customerName': customerName.toUpperCase(),
                    'ewaybillNumber': _ewaybillNumber.text,
                    'billedItem': BillingItems,
                    'shippingAddress': shippingAddress.text,
                    'transportName': transportName.text,
                    'vehicleNumber': vehicleNumber.text,
                    'description': description.text,
                    'invoiceAmount': grandTotal.roundToDouble(),
                    'taxableAmount': totalTaxAmount,
                    'approved': admin,
                    'powo': powo.text,
                    'timestamp': DateTime.now(),
                    'generatedBy': user
                  };
                  if (BillingItems.isEmpty) {
                    setState(() {
                      _billingItemError = true;
                    });
                  }

                  widget.edit
                      ? updateSaleHandler(
                          data,
                          admin,
                          user,
                          selectedTime,
                          data['invoiceDate'].compareTo(
                                  widget.data['invoiceDate'].toDate()) ==
                              0)
                      : FirebaseHandler(data, user, admin, selectedTime);
                }
                _formKey.currentState?.reset();
                // Navigator.pop(context);
              },
              child: Text(
                widget.edit ? 'Update' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
      ],
    );
  }
}
