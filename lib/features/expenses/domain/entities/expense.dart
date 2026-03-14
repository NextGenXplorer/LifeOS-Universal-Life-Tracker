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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      paymentMethod: map['payment_method'] as String?,
      isIncome: (map['is_income'] as int?) == 1,
      receiptPath: map['receipt_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'is_income': isIncome ? 1 : 0,
      'receipt_path': receiptPath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
