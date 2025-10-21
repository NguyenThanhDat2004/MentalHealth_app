Ứng dụng Sức khỏe Tinh thần - Flutter UI
Đây là một dự án Flutter mô phỏng và xây dựng một ứng dụng hoàn chỉnh về sức khỏe tinh thần và ευεξία. Dự án không chỉ dừng lại ở việc tái tạo giao diện mà còn tích hợp các tính năng cao cấp như trợ lý AI, quản lý trạng thái thông minh, và hỗ trợ đa ngôn ngữ.

Các Tính năng Nổi bật
Ứng dụng được trang bị nhiều tính năng hiện đại để mang lại trải nghiệm người dùng cao cấp:

Giao diện "Liquid Glass": Toàn bộ ứng dụng sử dụng phong cách thiết kế kính mờ (Glassmorphism) kết hợp với các khối màu "lỏng" chuyển động mượt mà ở phía sau, tạo ra một giao diện sang trọng và thư giãn.

Trợ lý AI (AI Companion): Tích hợp trực tiếp với Google Gemini API, cho phép người dùng trò chuyện và nhận được sự hỗ trợ tức thì từ AI, mô phỏng một người bạn đồng hành.

Hỗ trợ đa ngôn ngữ (i18n): Ứng dụng được cấu hình hoàn chỉnh để hỗ trợ 3 ngôn ngữ: Tiếng Anh, Tiếng Việt, và Tiếng Nga. Người dùng có thể chuyển đổi ngôn ngữ bất kỳ lúc nào trong màn hình Profile.

Cập nhật theo thời gian thực: Màn hình chính tự động cập nhật ngày, giờ và lời chào (Sáng, Trưa, Chiều, Tối) mỗi giây.

Đồng bộ hóa trạng thái: Tên và ảnh đại diện của người dùng được cập nhật tự động trên tất cả các màn hình sau khi họ chỉnh sửa trong Profile.

Hiệu ứng chuyển động mượt mà: Tất cả các tương tác, từ chuyển đổi màn hình đến hiển thị danh sách, đều được trang bị các hiệu ứng animation tinh tế.
Thanh điều hướng cong (Curved Navigation Bar): Sử dụng một thanh điều hướng cong độc đáo với hiệu ứng chuyển động mượt mà.
<img width="1290" height="2796" alt="image" src="https://github.com/user-attachments/assets/8aedbdc8-8aa2-49bf-b08c-93e8b15a7905" />

Bắt đầu
Để chạy dự án này trên máy của bạn, hãy làm theo các bước sau:

Yêu cầu
Đã cài đặt Flutter SDK (phiên bản 3.0 trở lên).

Một trình soạn thảo code như VS Code hoặc Android Studio.

Một thiết bị Android/iOS hoặc máy ảo đã được cấu hình.

Cài đặt
Clone a repository này:

git clone [https://github.com/NguyenThanhDat2004/MentalHealth_app.git](https://github.com/NguyenThanhDat2004/MentalHealth_app.git)
cd MentalHealth_app

Cài đặt các gói phụ thuộc:
Mở terminal trong thư mục gốc của dự án và chạy lệnh:

flutter pub get

Lệnh này sẽ tự động tải về tất cả các gói cần thiết và tạo ra các tệp dịch tự động.

Cấu hình API Key (Quan trọng):

Truy cập Google AI Studio để lấy API Key cho Gemini.

Mở tệp lib/ai_chat_screen.dart.

Tìm đến dòng const String _apiKey = 'YOUR_GOOGLE_API_KEY'; và thay thế 'YOUR_GOOGLE_API_KEY' bằng chuỗi key bạn đã lấy.

Chạy ứng dụng:

flutter run

Cấu trúc dự án
Dự án được tổ chức một cách rõ ràng để dễ dàng bảo trì và mở rộng:

lib
  l10n                   # Chứa các tệp dịch (.arb)
  widgets                # Chứa các widget có thể tái sử dụng (LiquidBackground, GlassCard)
  ai_chat_screen.dart   # Màn hình trò chuyện với AI
  community_screen.dart # Màn hình Cộng đồng
  home_screen.dart      # Màn hình chính
  main.dart             # Điểm vào chính, quản lý điều hướng và trạng thái chung
  profile_screen.dart   # Màn hình Hồ sơ người dùng
  sessions_screen.dart  # Màn hình các buổi học
