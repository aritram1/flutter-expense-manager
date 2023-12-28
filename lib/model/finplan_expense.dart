// file : expense.dart
class FinPlanExpense {
  final String beneficiary;
  final double amount;
  final DateTime date;
  final String id;

  const FinPlanExpense({
    required this.beneficiary,
    required this.amount,
    required this.date,
    required this.id
  });

  Map<String, dynamic> toMap() {
    return {
      'beneficiary': beneficiary,
      'amount': amount,
      'date': date.toIso8601String(), // Convert DateTime to String
      'id': id,
    };
  }
}