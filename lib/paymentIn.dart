import 'package:ay_invoiving_app/components/ViewImage.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

import 'package:provider/provider.dart';

class PaymentInWidget extends StatefulWidget {
  final data, edit, view;
  const PaymentInWidget({Key? key, this.data, this.edit, this.view})
      : super(key: key);

  @override
  _PaymentInWidgetState createState() {
    return _PaymentInWidgetState();
  }
}

enum Company { jrm, ayi }

List<String> paymentMode = ['Cash', 'UPI', 'Bank Deposit', 'Cheque'];
// List<PickedFile> images = [];

class _PaymentInWidgetState extends State<PaymentInWidget> {
  Company _company = Company.jrm;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _partyNames = [];
  var dateFormat = DateFormat("dd/MM/yyyy");
  var timeFormat = TimeOfDayFormat.h_colon_mm_space_a;
  String _modeSelected = paymentMode[0];
  final TextEditingController _paymentAmount = TextEditingController();
  var _customerName = "";

  var admin, user;

  int state = 0;

  fetchPartyList() {
    List<String> _list = [];
    FirebaseFirestore.instance.collection('party').get().then((parties) {
      parties.docs.forEach((element) {
        _list.add(element.id);
      });
    });

    setState(() {
      _partyNames = _list;
    });
  }

  firebaseUpdateHandler(data, admin, user) {
    List users = ["Aayush", "Ashok", "Raj"];

    if (admin) users.remove(user);

    widget.data['date'] = widget.data['date'].toDate();

    bool needtoUpdate = false;
    String changedData = "";
    widget.data.forEach((key, value) {
      if (key != 'approved' && key != 'generatedBy' && key != 'id') {
        if (widget.data[key] != data[key]) {
          needtoUpdate = true;
          changedData = "$key $changedData";
        }
      }
    });

    if (needtoUpdate) {
      FirebaseFirestore.instance
          .collection('paymentin')
          .doc(widget.data['id'])
          .update(data);
      FirebaseFirestore.instance.collection('log').add({
        'title': 'Payment In Updated',
        'subTitle': data['customerName'],
        'generatedBy': user,
        'approved': admin,
        'time': DateTime.now(),
        'data':
            "Company: ${data['company']} | Amount: ₹${NumberFormat("##,##,#00.00").format(data['amount'])} Changed Data: $changedData",
        'notSeen': users
      });
      FirebaseFirestore.instance
          .collection('party')
          .doc(data['customerName'])
          .update({
        'transactions': FieldValue.arrayRemove([
          {
            'amount': widget.data['amount'],
            'approved': widget.data['approved'],
            'id': widget.data['mode'],
            'time': widget.data['date'],
            'type': 'paymentin'
          }
        ])
      }).then((value) {
        FirebaseFirestore.instance
            .collection('party')
            .doc(data['customerName'])
            .update({
          'transactions': FieldValue.arrayUnion([
            {
              'amount': data['amount'],
              'approved': data['approved'],
              'id': data['mode'],
              'time': data['date'],
              'type': 'paymentin'
            }
          ])
        });
      });

      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Payment Updated"),
                actions: [
                  TextButton(
                      onPressed: () {
                        int count = 0;
                        Navigator.popUntil(context, (route) => count++ >= 2);
                      },
                      child: const Text("Ok"))
                ],
              ));

    }

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Nohting to Updated"),
              actions: [
                TextButton(
                    onPressed: () {
                      int count = 0;
                      Navigator.popUntil(context, (route) => count++ >= 2);
                    },
                    child: const Text("Ok"))
              ],
            ));
  }

  firebaseHandler(data, admin, user) {
    List users = ["Aayush", "Ashok", "Raj"];

    if (admin) users.remove(user);
    FirebaseFirestore.instance.collection('paymentin').add(data).then((doc) {
      FirebaseFirestore.instance.collection('log').doc(doc.id).set({
        'title': 'Payment In',
        'subTitle': data['customerName'],
        'generatedBy': user,
        'approved': admin,
        'time': DateTime.now(),
        'data':
            "Company: ${data['company']} | Amount: ₹${NumberFormat("##,##,#00.00").format(data['amount'])}",
        'notSeen': users
      });

      var partyRef = FirebaseFirestore.instance
          .collection('party')
          .doc(data['customerName']);
      partyRef.get().then((party) {
        if (party.exists) {
          partyRef.update({
            'transactions': FieldValue.arrayUnion([
              {
                'id': data['mode'],
                'amount': data['amount'],
                'approved': admin,
                'time': data['date'],
                'type': 'paymentin'
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
                'id': data['mode'],
                'amount': data['amount'],
                'approved': admin,
                'time': data['date'],
                'type': 'paymentin'
              }
            ]
          });
        }
      });
    }).whenComplete(() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("${data['customerName']} paid ${data['amount']}"),
                actions: [
                  TextButton(
                      onPressed: () {
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                      child: const Text("Ok"))
                ],
              ));
    });
  }

  // ImagePicker _imagePicker = ImagePicker();

  // contentBox(context) {
  //   return Stack(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 10),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Center(
  //               child: Text(
  //                 'UPLOAD IMAGE FROM',
  //                 style: TextStyle(
  //                     color: Colors.amber,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.w600),
  //               ),
  //             ),
  //             const Divider(
  //               height: 8,
  //               thickness: 1,
  //               color: Colors.amber,
  //               indent: 50,
  //               endIndent: 15,
  //             ),
  //             const SizedBox(
  //               height: 15,
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 TextButton.icon(
  //                     onPressed: () {
  //                       getImages(ImageSource.gallery);
  //                       Navigator.pop(context);
  //                     },
  //                     icon: const Icon(Icons.image, color: Colors.amber),
  //                     label: const Text(
  //                       "Gallery",
  //                       style: TextStyle(
  //                           color: Colors.amber,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 16),
  //                     )),
  //                 TextButton.icon(
  //                     onPressed: () {
  //                       // getImages();
  //                       Navigator.pop(context);
  //                     },
  //                     icon: const Icon(Icons.camera, color: Colors.amber),
  //                     label: const Text(
  //                       "Camera",
  //                       style: TextStyle(
  //                           color: Colors.amber,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 16),
  //                     ))
  //               ],
  //             )
  //           ],
  //         ),
  //       )
  //     ],
  //   );
  // }

  // // Dialog to add photo👇
  // void displayDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //         backgroundColor: Colors.white,
  //         elevation: 1,
  //         child: contentBox(context),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (state == 0) {
      fetchPartyList();

      if (widget.edit || widget.view) {
        setState(() {
          _company =
              widget.data['company'] == 'ayi' ? Company.ayi : Company.jrm;
          _customerName = widget.data['customerName'];
          _modeSelected = widget.data['mode'];
          _selectedDate = widget.data['date'].toDate();
          _selectedTime = TimeOfDay(
              hour: widget.data['date'].toDate().hour,
              minute: widget.data['date'].toDate().minute);
          _paymentAmount.text = widget.data['amount'].toString();
        });
      }

      setState(() {
        user = context.watch<UserProvider>().userName;
        admin = context.watch<UserProvider>().admin;
        state++;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment In'),
        backgroundColor: Colors.amber,
        elevation: 1,
      ),
      body: Column(children: [
        // date and time 👇

        Row(
          children: [
            // Date 👇
            Expanded(
              child: InkWell(
                onTap: widget.view
                    ? null
                    : () async {
                        final DateTime? dateTime = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000));
                        setState(() {
                          _selectedDate = dateTime!;
                        });
                      },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Date'),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(dateFormat.format(_selectedDate))
                      ]),
                ),
              ),
            ),

            // Time👇
            Expanded(
              child: InkWell(
                onTap: widget.view
                    ? null
                    : () async {
                        final TimeOfDay? dateTime = await showTimePicker(
                            context: context, initialTime: _selectedTime);

                        if (dateTime != null) {
                          setState(() {
                            _selectedTime = dateTime;
                          });
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1),
                          left: BorderSide(color: Colors.black, width: 1))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Time')
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                            '${_selectedTime.hour}:${_selectedTime.minute} ${_selectedTime.period.toString().split('.')[1]}')
                      ]),
                ),
              ),
            ),
          ],
        ),

        // Company Radio selection.👇
        Container(
          margin: const EdgeInsets.fromLTRB(10, 12, 10, 3),
          child: InputDecorator(
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Payment In For',
                labelStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            child: Row(children: [
              Flexible(
                fit: FlexFit.tight,
                child: ListTile(
                  dense: false,
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  visualDensity: VisualDensity.compact,
                  horizontalTitleGap: 0,
                  title: const Text(
                    'JRM',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  leading: Radio<Company>(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Colors.amber,
                    groupValue: _company,
                    value: Company.jrm,
                    onChanged: widget.view
                        ? null
                        : (Company? value) => {
                              setState(() {
                                _company = value!;
                              })
                            },
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: ListTile(
                  dense: false,
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  visualDensity: VisualDensity.compact,
                  horizontalTitleGap: 0,
                  title: const Text(
                    'A Y Industries',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  leading: Radio<Company>(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Colors.amber,
                    groupValue: _company,
                    value: Company.ayi,
                    onChanged: widget.view
                        ? null
                        : (Company? value) {
                            setState(() {
                              _company = value!;
                            });
                          },
                  ),
                ),
              )
            ]),
          ),
        ),

        // Customer Name Autocomplete👇

        Container(
          child: RawAutocomplete(
            initialValue: TextEditingValue(text: _customerName),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }

              return _partyNames.where((party) => party
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              return Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 3),
                child: TextFormField(
                  readOnly: widget.edit || widget.view,
                  onChanged: widget.view || widget.edit
                      ? null
                      : (value) {
                          setState(() {
                            _customerName = textEditingController.text;
                          });
                        },
                  focusNode: focusNode,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Customer Name',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              );
            },
            onSelected: widget.edit || widget.view
                ? null
                : (String? option) {
                    setState(() {
                      _customerName = option!;
                    });
                  },
            optionsViewBuilder:
                (context, void Function(String) onSelected, options) {
              return Material(
                child: SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      children: options.map((partyName) {
                        return InkWell(
                          onTap: () {
                            onSelected(partyName.toString());
                          },
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 1, bottom: 1),
                              width: double.infinity,
                              child: Card(
                                  color: Colors.amber,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(partyName.toString()),
                                  ))),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Payment Amount Input Field.👇👇

        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 3),
          child: TextFormField(
            readOnly: widget.view,
            controller: _paymentAmount,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Amount',
                labelStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            keyboardType: TextInputType.number,
          ),
        ),

        // Payment Mode Dropdown.

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              border: Border.all(width: 0.8, color: Colors.black54),
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 3),
          child: DropdownButton<String>(
            underline: const SizedBox(),
            hint: const Text('Payment Mode'),
            isExpanded: true,
            value: _modeSelected,
            borderRadius: BorderRadius.circular(10),
            items: paymentMode.map<DropdownMenuItem<String>>((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.toString()),
              );
            }).toList(),
            onChanged: widget.view
                ? null
                : (value) {
                    setState(() {
                      _modeSelected = value!;
                    });
                  },
          ),
        ),

        // // Button to attach reference photo.👇

        // Container(
        //   child: ElevatedButton.icon(
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all(Colors.amber),
        //     ),
        //     icon: const Icon(Icons.attach_file),
        //     label: const Text(
        //       'Attach',
        //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //     ),
        //     onPressed: () {
        //       displayDialog();
        //     },
        //   ),
        // ),

        // // InkWell
        // if (images.isNotEmpty)
        //   InkWell(
        //     onTap: () {
        //       Navigator.push(context,
        //           MaterialPageRoute(builder: (context) => ViewImage(images)));
        //     },
        //     child: Container(
        //       constraints: const BoxConstraints(maxHeight: 100),
        //       clipBehavior: Clip.hardEdge,
        //       margin: const EdgeInsets.only(left: 10, right: 10),
        //       decoration: BoxDecoration(
        //           shape: BoxShape.rectangle,
        //           borderRadius: BorderRadius.circular(10),
        //           color: Colors.red),
        //       height: 100,
        //       width: MediaQuery.of(context).size.width,
        //       child: Stack(children: [
        //         Image.file(
        //           width: double.infinity,
        //           File(
        //             images[0].path,
        //           ),
        //           fit: BoxFit.fitWidth,
        //         ),
        //         Positioned(
        //           // bottom: 0,
        //           child: Container(
        //             // alignment: Alignment(0, 0.5),
        //             width: double.infinity,
        //             // height: 30,
        //             decoration: const BoxDecoration(color: Colors.white),
        //             child: const Text('Tap To View',
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(
        //                     fontSize: 18, fontWeight: FontWeight.w500)),
        //           ),
        //         )
        //       ]),
        //     ),
        //   ),

        // buttons for confirm and cancel👇
      ]),
      resizeToAvoidBottomInset: false,
      persistentFooterButtons: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber)),
            onPressed: widget.view
                ? null
                : () {
                    DateTime paymentDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute);

                    Map<String, dynamic> data = {
                      'date': paymentDate,
                      'company': _company.toString().split('.').last,
                      'customerName': _customerName.toString().toUpperCase(),
                      'amount': double.parse(_paymentAmount.text),
                      'mode': _modeSelected,
                      'approved': admin,
                      'generatedBy': user
                    };

                    widget.edit
                        ? firebaseUpdateHandler(data, admin, user)
                        : firebaseHandler(data, admin, user);
                  },
            child: Text(widget.edit ? 'Update' : 'Confirm'),
          ),
        )
      ],
    );
  }
}
