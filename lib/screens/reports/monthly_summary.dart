import 'package:flutter/material.dart';

class MonthlySummary extends StatefulWidget{

  @override
  State<MonthlySummary> createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary> {

  DateTime startDate = DateTime(DateTime.now().year,DateTime.now().month,1);
  DateTime endDate = DateTime(DateTime.now().year,DateTime.now().month+1,0);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report'),),
    );
  }
}
