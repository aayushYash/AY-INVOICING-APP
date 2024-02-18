import 'package:ay_invoiving_app/helper/input_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemWidget extends StatefulWidget {
  final data;
  final edit;
  bool pakka;
  AddItemWidget(this.pakka, this.data, this.edit, {super.key});

  @override
  _AddItemWidgetState createState() {
    return _AddItemWidgetState();
  }
}

const List<double> gstrate = [0, 5, 12, 18, 28];
const  List<String> unitList = ['Pcs','Bags', 'Kg', 'Gram', 'Ltrs.', 'Buckets', 'Bundles', 'Boxs', 'MTS', 'Packet' ];

class _AddItemWidgetState extends State<AddItemWidget> {
  List<String> ItemList = [];
  Map _itemData = {};

 TextEditingController quantity =TextEditingController();
  // String rate = '';
  TextEditingController rate = TextEditingController();
  TextEditingController discount = TextEditingController(text: '0');
  String _unit = unitList[0];
  TextEditingController itemName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double gstSelected = gstrate[0];
  bool inclusiveTax = false;
  double counter = 0;
  String hsn = '';
  Widget build(BuildContext context) {

    setState(() {
      if (counter == 0) {
        FirebaseFirestore.instance.collection('product').get().then((data) {
          for (var doc in data.docs) {
            ItemList = [doc.id, ...ItemList];
            _itemData = {doc.id: doc.data(), ..._itemData};
          }
        }).onError((error, stackTrace) {
          debugPrint(error.toString());
        });
      }
      if (widget.edit && counter == 0) {
        quantity.text = widget.data['quantity'].toString();
        rate.text = widget.data['rate'].toString();
        discount.text = widget.data['discount'].toString();
        itemName.text = widget.data['name'].toString();
        gstSelected = widget.data['gst'];
        _unit = widget.data['unit'];
        inclusiveTax = widget.data['inclTax'];
        // rate.text =
      }
      counter = 1;
    });
    return Material(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Item',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0x00d9d9d9),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: RawAutocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return ItemList.where((item) => item
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (option) {
                setState(() {
                  itemName.text = option.toString();
                });
              },
              initialValue: TextEditingValue(text: itemName.text),
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFormField(
                  validator: (value) => inputValidator(value!),
                  controller: textEditingController,
                  onChanged: (value) {
                    setState(() {
                      itemName.text = value;
                    });
                  },
                  focusNode: focusNode,
                  // initialValue: itemName,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                      alignLabelWithHint: true,
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      labelText: 'Item'),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  void Function(String) onSelected, Iterable<String> options) {
                return Material(
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                          children: options.map((opt) {
                        debugPrint(opt.toString());
                        return InkWell(
                            onTap: () {
                              setState(() {
                                gstSelected = _itemData[opt]['gst'];
                                rate.text = _itemData[opt]['rate'].toString();
                                _unit = _itemData[opt]['unit'].isEmpty ? unitList[0] : _itemData[opt]['unit'];
                                hsn = _itemData[opt]['hsn'].toString();
                              });
                              onSelected(opt);
                            },
                            child: Container(
                              width: double.infinity,
                                padding: const EdgeInsets.only(right: 60),
                                child: Card(
                                
                                  color: Colors.amber,
                                    child: Container(
                                  width: MediaQuery.of(context).size.width + 40,
                                  padding: const EdgeInsets.all(10),
                                  child: Text(opt),
                                ))));
                      }).toList()),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: quantity,
                    validator: (text) => inputValidator(text!),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                        alignLabelWithHint: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        labelText: 'Quantity'),
                  ),
                ),
                Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: SizedBox(
                        width: 100,
                        height: 35,
                        child: DropdownButton<String>(
                            dropdownColor: Colors.amber,
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.circular(15),
                            elevation: 0,
                            underline: const SizedBox(),
                            value: _unit,
                            items: unitList.map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item.toString()),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _unit = value!;
                              });
                            }),
                      ),
                    )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) => inputValidator(value!),
                    controller: rate,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                        alignLabelWithHint: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        labelText: 'Rate'),
                  ),
                ),
                SizedBox(width: 10,),
                if(widget.pakka) InputChip(
                  selectedColor: Colors.amber,
                  label: const Text('Incl. of Tax'), selected: inclusiveTax,onSelected: (value){
                  setState(() {
                    inclusiveTax = value;
                  });
                },)
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(15)),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discount(%)',
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: SizedBox(
                          width: 100,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) => inputValidator(value!),
                            controller: discount,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.amber, width: 0.0)),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              if(widget.pakka) Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GST(%)',
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: SizedBox(
                        width: 100,
                        height: 35,
                        child: DropdownButton<double>(
                            dropdownColor: Colors.amber,
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.circular(15),
                            elevation: 0,
                            underline: const SizedBox(),
                            value: gstSelected,
                            items: gstrate.map<DropdownMenuItem<double>>((item) {
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
                    )
                  ],
                ),
              ),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                        // ignore: prefer_const_constructors
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black26),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          return Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
      
                          // ignore: prefer_const_constructors
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.amber),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              
                              var r = double.parse(rate.text);
                              
                              return Navigator.pop(context, {
                                'name': itemName.text,
                                'quantity': double.parse(quantity.text),
                                'rate': r,
                                'discount': double.parse(discount.text),
                                'gst': gstSelected,
                                'unit': _unit,
                                'inclTax' : inclusiveTax,
                                'hsn': hsn
                              });
                            }
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 18),
                          )),
                    )
                  ],
                )),
          ),
        ]),
      ),
    ));
  }
}
