import 'package:flutter/material.dart';

class DateRangeUtils {
  DateTimeRange getDefaultRange(String category) {
    final now = DateTime.now();
    final currentYear = DateTime(now.year);
    
    switch (category) {
      case '周目标':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateTimeRange(
          start: startOfWeek.isBefore(currentYear) ? currentYear : startOfWeek,
          end: endOfWeek.isAfter(DateTime(currentYear.year + 1)) 
              ? DateTime(currentYear.year + 1) 
              : endOfWeek,
        );
        
      case '月目标':
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: startOfMonth, end: endOfMonth);
        
      case '季目标':
        final quarterStartMonth = (now.month - 1) ~/ 3 * 3 + 1;
        final startOfQuarter = DateTime(now.year, quarterStartMonth);
        final endOfQuarter = DateTime(now.year, quarterStartMonth + 3, 0);
        return DateTimeRange(start: startOfQuarter, end: endOfQuarter);
        
      default:
        return DateTimeRange(start: now, end: now.add(const Duration(days: 7)));
    }
  }
}