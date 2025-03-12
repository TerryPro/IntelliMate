import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/domain/entities/finance.dart';
import 'package:sqflite/sqflite.dart';

class FinanceDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // 将 Finance 对象转换为 Map
  Map<String, dynamic> _financeToMap(Finance finance) {
    return {
      'id': finance.id,
      'amount': finance.amount,
      'type': finance.type,
      'category': finance.category,
      'description': finance.description,
      'date': finance.date.millisecondsSinceEpoch,
      'payment_method': finance.paymentMethod,
      'created_at': finance.createdAt.millisecondsSinceEpoch,
      'updated_at': finance.updatedAt.millisecondsSinceEpoch,
    };
  }

  // 将 Map 转换为 Finance 对象
  Finance _mapToFinance(Map<String, dynamic> map) {
    return Finance(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      paymentMethod: map['payment_method'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // 获取所有财务记录
  Future<List<Finance>> getAllFinances() async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableFinance,
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => _mapToFinance(map)).toList();
  }

  // 根据ID获取单个财务记录
  Future<Finance?> getFinanceById(String id) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableFinance,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return _mapToFinance(maps.first);
    }
    
    return null;
  }

  // 创建财务记录
  Future<void> createFinance(Finance finance) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableFinance,
      _financeToMap(finance),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 更新财务记录
  Future<void> updateFinance(Finance finance) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableFinance,
      _financeToMap(finance),
      where: 'id = ?',
      whereArgs: [finance.id],
    );
  }

  // 删除财务记录
  Future<void> deleteFinance(String id) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableFinance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取指定日期范围内的财务记录
  Future<List<Finance>> getFinancesByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;
    
    final maps = await db.query(
      DatabaseHelper.tableFinance,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startMs, endMs],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => _mapToFinance(map)).toList();
  }

  // 获取指定类型的财务记录（收入/支出）
  Future<List<Finance>> getFinancesByType(String type) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableFinance,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => _mapToFinance(map)).toList();
  }

  // 获取指定类别的财务记录
  Future<List<Finance>> getFinancesByCategory(String category) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableFinance,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => _mapToFinance(map)).toList();
  }

  // 获取指定时间范围和类型的财务记录
  Future<List<Finance>> getFinancesByDateRangeAndType(
    DateTime startDate, 
    DateTime endDate, 
    String type
  ) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;
    
    final maps = await db.query(
      DatabaseHelper.tableFinance,
      where: 'date >= ? AND date <= ? AND type = ?',
      whereArgs: [startMs, endMs, type],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => _mapToFinance(map)).toList();
  }

  // 获取指定时间范围内的总收入
  Future<double> getTotalIncomeByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;
    
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.tableFinance}
      WHERE date >= ? AND date <= ? AND type = ?
    ''', [startMs, endMs, 'income']);
    
    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // 获取指定时间范围内的总支出
  Future<double> getTotalExpenseByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;
    
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.tableFinance}
      WHERE date >= ? AND date <= ? AND type = ?
    ''', [startMs, endMs, 'expense']);
    
    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // 获取指定时间范围内按类别分组的支出统计
  Future<Map<String, double>> getExpenseStatsByCategory(
    DateTime startDate, 
    DateTime endDate
  ) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;
    
    final results = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM ${DatabaseHelper.tableFinance}
      WHERE date >= ? AND date <= ? AND type = ?
      GROUP BY category
    ''', [startMs, endMs, 'expense']);
    
    final Map<String, double> stats = {};
    for (final row in results) {
      final category = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      stats[category] = total;
    }
    
    return stats;
  }

  // 获取指定时间范围内按类别分组的收入统计
  Future<Map<String, double>> getIncomeStatsByCategory(
    DateTime startDate, 
    DateTime endDate
  ) async {
    await _databaseHelper.ensureInitialized();
    
    final db = await _databaseHelper.database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;
    
    final results = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM ${DatabaseHelper.tableFinance}
      WHERE date >= ? AND date <= ? AND type = ?
      GROUP BY category
    ''', [startMs, endMs, 'income']);
    
    final Map<String, double> stats = {};
    for (final row in results) {
      final category = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      stats[category] = total;
    }
    
    return stats;
  }
} 