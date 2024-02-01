// file : finplan_exception.dart

class FinPlanException implements Exception {
  final String message;

  FinPlanException(this.message);

  @override
  String toString() {
    return 'FinPlanException: $message';
  }
}