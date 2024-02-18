import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:ay_invoiving_app/screens/staff_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addStaff.dart';


class Attendance extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AttendanceState();
  }
}

class AttendanceState extends State<Attendance>{

  markPresent(name){
    FirebaseFirestore.instance.collection('staff').doc(name).update({
      'today': DateTime.now()
    });
    final month = "${DateTime.now().month}:${DateTime.now().year}";

    final monthRef = FirebaseFirestore.instance.collection('staff').doc(name).collection('attendance').doc(month);

    monthRef.get().then((attendanceMonth){
      if(attendanceMonth.exists){
        monthRef.update({
          'attendence': FieldValue.arrayUnion([DateTime.now().day])
        });
      }
      else{
        monthRef.set(
          {
            'attendence': [DateTime.now().day]
          }
        );
      }
    });

  }
  markAbsent(name){
    FirebaseFirestore.instance.collection('staff').doc(name).update({
      'today': DateTime(2000)
    });

    final month = "${DateTime.now().month}:${DateTime.now().year}";

    final monthRef = FirebaseFirestore.instance.collection('staff').doc(name).collection('attendance').doc(month);

    monthRef.get().then((attendanceMonth){
      if(attendanceMonth.exists){
        monthRef.update({
          'attendence': FieldValue.arrayRemove([DateTime.now().day])
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('staff').snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          print(snapshot.hasData.toString());
          if(snapshot.hasData){
            if(snapshot.data.docs.isEmpty){
              return const Center(child: Text("No Staff"),);
            }

            return Column(children :snapshot.data.docs.map<Widget>((staff) {

              DateTime today = DateTime.now();
              DateTime staffToday = staff['today'].toDate();

              bool todayPresent = today.year == staffToday.year && today.month == staffToday.month && today.day == staffToday.day;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                child: Card(
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetails(data: staff.data(),)));
                    },
                    child: Container(
                    height: 55,
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text(staff['name']),
                      TextButton(onPressed: (){
                        todayPresent ? markAbsent(staff['name']) : markPresent(staff['name']);
                      }, child: Container(child: Text("Mark ${todayPresent ? "Absent" : "Present"} Today",style: TextStyle(color: todayPresent ? Colors.red : Colors.green),))),
                    ]),
                  ),
                ),
                ));
            }).toList());
          }
          return Loading();
        }),

        floatingActionButton: FloatingActionButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddStaff()));
        },
        child: const Icon(Icons.add),),
    );
  }
}
