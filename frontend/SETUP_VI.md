# StaySmart Hotel Booking App - Hướng dẫn thiết lập

## 📱 Giới thiệu

Đây là ứng dụng Flutter hoàn chỉnh cho hệ thống quản lý đặt phòng khách sạn StaySmart. Ứng dụng bao gồm màn hình Splash và màn hình Đăng nhập, được thiết kế theo mockup Figma của bạn.

## 🏗️ Cấu trúc dự án

```
frontend/
├── lib/
│   ├── main.dart                      # Điểm vào ứng dụng
│   ├── screens/
│   │   ├── splash_screen.dart         # Màn hình Splash
│   │   ├── login_screen.dart          # Màn hình Đăng nhập
│   │   ├── widgets/
│   │   │   └── custom_text_field.dart # Widget trường nhập văn bản tùy chỉnh
│   │   └── index.dart                 # File xuất các screen
│   ├── utils/
│   │   ├── colors.dart                # Các màu sắc
│   │   ├── strings.dart               # Các chuỗi văn bản
│   │   ├── theme.dart                 # Chủ đề ứng dụng
│   │   ├── validators.dart            # Các hàm xác thực dữ liệu
│   │   ├── constants.dart             # Các hằng số
│   │   └── index.dart                 # File xuất các util
│   └── assets/
│       ├── images/                    # Hình ảnh
│       └── fonts/                     # Font chữ
├── pubspec.yaml                       # Cấu hình dự án
├── analysis_options.yaml              # Tùy chọn phân tích
├── README.md                          # Tài liệu chính
└── .gitignore                         # File git ignore
```

## 🚀 Hướng dẫn cài đặt

### 1. Yêu cầu có sẵn

- Flutter SDK (>=3.0.0)
- Dart SDK (kèm theo Flutter)
- IDE: VS Code, Android Studio, hoặc XCode

### 2. Cài đặt Flutter

Nếu chưa cài Flutter, hãy tải từ: https://flutter.dev/docs/get-started/install

Kiểm tra cài đặt:
```bash
flutter --version
dart --version
```

### 3. Clone/Mở dự án

```bash
cd "d:\e-project 4\Booking app\frontend"
```

### 4. Cài đặt dependencies

```bash
flutter pub get
```

### 5. Chạy ứng dụng

#### Trên Android Emulator
```bash
flutter run
```

#### Trên thiết bị thực
```bash
# Kết nối thiết bị qua USB, sau đó:
flutter run
```

#### Trên iOS Simulator (macOS)
```bash
flutter run
```

#### Trên Web Browser
```bash
flutter run -d chrome
```

## 📋 Các tính năng hiện có

### 1. Màn hình Splash
- ✅ Logo StaySmart với tagline
- ✅ Chuyển đổi tự động sang màn hình Đăng nhập sau 3 giây
- ✅ Nền có gradient

### 2. Màn hình Đăng nhập
- ✅ Trường nhập Email với icon
- ✅ Trường nhập Password với nút hiển thị/ẩn
- ✅ Nút "Đăng nhập"
- ✅ Nút "Đăng nhập với Google"
- ✅ Liên kết "Quên mật khẩu?"
- ✅ Liên kết đến "Đăng ký"
- ✅ Nền gradient phù hợp thiết kế
- ✅ Nút quay lại

## 🎨 Bảng màu sắc

```dart
Primary Blue: #1E5BA8
Dark Blue: #0F3A5F
Light Blue: #2E7BC4
Gradient Start: #2D5A7B
Gradient End: #1A3A5C
White: #FFFFFF
Light Gray: #F5F5F5
Medium Gray: #999999
Dark Gray: #333333
```

## 📝 Các bước tiếp theo

### 1. Tích hợp Backend
Cập nhật `AppConstants.apiBaseUrl` với URL API của bạn:

```dart
// lib/utils/constants.dart
static const String apiBaseUrl = 'https://your-api.com/api';
```

### 2. Xác thực Google Sign-In
```bash
flutter pub add google_sign_in
```

Thêm cấu hình trong `pubspec.yaml` sau khi cài đặt.

### 3. Tạo các màn hình khác
- Màn hình Đăng ký
- Màn hình Quên mật khẩu
- Màn hình Chính (Trang chủ)
- Màn hình Danh sách phòng
- Màn hình Chi tiết phòng
- Màn hình Đặt phòng
- Màn hình Tài khoản

### 4. Thêm State Management
```bash
flutter pub add provider
# hoặc
flutter pub add getx
```

### 5. Thêm Local Storage
```bash
flutter pub add shared_preferences
# hoặc
flutter pub add hive
```

## 🔧 Các lệnh hữu ích

```bash
# Cài đặt dependencies
flutter pub get

# Nâng cấp dependencies
flutter pub upgrade

# Chạy linting
flutter analyze

# Format code
flutter format lib/
dart format lib/

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web

# Build Windows
flutter build windows

# Build macOS
flutter build macos

# Build Linux
flutter build linux

# Xóa file build
flutter clean

# Cập nhật Flutter SDK
flutter upgrade
```

## 📚 Tài liệu hữu ích

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Flutter Material Design](https://api.flutter.dev/flutter/material/material-library.html)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

## 🐛 Gỡ lỗi

### Lỗi dependencies
```bash
flutter pub clean
flutter pub get
```

### Lỗi build
```bash
flutter clean
flutter pub get
flutter run
```

### Kiểm tra thiết bị
```bash
flutter devices
```

## 💡 Mẹo phát triển

1. **Sử dụng Hot Reload**: Nhấn `r` trong terminal để reload hot
2. **Sử dụng Hot Restart**: Nhấn `R` để restart lại ứng dụng
3. **Xem logs**: `flutter logs`
4. **Debugger**: Sử dụng breakpoints trong IDE

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra Flutter version: `flutter --version`
2. Chạy `flutter doctor` để kiểm tra setup
3. Tham khảo Flutter documentation
4. Kiểm tra GitHub issues của các packages

## 📄 Giấy phép

MIT License - Tự do sử dụng và phát triển

---

**Chúc bạn phát triển ứng dụng thành công! 🎉**
