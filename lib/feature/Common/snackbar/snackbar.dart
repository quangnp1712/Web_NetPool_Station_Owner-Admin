import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Vẫn cần Get để lấy context

/// Hiển thị một popup TÙY CHỈNH (dùng Overlay) ở góc trên bên trái.
///
/// [message]: Nội dung thông báo (vd: "Đăng nhập thành công").
/// [type]: Loại popup (SnackbarType.success hoặc SnackbarType.error).
void ShowSnackBar(String message, bool success) {
  // Lấy Overlay của GetMaterialApp
  // Get.overlayContext là context gốc của ứng dụng

  // --- SỬA LỖI Ở ĐÂY ---
  // 1. Khai báo `overlayEntry` là nullable (có thể rỗng)
  OverlayEntry? overlayEntry;
  // --- KẾT THÚC SỬA LỖI ---

  // Tạo một OverlayEntry
  overlayEntry = OverlayEntry(
    builder: (context) {
      // Dùng Positioned để đặt vị trí TỰ DO (độc lập)
      return Positioned(
        top: 20,
        right: 20,
        child: _ToastWidget(
          message: message,
          success: success,
          // Khi widget này gọi onClose, nó sẽ tự xóa chính nó
          onClose: () {
            // --- SỬA LỖI Ở ĐÂY ---
            // 2. Dùng `?.remove()` để xóa an toàn (vì nó là nullable)
            //    (Không cần try-catch nữa)
            overlayEntry?.remove();
            // --- KẾT THÚC SỬA LỖI ---
          },
        ),
      );
    },
  );

  // Thêm entry vào Overlay
  Overlay.of(Get.overlayContext!).insert(overlayEntry);
}

/// Widget Toast (Bên trong Overlay)
/// Dùng StatefulWidget để quản lý AnimationController (cho progress bar)
class _ToastWidget extends StatefulWidget {
  final String message;
  final bool success;
  final VoidCallback onClose; // Hàm để gọi khi đóng

  const _ToastWidget({
    Key? key,
    required this.message,
    required this.success,
    required this.onClose,
  }) : super(key: key);

  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

/// State cho ToastWidget, dùng SingleTickerProviderStateMixin cho vsync
class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Color backgroundColor;
  late Color progressBarColor;
  late IconData iconData;

  @override
  void initState() {
    super.initState();

    // 1. Cài đặt màu sắc
    if (widget.success) {
      backgroundColor = const Color(0xFFE6F7ED);
      progressBarColor = const Color(0xFF28A745);
      iconData = Icons.check_circle;
    } else {
      backgroundColor = const Color(0xFFFDEBEC);
      progressBarColor = const Color(0xFFDC3545);
      iconData = Icons.error;
    }

    // 2. Cài đặt AnimationController cho progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 10 giây
    );

    // 3. Chạy animation ngược (từ 1.0 về 0.0)
    _progressController.reverse(from: 1.0);

    // 4. Thêm listener để tự động đóng khi animation hoàn tất
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onClose(); // Gọi hàm đóng
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose(); // Hủy controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dùng Material để style (shadow, shape) hiển thị đúng
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400, // Chiều rộng cố định
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Cắt nội dung con theo bo góc
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // 1. Nội dung (Icon, Text, Nút X)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Icon(iconData, color: progressBarColor, size: 32),
                  const SizedBox(width: 12),

                  // Text (Tự động xuống hàng)
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nút "x"
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    onPressed: widget.onClose, // Gọi hàm đóng khi bấm
                  ),
                ],
              ),
            ),

            // 2. Thanh Progress Bar (Chạy ngược)
            // Dùng AnimatedBuilder để lắng nghe controller
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value, // Giá trị từ 1.0 -> 0.0
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressBarColor,
                  ),
                  minHeight: 5, // Độ dày của thanh
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
