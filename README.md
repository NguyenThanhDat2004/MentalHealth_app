# 🧠 Mental Health App – Flutter Wellness Companion

<p align="center">
<strong>Một ứng dụng Flutter đa nền tảng hiện đại được thiết kế để cải thiện sức khỏe tinh thần thông qua tự nhận thức, hỗ trợ AI, và kết nối cộng đồng</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19.0-02569B?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-2.19.0-0175C2?style=for-the-badge&logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/AI-Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/2d0cdbce-2d91-4149-846d-e2b0d643db79" width="200" />
  <img src="https://github.com/user-attachments/assets/502c7aff-5e54-4ff4-b5c9-e74cde4871cc" width="200" />
  <img src="https://github.com/user-attachments/assets/4579506e-f408-4988-8e7b-200f7799a8cb" width="200" />
</p>

## 🎯 Tổng Quan

**Mental Health App** là một ứng dụng di động đa ngôn ngữ được xây dựng bằng Flutter, giúp người dùng theo dõi sức khỏe tinh thần, kết nối với cộng đồng hỗ trợ, và trò chuyện với trợ lý AI thông minh. Ứng dụng có UI tối giản, hiệu ứng chuyển cảnh mượt mà, và thanh điều hướng cong, tạo ra trải nghiệm người dùng bình tĩnh và dễ chịu.

## ✨ Tính Năng Nổi Bật

### 🤖 AI Companion

- 💬 Trò chuyện thời gian thực với trợ lý AI sử dụng Google Gemini
- 💾 Lịch sử trò chuyện được lưu trữ an toàn bằng Cloud Firestore
- 📚 Tự động lưu và tải các cuộc hội thoại
- 📌 Hỗ trợ xem lại, ghim và xóa lịch sử chat

### 🏠 Màn Hình Chính

- 🎛️ Bảng điều khiển cá nhân hóa với tên người dùng và avatar
- 💫 Trích dẫn tạo động lực và lời nhắc sức khỏe
- 😊 Chọn biểu cảm trạng thái trực tiếp (vui, buồn, v.v.)

### 💬 Cộng Đồng

- 🚀 Khởi chạy màn hình AI Companion
- 👥 Tương lai: Tham gia thảo luận về sức khỏe tinh thần

### 👤 Hồ Sơ

- ✏️ Chỉnh sửa tên và ảnh đại diện trong thời gian thực
- 🔄 Cập nhật ngay lập tức trên tất cả các trang

### 🌍 Đa Ngôn Ngữ

- 🇺🇸 **English** (en)
- 🇻🇳 **Vietnamese** (vi)
- 🇷🇺 **Russian** (ru)

## 🛠️ Công Nghệ & Kiến Trúc

### 🧩 Tech Stack

| Thành Phần           | Công Nghệ                                       |
| -------------------- | ----------------------------------------------- |
| **Framework**        | Flutter (Material Design)                       |
| **Ngôn ngữ**         | Dart                                            |
| **Backend**          | Firebase Auth, Cloud Firestore                  |
| **AI Integration**   | Google Gemini API                               |
| **State Management** | StatefulWidget, setState, StreamSubscription    |
| **Navigation**       | curved_navigation_bar                           |
| **Localization**     | flutter_localizations                           |
| **UI Effects**       | AnimatedSwitcher, flutter_staggered_animations  |
| **UI Theme**         | Font Urbanist, Glassmorphism, Liquid Background |

### 📁 Cấu Trúc Dự Án

```
lib/
│
├── main.dart                 # Điểm vào ứng dụng, Khởi tạo Firebase
├── home_screen.dart          # Màn hình chính
├── sessions_screen.dart      # (Placeholder)
├── community_screen.dart     # Màn hình cộng đồng
├── ai_chat_screen.dart       # Giao diện Chat AI & Logic Firebase
├── profile_screen.dart       # Trang hồ sơ người dùng
├── widgets/
│   ├── liquid_background.dart  # Hiệu ứng nền lỏng
│   └── glass_card.dart         # UI Kính mờ (Glassmorphism)
└── l10n/
    └── app_localizations.dart # Xử lý đa ngôn ngữ
```

## 🚀 Cài Đặt & Khởi Chạy

### 📋 Yêu Cầu

- Flutter SDK ≥ 3.0.0
- Dự án Firebase (đã bật Auth & Firestore)
- API Key Google Gemini

### 🔧 Các Bước Cài Đặt

1. **Sao chép kho lưu trữ**

```bash
git clone https://github.com/NguyenThanhDat2004/MentalHealth_app.git
cd MentalHealth_app
```

2. **Cấu hình Firebase**

```bash
flutterfire configure
```

3. **Cài đặt packages**

```bash
flutter pub get
```

4. **Cấu hình API Key**

- Mở file `.vscode/launch.json`
- Thay thế `AIzaSy...` bằng API Key Gemini của bạn
- Chạy ứng dụng với "Flutter with Gemini AI" trong VS Code

5. **Build ứng dụng**

```bash
flutter build apk --dart-define=GEMINI_API_KEY=YOUR_OWN_KEY_HERE
```

## 🎨 Giao Diện & Trải Nghiệm

### 🎭 Hiệu Ứng Visual

- **Liquid Background**: Nền động với hiệu ứng sóng lỏng
- **Glassmorphism**: Thẻ kính mờ với hiệu ứng trong suốt
- **Smooth Animations**: Chuyển cảnh mượt mà với AnimatedSwitcher
- **Curved Navigation**: Thanh điều hướng cong độc đáo

### 🎯 Trải Nghiệm Người Dùng

- 🧘‍♂️ Giao diện bình tĩnh, tối giản
- ⚡ Phản hồi nhanh, mượt mà
- 🌈 Màu sắc nhẹ nhàng, tốt cho mắt
- 📱 Thiết kế responsive cho mọi kích thước màn hình

## 🔮 Roadmap & Cải Tiến Tương Lai

### ✅ Đã Hoàn Thành

- [x] Tích hợp Firebase Authentication 🔥
- [x] Trò chuyện với AI (Gemini & Firestore) 🤖
- [x] Theo dõi tâm trạng trên Home screen 📓
- [x] Đa ngôn ngữ (EN, VI, RU) 🌍

### 🚧 Đang Phát Triển

- [ ] Chế độ Tối (Dark mode) 🌙
- [ ] Thông báo đẩy hàng ngày 🔔
- [ ] Tính năng cộng đồng đầy đủ 👥
- [ ] Theo dõi tâm trạng nâng cao 📊

## 👨‍💻 Kỹ Năng Lập Trình Viên

<p align="left">
  <img src="https://skillicons.dev/icons?i=dart,flutter,firebase,androidstudio,git,github,vscode" alt="Skills" />
</p>

## 📊 Thống Kê Dự Án

<p align="center">
  <img src="https://img.shields.io/github/stars/NguyenThanhDat2004/MentalHealth_app?style=for-the-badge" alt="Stars"/>
  <img src="https://img.shields.io/github/forks/NguyenThanhDat2004/MentalHealth_app?style=for-the-badge" alt="Forks"/>
  <img src="https://img.shields.io/github/issues/NguyenThanhDat2004/MentalHealth_app?style=for-the-badge" alt="Issues"/>
</p>

## 📄 Giấy Phép

Dự án này được cấp phép theo **MIT License**. Xem file [LICENSE](LICENSE) để biết chi tiết.

---

<p align="center">
⭐ <b>Nếu bạn thấy dự án này hữu ích, hãy tặng nó một Ngôi sao trên GitHub để hỗ trợ phát triển!</b> ⭐
</p>

<p align="center">
<sub>Được xây dựng với ❤️ bằng Flutter & Firebase</sub>
</p>
