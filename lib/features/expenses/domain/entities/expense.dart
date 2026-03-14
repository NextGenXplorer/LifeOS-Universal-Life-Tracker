class Expense {
  final String id;
  final double amount;
  final String? description;
  final String category;
  final DateTime date;
  final String? paymentMethod;
  final bool isIncome;
  final String? receiptPath;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.amount,
    this.description,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.isIncome = false,
    this.receiptPath,
    required this.createdAt,
  });
}
