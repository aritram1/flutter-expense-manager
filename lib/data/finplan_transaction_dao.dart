// transaction_dao.dart
import 'package:sqflite/sqflite.dart';
import '../model/finplan_transaction.dart';

class FinPlanTransactionDao {
  final Database _database;

  FinPlanTransactionDao(this._database);

  Future<void> insertTransaction(FinPlanTransaction transaction) async {
    await _database.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Other methods for CRUD operations and queries related to transactions
}
