🌿 Mental Health App – Flutter Wellness Companion

<p align="center">
<strong>Một ứng dụng Flutter đa nền tảng, hiện đại được thiết kế để cải thiện sức khỏe tinh thần thông qua tự nhận thức, hỗ trợ AI, và kết nối cộng đồng.</strong>
</p>

🧘 Tổng quan

Mental Health App là một ứng dụng di động đa ngôn ngữ được xây dựng bằng Flutter. Nó giúp người dùng theo dõi sức khỏe tinh thần, kết nối với cộng đồng hỗ trợ, và trò chuyện với một trợ lý AI thông minh.

Ứng dụng có UI tối giản, hiệu ứng chuyển cảnh mượt mà, và một thanh điều hướng cong (curved bottom navigation bar), tạo ra trải nghiệm người dùng bình tĩnh và dễ chịu.

✨ Tính năng Nổi bật

🤖 AI Companion (Tính năng mới!)

Trò chuyện thời gian thực với trợ lý AI sử dụng Google Gemini.

Lịch sử trò chuyện được lưu trữ an toàn và đồng bộ hóa bằng Cloud Firestore.

Tự động lưu và tải các cuộc hội thoại, cho phép bạn tiếp tục bất cứ lúc nào.

Hỗ trợ xem lại lịch sử chat, ghim (pin) và xóa các cuộc tròIs chuyện.

🏠 Màn hình chính (Home)

Bảng điều khiển cá nhân hóa với tên người dùng và avatar.

Trích dẫn tạo động lực và lời nhắc nhở sức khỏe tinh thần.

Tương tác: Chọn biểu cảm trạng thái (vui, buồn, v.v.) trực tiếp trên màn hình.

💬 Cộng đồng (Community)

(Hiện tại) Là nơi để khởi chạy màn hình AI Companion.

(Tương lai: Nơi tham gia các cuộc thảo luận về sức khỏe tinh thần.)

👤 Hồ sơ (Profile)

Chỉnh sửa tên và ảnh đại diện (từ thư viện hoặc URL) trong thời gian thực.

Các cập nhật được phản ánh ngay lập tức trên tất cả các trang.

🌍 Đa ngôn ngữ (Localization)

Ứng dụng này hỗ trợ ba ngôn ngữ:

🇺🇸 English (en)

🇻🇳 Vietnamese (vi)

🇷🇺 Russian (ru)

Bạn có thể chuyển đổi ngôn ngữ tự động bằng cách sử dụng:

MentalHealthApp.setLocale(context, Locale('vi'));

🧩 Kiến trúc & Công nghệ

Thành phần

Mô tả

Framework

Flutter (Material Design)

Ngôn ngữ

Dart

Backend & Database

Firebase Auth, Cloud Firestore

Tích hợp AI

Google Gemini API (thông qua http)

Quản lý State

StatefulWidget (Lifted State), setState, StreamSubscription

Điều hướng

curved_navigation_bar

Đa ngôn ngữ

flutter_localizations, AppLocalizations

Hiệu ứng

AnimatedSwitcher, flutter_staggered_animations

UI Theme

Font Urbanist, Glassmorphism (Kính mờ), Liquid Background (Nền lỏng)

Nền tảng

Android & iOS

⚙️ Cấu trúc Dự án

lib/
│
├── main.dart # Điểm vào ứng dụng, Khởi tạo Firebase
├── home_screen.dart # Màn hình chính
├── sessions_screen.dart # (Placeholder)
├── community_screen.dart # Màn hình cộng đồng
├── ai_chat_screen.dart # <-- Giao diện Chat AI & Logic Firebase
├── profile_screen.dart # Trang hồ sơ người dùng
├── widgets/
│ ├── liquid_background.dart # Hiệu ứng nền lỏng (đã tối ưu)
│ └── glass_card.dart # UI Kính mờ (Glassmorphism)
└── l10n/
└── app_localizations.dart # Xử lý đa ngôn ngữ

🛠️ Cài đặt & Khởi chạy

Yêu cầu

Flutter SDK ≥ 3.0.0

Một dự án Firebase (đã bật Auth & Firestore)

Một API Key của Google Gemini

1️⃣ Sao chép (Clone) Kho lưu trữ

git clone [https://github.com/NguyenThanhDat2004/MentalHealth_app.git](https://github.com/NguyenThanhDat2004/MentalHealth_app.git)
cd MentalHealth_app

2️⃣ Cấu hình Firebase

Dự án này yêu cầu Firebase.

Chạy flutterfire configure và chọn dự án Firebase của bạn (như chúng ta đã làm).

Lệnh này sẽ tự động tạo tệp lib/firebase_options.dart.

3️⃣ Cài đặt Gói (Packages)

flutter pub get

4️⃣ Cài đặt API Key (RẤT QUAN TRỌNG)

Ứng dụng này sử dụng Google Gemini API Key. Để chạy, bạn bắt buộc phải cung cấp API key thông qua --dart-define.

Cách dễ nhất là sử dụng cấu hình VS Code đã có sẵn:

Mở tệp .vscode/launch.json.

Thay thế AIzaSy... bằng API Key Gemini của riêng bạn.

Chạy ứng dụng bằng cách sử dụng tab "Run and Debug" (Chạy và Gỡ lỗi), và chọn "Flutter with Gemini AI".

5️⃣ Build (Xuất bản) Ứng dụng

Để build bản release (ví dụ: APK), bạn phải "tiêm" API key vào lệnh build:

flutter build apk --dart-define=GEMINI_API_KEY=YOUR_OWN_KEY_HERE

📱 Ảnh chụp màn hình

<p align="center">
<img src="https://github.com/user-attachments/assets/2d0cdbce-2d91-4149-846d-e2b0d643db79" width="220" />
<img src="https://github.com/user-attachments/assets/502c7aff-5e54-4ff4-b5c9-e74cde4871cc" width="220" />
<img src="https://github.com/user-attachments/assets/4579506e-f408-4988-8e7b-200f7799a8cb" width="220" />
</p>

💡 Cải tiến trong tương lai

[x] Tích hợp Firebase Authentication 🔥

[x] Trò chuyện với AI (Gemini & Firestore) 🤖

[x] Theo dõi tâm trạng (Clickable moods on Home screen) 📓

[ ] Chế độ Tối (Dark mode) 🌙

[ ] Thông báo đẩy (Push notifications) hàng ngày 🔔

🧠 Kỹ năng Lập trình viên

<p align="left">
<img src="https://www.google.com/search?q=https://skillicons.dev/icons%3Fi%3Ddart,flutter,firebase,java,kotlin,swift" alt="Mobile" />
<img src="https://skillicons.dev/icons?i=git,github,vscode,androidstudio,postman,figma" alt="Tools" />
</p>

📜 Giấy phép (License)

Dự án này được cấp phép theo MIT License.
Xem tệp LICENSE để biết chi tiết.

<p align="center">
⭐ Nếu bạn thấy dự án này hữu ích, hãy tặng nó một <b>Ngôi sao (Star)</b> trên GitHub để hỗ trợ phát triển! ⭐
</p>
