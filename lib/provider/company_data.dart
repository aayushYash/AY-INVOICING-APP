import 'package:flutter/material.dart';

class CompanyDataProvider extends ChangeNotifier{
  CompanyDataProvider({required this.data});
  List data;


  void updateData({required List val}){
    data = [...val];
  }

}