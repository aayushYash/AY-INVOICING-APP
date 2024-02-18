import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StaffDetails extends StatefulWidget {
  final data;
  const StaffDetails({super.key, required this.data});
  @override
  State<StatefulWidget> createState() {
    return StaffDetailsState();
  }
}

final months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

class StaffDetailsState extends State<StaffDetails> {
  double openingBalance = 0;
  Map monthWiseAttendence = {};

  List dropdowns = [];

  int lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;

  int returnLastDate(str) {
    int month = int.parse(str.split('/')[0]);
    int year = int.parse(str.split('/')[1]);
    return DateTime(year, month + 1, 0).day;
  }

  int index = 0;

  firestoreHandler() {
    final name = widget.data['name'];
    FirebaseFirestore.instance
        .collection('staff')
        .doc(name)
        .get()
        .then((staff) {
      openingBalance = staff.data()?['openingBalance'];
    });
    FirebaseFirestore.instance
        .collection('staff')
        .doc(name)
        .collection('attendance')
        .get()
        .then((attendence) {
      List dd = [];
      double sal = 0;
      Map mwa = {};
      attendence.docs.forEach((month) {
        mwa[month.id.replaceAll(':', '/')] = month.data()['attendence'];
        dd.add(month.id.replaceAll(':', '/'));
        if (dailyBasis) {
        sal = sal + (salary * month.data()['attendence'].length);
      } else {
        sal += salary;
      }
      });
      dd.sort((a, b) {
        int month1 = int.parse(a.split('/')[0]);
        int year1 = int.parse(a.split('/')[1]);
        int month2 = int.parse(b.split('/')[0]);
        int year2 = int.parse(b.split('/')[1]);
        DateTime date1 = DateTime(year1, month1, 1);
        DateTime date2 = DateTime(year2, month2, 1);

        return date1.compareTo(date2);
      });
      setState(() {
        lastDate = returnLastDate(dd.last);
        dropdowns = dd;
        index = dd.length - 1;
        monthWiseAttendence = mwa;
        balance += sal;
      });
    });

  }

  calculateBalance() {
    
    double totalPayment = 0;
    payments.forEach((element) {
      totalPayment += element['amount'];
    });
    setState(() {
      balance = balance - totalPayment;
    });
  }

  bool dailyBasis = false;
  bool admin = false;
  int state = 0;
  List payments = [];
  double balance = 0;
  double salary = 0;
  String user = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    payments = widget.data['payments'];
    payments.sort(
        (pay1, pay2) => pay1['date'].toDate().compareTo(pay2['date'].toDate()));
    payments = payments.reversed.toList();
    balance = widget.data['openingBalance'];
    dailyBasis = widget.data['dailyBasis'];
    salary = widget.data['salary'];
      firestoreHandler();
      calculateBalance();

  }

  @override
  Widget build(BuildContext context) {

    user = context.watch<UserProvider>().userName;
    admin = context.watch<UserProvider>().admin;
    
    print(dropdowns.toString());
    return dropdowns.isNotEmpty ? Scaffold(
      appBar: AppBar(title: Text(widget.data['name'])),
      body: Column(children: [
        // month selection;

        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: index == 0
                    ? null
                    : () {
                        setState(() {
                          index--;
                          lastDate = returnLastDate(dropdowns[index]);
                        });
                      },
                icon: const Icon(Icons.remove)),
            const SizedBox(
              width: 10,
            ),
            Text(
                "${months[int.parse(dropdowns[index].split('/')[0]) - 1]} ${dropdowns[index].split('/')[1]}"),
            const SizedBox(
              width: 10,
            ),
            IconButton(
                onPressed: index == dropdowns.length - 1
                    ? null
                    : () {
                        setState(() {
                          index++;
                          lastDate = returnLastDate(dropdowns[index]);
                        });
                      },
                icon: const Icon(Icons.add)),
          ]),
        ),

        // dates for month
        Expanded(
            flex: 2,
            child: GridView(
              padding: EdgeInsets.symmetric(horizontal: 18),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7),
              children: [
                for (int i = 1; i <= lastDate; i++)
                  Container(
                      color: monthWiseAttendence[dropdowns[index]]?.contains(i)
                          ? Colors.green
                          : null,
                      child: Center(child: Text(i.toString())))
              ],
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Text(
                  "No. days present in ${months[int.parse(dropdowns[index].split('/')[0]) - 1]} ${dropdowns[index].split('/')[1]}: ${monthWiseAttendence[dropdowns[index]].length}"),
            ),
            Container(
              child: Text("${balance < 0 ? 'Advance:' : 'Balance:'} ${NumberFormat("₹##,##,##0.00").format(balance.abs())}"),
            ),
          ],
        ),
        const Row(
          children: [
            Expanded(
              child: Divider(
                thickness: 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Payment Details'),
            ),
            Expanded(
              child: Divider(
                thickness: 1.5,
              ),
            )
          ],
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 2),
              children: payments.map<Widget>((payment) {
                DateTime date = payment['date'].toDate();
                return Card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("${date.day}/${date.month}/${date.year}"),
                        Text(NumberFormat("₹##,##,##0.00")
                            .format(payment['amount'])),
                      ]),
                );
              }).toList(),
            ),
          ),
        )
      ]),

      persistentFooterButtons: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Expanded(child: Container(
            
            child: TextButton(child: const Center(child: Text('Back')),onPressed: (){
            Navigator.pop(context);
          },),),),
          Expanded(child: Container(
            color: Colors.amber,
            child: TextButton(child: const Center(child: Text('Pay',style: TextStyle(color: Colors.black),)),onPressed: (){
                      print(user+"||"+admin.toString());

              TextEditingController payamount = TextEditingController();
              showDialog(context: context, builder: (context) => AlertDialog(
                title: Text("Pay to ${widget.data['name']}"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextFormField(controller: payamount,decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),labelText: 'Pay Amount',isDense: true,contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 17)),)
                ]),
                actionsAlignment: MainAxisAlignment.spaceAround,
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: const Text("Cancel")),
                  TextButton(
                    onPressed: (){
                    List users = ['Aayush','Ashok', 'Raj'];
                    if(admin) users.remove(user);
                    FirebaseFirestore.instance.collection('expense').add({
                      'date': DateTime.now(),
                      'expenseFor': widget.data['name'],
                      'description': 'Labour Payment',
                      'amount': double.parse(payamount.text),
                      'generatedBy': user,
                    });
                    FirebaseFirestore.instance.collection('staff').doc(widget.data['name']).update({
                      'payments': FieldValue.arrayUnion([{
                        'date': DateTime.now(),
                        'amount': double.parse(payamount.text)
                      }])
                    });
                    FirebaseFirestore.instance.collection('log').add({
                      'title': 'Expense',
                      'subTitle': widget.data['name'],
                      'time': DateTime.now(),
                      'notSeen': users,
                      'generatedBy': user,
                      'approved': true,
                      'data': 'Labour Payment: ${NumberFormat("₹##,##,##0.00").format(double.parse(payamount.text))}'
                    });
                    int count = 0;
                    return Navigator.of(context).popUntil((route) => count++>=2);
                  }, child: const Text("Pay")),
                ],
              ));
          },),),)
        ],)
      ],
    ) : Loading();
  }
}
