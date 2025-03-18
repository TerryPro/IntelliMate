// 简单的日志工具类
class AppLogger {
  static void log(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) return;
    // ignore: avoid_print
    print('[IntelliMate] $message');
  }
} 