
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class NewParty extends StatefulWidget {

  var data,edit;

  NewParty({super.key, this.data,this.edit});
  @override
  State<StatefulWidget> createState() {
    return _NewPartyState();
  }
}

class _NewPartyState extends State<NewParty> {
  final TextEditingController _partyName = TextEditingController();
  final TextEditingController _contactPerson = TextEditingController();
  final TextEditingController _billingAddress = TextEditingController();
  final TextEditingController _shippingAddress = TextEditingController();
  final TextEditingController _gstin = TextEditingController();
  final TextEditingController _openingBalance = TextEditingController();

  bool sameShippingAddress = true;
  int state = 0;

  @override
  Widget build(BuildContext context) {
      String user = context.watch<UserProvider>().userName;
      bool admin = context.watch<UserProvider>().admin;
    if(state == 0){
      if(widget.edit){

        setState(() {
          _partyName.text = widget.data['partyName'];
          _billingAddress.text = widget.data['billingAddress'];
          if(widget.data['billingAddress'] == widget.data['shippingAddress']){
            sameShippingAddress = true;
          }
          else{
            sameShippingAddress = false;
            _shippingAddress.text = widget.data['shippingAddress'];
          }
          _gstin.text = widget.data['gstin'];
          _openingBalance.text = widget.data['openingBalance'].toString();
          state++;
        });
      }
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('${widget.edit ? "Update": "Edit"} Party')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 90,
                child: TextFormField(
                  readOnly: widget.edit,
                  controller: _partyName,
                  decoration: const InputDecoration(
                      hintText: 'Party/Company Name', border: InputBorder.none),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            flex: 1,
            child: Container(
              
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Color.fromARGB(133, 0, 0, 0),
                offset: Offset(0, -2),
                blurRadius: 5,
                spreadRadius: 0.5
                ),],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextFormField(
                          controller: _contactPerson,
                          decoration: const InputDecoration(
                              labelText: 'Contact Person',
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.only(left: 10),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: _billingAddress,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: 'Billing Address',
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding:
                                  EdgeInsets.only(left: 10, top: 10),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 350,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                                'Shipping Address Same as Billing Address'),
                            Switch(
                                value: sameShippingAddress,
                                onChanged: (bool value) {
                                  setState(() {
                                    sameShippingAddress = value;
                                  });
                                }),
                          ],
                        ),
                      ),
                      if (!sameShippingAddress)
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            controller: _shippingAddress,
                            maxLines: null,
                            decoration: const InputDecoration(
                                labelText: 'Shipping Address',
                                labelStyle: TextStyle(color: Colors.black),
                                contentPadding:
                                    EdgeInsets.only(left: 10, top: 10),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextFormField(
                          controller: _gstin,
                          decoration: const InputDecoration(
                              labelText: 'GSTIN',
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.only(left: 10),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _openingBalance,
                          decoration: const InputDecoration(
                              labelText: 'Opening Balance',
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.only(left: 10),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.amber)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0)),
                          onPressed: () {
                            final partyName = _partyName.text;
                            final contactPerson = _contactPerson.text;
                            final billingAddress = _billingAddress.text;
                            final shippingAddress = sameShippingAddress
                                ? _billingAddress.text
                                : _shippingAddress.text;
                            final gstin = _gstin.text;
                            final openingBalanc =
                                _openingBalance.text.isNotEmpty
                                    ? _openingBalance.text
                                    : 0;
            
                            if (partyName.isEmpty) {
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    elevation: 2,
            
                                      content:
                                          Text("Party Name can not be empty")));
                              return;
                            }
            
                            if (billingAddress.isEmpty ) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Billing Address can not be empty")));
                              return;
                            }
            
                            Map<String, dynamic> data = {
                              'partyName': partyName.toUpperCase(),
                              'contactPerson': contactPerson,
                              'billingAddress': billingAddress,
                              'shippingAddress': shippingAddress,
                              'gstin': gstin,
                              'openingBalance': openingBalanc,
                              'transactions': []
                            };
            
            
                            List users = ['Aayush', 'Ashok', 'Raj'];
            
                                        if(admin) users.remove(user);
            
                            // check for already existing party.
                            final docRef = FirebaseFirestore.instance
                                .collection('party')
                                .doc(partyName.toUpperCase());
            
            
                            String changedData = "";
            
                            bool needtoUpdate = false;
            
                            Map<String,dynamic> updatedData = {
                        'contactPerson': contactPerson,
                              'billingAddress': billingAddress,
                              'shippingAddress': shippingAddress,
                              'gstin': gstin,
                              'openingBalance': openingBalanc,
                            };
            
                            if(widget.edit){
            
                              widget.data.forEach((key,value){
                                if(key!='transactions'){
                                  if(data[key] != value){
                                    changedData = "$key $changedData";
                                    needtoUpdate = true;
                                  }
                                }
                              });
            
                              if(needtoUpdate){
                                FirebaseFirestore.instance.collection('party').doc(widget.data['partyName']).update(updatedData);
                                
                                FirebaseFirestore.instance.collection('log').add({
                                  'title': 'Party Updated',
                                  'subTitle': data['partyName'],
                                  'time': DateTime.now(),
                                  'approved': admin,
                                  'generatedBy': user,
                                  'notSeen': users,
                                  'data': 'Changed Data: $changedData'
                                });        
            
                                showDialog(context: context, builder: (context) => AlertDialog(title: Text("${data['partyName']} Updated"),actions: [
                                  TextButton(child: const Text("Ok"), onPressed: (){
                                    int count = 0;
                                    Navigator.of(context).popUntil((route) => count++>=2);
                                  },)
                                ],));
                              }
            
                              else{
                                showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Nothing to Updated"),actions: [
                                  TextButton(child: const Text("Ok"), onPressed: (){
                                    int count = 0;
                                    Navigator.of(context).popUntil((route) => count++>=2);
                                  },)
                                ],));        
                              }
            
                              return;
                            }
            
                            docRef.get().then((snapshot) => {
                                  if (snapshot.exists)
                                    {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: Text(
                                                    "Party already exist with Party Name: $partyName"),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('Ok'),
                                                    onPressed: () => {
                                                      Navigator.pop(context)
                                                    },
                                                  )
                                                ],
                                              ))
                                    }
                                  else
                                    {
                                      docRef.set(data).then((value) {
                                        
                                        // create log
                                        FirebaseFirestore.instance
                                            .collection('log')
                                            .add({
                                          'title': "New Party Created",
                                          'subTitle': partyName,
                                          'data': "Opening Balance: $openingBalanc",
                                          'generatedBy': user,
                                          'approved': true,
                                          'time': DateTime.now(),
                                          'notSeen': users,
                                        }).then((value) {
            
                                          // show success pop
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    content: Text(
                                                        "$partyName Added"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child:
                                                              const Text("Ok"))
                                                    ],
                                                  ));
                                        });
                                      }).onError((error, stackTrace) {
                                        debugPrint(error.toString());
                                        throw "excpetion";
                                      })
                                    }
                                });
                                _billingAddress.clear();
                                _contactPerson.clear();
                                _partyName.clear();
                                _shippingAddress.clear();
                                _gstin.clear();
                                _openingBalance.clear();
            
                                
                          },
                          child:  Text(
                            widget.edit ? "Update" : "Save",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
