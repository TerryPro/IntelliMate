import 'package:intellimate/data/datasources/finance_datasource.dart';
import 'package:intellimate/domain/entities/finance.dart';
import 'package:intellimate/domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceDataSource _dataSource;

  FinanceRepositoryImpl(this._dataSource);

  @override
  Future<List<Finance>> getAllFinances() {
    return _dataSource.getAllFinances();
  }

  @override
  Future<Finance?> getFinanceById(String id) {
    return _dataSource.getFinanceById(id);
  }

  @override
  Future<void> createFinance(Finance finance) {
    return _dataSource.createFinance(finance);
  }

  @override
  Future<void> updateFinance(Finance finance) {
    return _dataSource.updateFinance(finance);
  }

  @override
  Future<void> deleteFinance(String id) {
    return _dataSource.deleteFinance(id);
  }

  @override
  Future<List<Finance>> getFinancesByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) {
    return _dataSource.getFinancesByDateRange(startDate, endDate);
  }

  @override
  Future<List<Finance>> getFinancesByType(String type) {
    return _dataSource.getFinancesByType(type);
  }

  @override
  Future<List<Finance>> getFinancesByCategory(String category) {
    return _dataSource.getFinancesByCategory(category);
  }

  @override
  Future<List<Finance>> getFinancesByDateRangeAndType(
    DateTime startDate, 
    DateTime endDate, 
    String type
  ) {
    return _dataSource.getFinancesByDateRangeAndType(startDate, endDate, type);
  }

  @override
  Future<double> getTotalIncomeByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) {
    return _dataSource.getTotalIncomeByDateRange(startDate, endDate);
  }

  @override
  Future<double> getTotalExpenseByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) {
    return _dataSource.getTotalExpenseByDateRange(startDate, endDate);
  }

  @override
  Future<Map<String, double>> getExpenseStatsByCategory(
    DateTime startDate, 
    DateTime endDate
  ) {
    return _dataSource.getExpenseStatsByCategory(startDate, endDate);
  }

  @override
  Future<Map<String, double>> getIncomeStatsByCategory(
    DateTime startDate, 
    DateTime endDate
  ) {
    return _dataSource.getIncomeStatsByCategory(startDate, endDate);
  }
} 