class Transactions {
  final DateTime createTime = DateTime.now();

  Transactions() {
    print("transaction creating");
  }

  void createTransaction() => print("transaction created at $createTime");

}
