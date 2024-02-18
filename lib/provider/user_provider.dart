import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier{
  bool admin;
  String userName ="";

  UserProvider({this.admin = false,
  userName = ""
  });

  void updateUser({required bool isAdmin,required String name}) async{
    userName = name;
    admin = isAdmin;
    notifyListeners();
  }

}