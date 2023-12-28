// file : transaction.dart
class FinPlanTransaction {
  final String beneficiary;
  final double amount;
  final DateTime date;
  final String id;
  final String type;

  const FinPlanTransaction({
    required this.beneficiary,
    required this.amount,
    required this.date,
    required this.id,
    required this.type
  });

  Map<String, dynamic> toMap() {
    return {
      'beneficiary': beneficiary,
      'amount': amount,
      'date': date.toIso8601String(), // Convert DateTime to String
      'id': id,
      'type' : type
    };
  }
}