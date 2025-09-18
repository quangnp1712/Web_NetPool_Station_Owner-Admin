class DebugLogger {
  // Tạo một trường static để giữ đối tượng duy nhất của DebugLogger
  static final DebugLogger _instance = DebugLogger._internal();

  // Tạo phương thức factory để lấy đối tượng duy nhất của DebugLogger
  factory DebugLogger() {
    return _instance;
  }

  // Constructor riêng để tạo một instance duy nhất
  DebugLogger._internal();

  // Phương thức static để in log
  static void printLog(String message) {
    print('\x1B[32m$message\x1B[0m'); // Màu xanh lá
  }
}
