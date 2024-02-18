import 'package:flutter/material.dart';


class BillingItemProvider extends ChangeNotifier{
  List<Map> data = [];
  BillingItemProvider({required this.data});


  void updateData({required Map dataItem}){
    data.add(dataItem);
    notifyListeners();
  }

  void deleteData({required int index}){
    data.removeAt(index);
    notifyListeners();
  }

  void clearData(){
    data.clear();
    notifyListeners();
  }


}

