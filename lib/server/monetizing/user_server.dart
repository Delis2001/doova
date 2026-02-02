import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doova/model/monetizing/user.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection('users');
  Future<UserModel> fetchUser(String uid) async {
    final snap = await users.doc(uid).get();
    if (snap.exists) {
      return UserModel.fromMap(snap.data()!);
    } else {
      final user = UserModel(uid: uid);
      await users.doc(uid).set(user.toMap());
      return user;
    }
  }

  Future<void> updateUser(UserModel user) async {
    await users.doc(user.uid).update(user.toMap());
  }

  Future<void> spendCoin(String uid) async {
    final user = await fetchUser(uid);
    if (!user.isPremium && user.coins > 0) {
      user.coins -= 1;
      await updateUser(user);
    }
  }

  Future<void> earnCoin(String uid) async {
    final user = await fetchUser(uid);
    user.coins += 1;
    await updateUser(user);
  }

  Future<void> upgradeToPremium(String uid) async {
    final user = await fetchUser(uid);
    user.isPremium = true;
    await updateUser(user);
  }
}