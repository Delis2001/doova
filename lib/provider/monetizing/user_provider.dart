import 'package:doova/model/monetizing/user.dart';
import 'package:doova/server/monetizing/user_server.dart';
import 'package:flutter/material.dart';


class UserProvider with ChangeNotifier {
   UserModel? _user;
  final _userService = UserService();

  UserModel? get user => _user;

  Future<void> loadUser(String uid) async {
    _user = await _userService.fetchUser(uid);
    notifyListeners();
  }
  
  Future<void> spendCoin(String uid) async {
    await _userService.spendCoin(uid);
    await loadUser(uid);
  }

  Future<void> earnCoin(String uid) async {
    await _userService.earnCoin(uid);
    await loadUser(uid);
  }

  Future<void> upgradeToPremium(String uid) async {
    await _userService.upgradeToPremium(uid);
    await loadUser(uid);
  }

  Future<void> updateCoin(int newCoin) async {
    if (_user != null) {
      _user!.coins = newCoin;
      await _userService.updateUser(_user!);
      notifyListeners();
    }
  }

}
