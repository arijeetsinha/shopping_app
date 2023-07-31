class UserID {
  final String uid;
  UserID({required this.uid});
}

class UserData {
  final String uid;
  final String title;
  final String desc;
  final double price;

  UserData(
      {required this.title,
      required this.desc,
      required this.price,
      required this.uid});
}
