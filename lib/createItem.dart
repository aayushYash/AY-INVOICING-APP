import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ay_invoiving_app/helper/input_validator.dart';

class NewItem extends StatefulWidget {
  final data, edit;
  const NewItem({super.key, this.data, this.edit});

  @override
  State<StatefulWidget> createState() => _NewItemState();
}

const List<double> gstrate = [0, 5, 12, 18, 28];

class _NewItemState extends State<NewItem> {
  // Methods
  FirebaseAddRecord(Map<String, dynamic> data, String user, bool approved) {
    Map<String, dynamic> widgetData = widget.data;

    List users = ["Aayush", "Ashok", "Raj"];

    if (approved) users.remove(user);
    if (widget.edit) {
      if (mapEquals(widgetData, data)) {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Nothing to update'),
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
      var changedData = "";

      data.forEach((key, value) {
        if (data[key] != widget.data[key]) {
          if (key != 'approved') {
            changedData = "${changedData}Updated $key: $value| ";
          }
        }
      });

      FirebaseFirestore.instance
          .collection('product')
          .doc(data['itemName'])
          .update(data)
          .then((value) {
        FirebaseFirestore.instance.collection('log').add({
          'title': "Product Updated",
          'subTitle': data['itemName'],
          'data': changedData,
          'generatedBy': user,
          'approved': true,
          'time': DateTime.now(),
          'notSeen': users,
        }).then((value) {
        showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text("${data['itemName']} Updated"),
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
      });
      return;
    }
    FirebaseFirestore.instance
        .collection('product')
        .doc(data['itemName'])
        .set(data)
        .then((value) {
      FirebaseFirestore.instance.collection('log').add({
        'title': "New Product Added",
        'subTitle': data['itemName'],
        'data':
            "Rate: ${data['rate']} | GST: ${data['gst']} | Stock: ${data['stock']}",
        'generatedBy': user,
        'approved': approved,
        'time': DateTime.now(),
        'notSeen': users,
      }).then((value) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text("${data['itemName']} Added"),
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
    });
  }

  // input validator

  // controller
  // final TextEditingController _itemName = TextEditingController();
  // final TextEditingController _hsn = TextEditingController();
  // final TextEditingController _unit = TextEditingController();
  // final TextEditingController _description = TextEditingController();
  // final TextEditingController _rate = TextEditingController();
  // final TextEditingController _actualStock = TextEditingController();

  String _itemName = '';
  String _hsn = "";
  String _unit = "";
  String _description = "";
  String _rate = "";
  String _actualStock = "";
  String _pakkaStock = "";
  int counter = 0;

  // variables
  double gstSelected = gstrate[0];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (widget.edit && counter == 0) {
      setState(() {
        counter++;
        _itemName = widget.data['itemName'];
        _unit = widget.data['unit'];
        _description = widget.data['description'];
        _hsn = widget.data['hsn'];
        _rate = widget.data['rate'].toString();
        _actualStock = widget.data['openingActualStock'].toString();
        gstSelected = widget.data['gst'];
        _pakkaStock = widget.data['openingPakkaStock'].toString();
      });
    }

    final user = context.watch<UserProvider>().userName;
    final approved = context.watch<UserProvider>().admin;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.edit ? "Update" : "New"} Item'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      labelText: 'Item Name',
                      isDense: true),
                  // controller: _itemName,
                  initialValue: _itemName,
                  onChanged: (value) {
                    setState(() {
                      _itemName = value;
                    });
                  },
                  scrollPadding: EdgeInsets.zero,
                  validator: (text) => inputValidator(text!),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        validator: (text) => inputValidator(text!),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            labelText: 'HSN',
                            isDense: true),
                        initialValue: _hsn.toString(),
                        onChanged: (value) {
                          setState(() {
                            _hsn = value;
                          });
                        },
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        validator: (text) => inputValidator(text!),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            labelText: 'Unit',
                            isDense: true),
                        initialValue: _unit,
                        onChanged: (value) {
                          setState(() {
                            _unit = value;
                          });
                        },
                        scrollPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        validator: (text) => inputValidator(text!),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            labelText: 'Rate',
                            isDense: true),
                        initialValue: _rate.toString(),
                        onChanged: (value) {
                          setState(() {
                            _rate = value;
                          });
                        },
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.black38, width: 1))),
                        child: DropdownButton<double>(
                            dropdownColor: Colors.amber,
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.circular(15),
                            elevation: 0,
                            underline: const SizedBox(),
                            value: gstSelected,
                            items:
                                gstrate.map<DropdownMenuItem<double>>((item) {
                              return DropdownMenuItem<double>(
                                value: item,
                                child: Text(item.toString()),
                              );
                            }).toList(),
                            onChanged: (double? value) {
                              setState(() {
                                gstSelected = value!;
                              });
                            }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (text) => inputValidator(text!),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      labelText: 'Opening Actual Stock',
                      isDense: true),
                  initialValue: _actualStock.toString(),
                  onChanged: (value) {
                    setState(() {
                      _actualStock = value;
                    });
                  },
                  maxLines: null,
                  scrollPadding: EdgeInsets.zero,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (text) => inputValidator(text!),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      labelText: 'Opening Pakka Stock',
                      isDense: true),
                  initialValue: _pakkaStock.toString(),
                  onChanged: (value) {
                    setState(() {
                      _pakkaStock = value;
                    });
                  },
                  maxLines: null,
                  scrollPadding: EdgeInsets.zero,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      labelText: 'Description',
                      isDense: true),
                  initialValue: _description,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  maxLines: null,
                  scrollPadding: EdgeInsets.zero,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.grey.shade300)),
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Map<String, dynamic> data = {
                                'itemName': _itemName,
                                'hsn': _hsn,
                                'unit': _unit,
                                'rate': _rate,
                                'gst': gstSelected,
                                'openingActualStock': _actualStock,
                                'openingPakkaStock': _pakkaStock,
                                'description': _description,
                              };

                              FirebaseAddRecord(data, user, approved);
                            }
                          },
                          child: widget.edit
                              ? const Text('Update')
                              : const Text('Add')),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
