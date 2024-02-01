// message_dao.dart
import 'package:sqflite/sqflite.dart';
import '../model/finplan_message.dart';

class FinPlanMessageDao {
  final Database _database;

  FinPlanMessageDao(this._database);

  Future<void> insertMessage(FinPlanMessage message) async {
    await _database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Other methods for CRUD operations and queries related to messages
}
