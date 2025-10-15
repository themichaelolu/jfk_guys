class Balance {
  final String person;
  double totalPaid;
  double totalOwed;
  double netBalance;

  Balance({
    required this.person,
    this.totalPaid = 0,
    this.totalOwed = 0,
    this.netBalance = 0,
  });
}