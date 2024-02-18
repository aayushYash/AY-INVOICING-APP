import 'package:flutter/material.dart';


class LogProvider extends ChangeNotifier{
  bool check=false;
  LogProvider({required this.check});

  void update(bool ch){
    check = ch;
    notifyListeners();
  }
}