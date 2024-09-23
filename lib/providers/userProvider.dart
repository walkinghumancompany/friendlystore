import 'package:flutter/cupertino.dart';
import 'package:friendlystore/user.dart';

class userProvider extends ChangeNotifier {
  User _user;

  userProvider({User? user}) : _user = user ?? User(code: "", name: "", phone: "");

  User get user => _user;

  void updateUserData({required User user}) {
    _user = user;
    notifyListeners();
  }
}
