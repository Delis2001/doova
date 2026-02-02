class UserModel {
  final String uid;
  int coins;
  bool isPremium;

  UserModel({required this.uid, this.coins = 5, this.isPremium = false});

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'coins': coins,
        'isPremium': isPremium,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'],
        coins: map['coins'] ?? 5,
        isPremium: map['isPremium'] ?? false,
      );
}
