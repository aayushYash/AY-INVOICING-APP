import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import '../components/AddItemScreen.dart';
import '../helper/input_validator.dart';
import '../provider/company_data.dart';

enum Company { jrm, ayi }

enum TransactionType { kachcha, pakka }

class AddQuotation extends StatefulWidget {
  final data, view, edit;
  const AddQuotation({super.key, this.data, this.view, this.edit});
  @override
  State<StatefulWidget> createState() {
    return AddQuotationState();
  }
}

class AddQuotationState extends State<AddQuotation> {
  List data = [];

  updateInvoiceNumber() {
    var i = _company == Company.ayi ? 0 : 1;
    setState(() {
      quotationNumber = "Quotation-${data[i]['quotation'] + 1}";
    });
  }

  fetchInvoiceNumber() {
    FirebaseFirestore.instance.collection('company').get().then((value) {
      value.docs.forEach((element) {
        data = [...data, element.data()];
      });
      var i = _company == Company.ayi ? 0 : 1;
      if (!widget.edit || !widget.view) {
        setState(() {
          quotationNumber = "Quotation-${data[i]['quotation'] + 1}";
        });
      }
    });
  }

  FirebaseHandler(
    data,
    user,
    admin,
  ) {
    final users = ["Ashok", "Aayush", "Raj"];

    if (admin) users.remove(user);

    FirebaseFirestore.instance
        .collection('quotation')
        .doc(data['quotationNumber'])
        .set(data)
        .then((value) {
      FirebaseFirestore.instance.collection('log').add({
        'title': "Quotation",
        'subTitle': data['customerName'],
        'data': "Quotation Amount: ${data['invoiceAmount']}",
        'approved': true,
        'generatedBy': user,
        'time': DateTime.now(),
        'notSeen': users,
      }).then((value) {
        FirebaseFirestore.instance
            .collection('company')
            .doc(data['billingCompany'])
            .update({'quotation': FieldValue.increment(1)});
      });
    });
    showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Quotation Added"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          int i = 0;
                          Navigator.of(context).popUntil((route) => i++ >= 2);
                        },
                        child: const Text("Ok"))
                  ],
                ));
    return;
  }

  updateQuotationHandler(Map<String, dynamic> data, user, admin) {}

  DateTime selectedDate = DateTime.now();
  String quotationNumber = '';
  Company _company = Company.jrm;
  TransactionType? _transactionType = TransactionType.kachcha;
  String customerName = "";
  List<String> PartyNameList = [''];
  List BillingItems = [];

  double grandTotal = 0;
  double totalTaxAmount = 0;
  double totalDiscount = 0;

  bool _billingItemError = false;

  TextEditingController powo = TextEditingController();
  TextEditingController shippingAddress = TextEditingController();
  TextEditingController vehicleNumber = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController transportName = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool customerError = false;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('party').get().then((value) {
      for (var element in value.docs) {
        PartyNameList = [element.id, ...PartyNameList];
      }
    });
    fetchInvoiceNumber();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<UserProvider>().admin;
    final user = context.watch<UserProvider>().userName;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Quotation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 55,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quotation No.'),
                            Text(quotationNumber)
                          ]),
                    ),
                    const VerticalDivider(
                      thickness: 2,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(3000));

                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date'),
                                Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')
                              ]),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Divider(thickness: 2, height: 2),

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
                              _company = value!;
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
                              _company = value!;
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
                                  // updateInvoiceNumber();
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
                                  // updateInvoiceNumber();
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
                        focusNode: focusNode,
                        readOnly: (widget.edit || widget.view),
                        validator: (text) => inputValidator(text!),
                        controller: textEditingController,
                        onChanged: (value) {
                          setState(() {
                            // if(value.isNotEmpty) customerError = false;
                            customerName = value;
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
                      debugPrint(options.length.toString());
                      return Material(
                        child: SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            child: Column(
                                children: options.map((opt) {
                              return InkWell(
                                  onTap: () {
                                    onSelected(opt);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.only(right: 60),
                                      child: Card(
                                          child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        child: Text(opt),
                                      ))));
                            }).toList()),
                          ),
                        ),
                      );
                    })),
            // if (_transactionType.toString().split('.')[1] == 'pakka')
            //   Container(
            //     margin: const EdgeInsets.all(10),
            //     child: TextFormField(
            //       controller: _ewaybillNumber,
            //       keyboardType: TextInputType.number,
            //       decoration: InputDecoration(
            //         contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
            //         alignLabelWithHint: true,
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         labelText: 'Ewaybill Number',
            //       ),
            //     ),
            //   ),
            if (customerError)
              const Text("Can't be empty", style: TextStyle(color: Colors.red)),
            // Billing Items section
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.amber),
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
                  if (_transactionType.toString().split('.')[1] == 'kachcha') {
                    item['gst'] = 0.0;
                  } else if (item['inclTax']) {
                    r = double.parse((item['rate'] / (1 + (item['gst'] * 0.01)))
                        .toStringAsFixed(2));
                  }
                  double subtotal = (item['quantity'] * r);
                  double discount = (subtotal * item['discount'] * 0.01);
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
                                    _transactionType.toString().split('.')[1] ==
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
                                  "${NumberFormat("##,##,#00.00").format(item['quantity'])} ${item['unit']} x \u{20B9} ${NumberFormat("##,##,#00.00").format(r)} = \u{20B9} ${NumberFormat("##,##,#00.##").format(subtotal)}")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Discount(%): ${item['discount'].toInt()}"),
                              Text(
                                  "\u{20B9} ${NumberFormat("##,##,#00.00").format(discount)}")
                            ],
                          ),
                          if (_transactionType.toString().split('.')[1] ==
                              'pakka')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

            // add new billing item button
            OutlinedButton(
                onPressed: widget.view
                    ? null
                    : () async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => AddItemWidget(
                                    _transactionType.toString().split('.')[1] ==
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
                                color: Colors.amber, style: BorderStyle.solid)),
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
                if (customerName.isEmpty) {
                  setState(() {
                    customerError = true;
                  });
                  return;
                }
                if (BillingItems.isEmpty) {
                  setState(() {
                    _billingItemError = true;
                  });
                  return;
                }

                Map<String, dynamic> data = {
                  'quotationDate': selectedDate,
                  // 'invoiceTime': selectedTime,
                  'quotationNumber': quotationNumber,
                  'billingCompany': _company.toString().split('.')[1],
                  'transactionType': _transactionType.toString().split('.')[1],
                  'customerName': customerName.toUpperCase(),
                  'ewaybillNumber': '',
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

                widget.edit
                    ? updateQuotationHandler(
                        data,
                        user,
                        admin,
                      )
                    : FirebaseHandler(
                        data,
                        user,
                        admin,
                      );

                Navigator.pop(context);
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
