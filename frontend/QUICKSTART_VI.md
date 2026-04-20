# 🚀 Hướng dẫn bắt đầu nhanh - HHBN Flutter App

## 📱 Giao diện đã được tạo

Bạn có một ứng dụng Flutter hoàn chỉnh với:

✅ **Màn hình Splash** - Hiển thị logo HHBN với tagline  
✅ **Màn hình Đăng nhập** - Đầy đủ với email, password, Google login  
✅ **Hệ thống màu sắc** - Gradient backgrounds đẹp mắt  
✅ **Widgets tùy chỉnh** - Custom text fields với focus states  
✅ **Validation** - Form validation sẵn sàng  
✅ **Routing** - Navigation giữa các màn hình  

## 🔧 Cài đặt ngay

### Bước 1: Mở Terminal

```powershell
# Điều hướng tới thư mục frontend
cd "d:\e-project 4\Booking app\frontend"
```

### Bước 2: Cài đặt Dependencies

```bash
flutter pub get
```

### Bước 3: Chạy ứng dụng

```bash
# Trên Android Emulator hoặc thiết bị Android
flutter run

# Trên Chrome (Web)
flutter run -d chrome

# Danh sách thiết bị có sẵn
flutter devices
```

## 📁 File cấu trúc chính

```
lib/
├── main.dart              ← Điểm vào ứng dụng
├── screens/
│   ├── splash_screen.dart  ← Màn hình Splash
│   ├── login_screen.dart   ← Màn hình Login
│   └── widgets/
│       └── custom_text_field.dart  ← Widget input
└── utils/
    ├── colors.dart        ← Màu sắc
    ├── strings.dart       ← Chuỗi text
    ├── theme.dart         ← Chủ đề
    ├── validators.dart    ← Validation
    └── constants.dart     ← Hằng số
```

## 🎯 Các tính năng chính

### 1. Màn hình Splash (3 giây)
```
┌─────────────────────────┐
│        GRADIENT          │
│                         │
│         ○ HHBN ○        │
│                         │
│  Đặt phòng nhanh        │
│  Trải nghiệm sang!      │
│                         │
└─────────────────────────┘
```

### 2. Màn hình Đăng nhập
```
┌─────────────────────────┐
│  ← (back button)        │
│                         │
│  Log In                 │
│  Log in to your account │
│                         │
│  📧 Email: _________    │
│                         │
│  🔒 Password: _______   │
│     [👁 toggle]         │
│                         │
│  Forgot password?       │
│                         │
│  [  LOG IN BUTTON  ]    │
│                         │
│          or             │
│                         │
│  [ LOG IN WITH GOOGLE ] │
│                         │
│  Don't have account?    │
│  Sign Up                │
└─────────────────────────┘
```

## 💻 Command Thường Dùng

```bash
# Cài dependencies
flutter pub get

# Format code
flutter format lib/

# Analyze code
flutter analyze

# Test hot reload (khi ứng dụng đang chạy)
# Nhấn: r (reload hot)
#       R (restart)
#       q (quit)

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Clean build 
flutter clean
flutter pub get
```

## 🎨 Tùy chỉnh giao diện

### Đổi màu sắc
Edit file `lib/utils/colors.dart`:
```dart
static const Color primaryBlue = Color(0xFF1E5BA8);  // Đổi màu ở đây
```

### Đổi text/strings
Edit file `lib/utils/strings.dart`:
```dart
static const String appName = 'HHBN';  // Đổi tên ứng dụng
```

### Customize button
Edit file `lib/screens/login_screen.dart`:
```dart
// Tìm và chỉnh sửa widget button
```

## 📦 Thêm Features

### 1. Thêm Google Sign-In
```bash
flutter pub add google_sign_in
```

### 2. Thêm State Management (Provider)
```bash
flutter pub add provider
```

### 3. Thêm API Requests
```bash
flutter pub add http
```

### 4. Thêm Local Storage
```bash
flutter pub add shared_preferences
```

## 🐛 Troubleshooting

### Error: "flutter: command not found"
```bash
# Thêm Flutter vào PATH hoặc sử dụng đường dẫn đầy đủ
C:/flutter/bin/flutter run
```

### Error: "No devices found"
```bash
# Kiểm tra thiết bị
flutter devices

# Nếu emulator, mở từ Android Studio hoặc
emulator -list-avds
emulator -avd <avd_name>
```

### Error: "Gradle error"
```bash
flutter clean
flutter pub get
flutter run
```

### Error: "Permission denied" (iOS)
```bash
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData
```

## 📚 Tấn công tiếp theo

### Màn hình cần tạo:
- [ ] Sign up screen
- [ ] Forgot password screen
- [ ] Home screen (Danh sách khách sạn)
- [ ] Hotel details screen
- [ ] Booking screen
- [ ] Payment screen
- [ ] My bookings screen
- [ ] Profile screen
- [ ] Settings screen

### Backend Integration:
- [ ] Kết nối API login
- [ ] Google Sign-In setup
- [ ] Token management
- [ ] Error handling

### Database:
- [ ] Setup local database
- [ ] Cache user data
- [ ] Store booking history

## 🎓 Tài liệu hữu ích

- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Firebase for Flutter](https://firebase.flutter.dev/)

## ✨ Format Code

```bash
# Format toàn bộ lib folder
flutter format lib/

# Format một file cụ thể
flutter format lib/screens/login_screen.dart
```

## 📞 Hỗ trợ nhanh

Nếu gặp vấn đề:

1. Kiểm tra Flutter installation:
```bash
flutter doctor
```

2. Cập nhật Flutter:
```bash
flutter upgrade
```

3. Clean project:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🎉 Bắt đầu ngay!

```bash
cd "d:\e-project 4\Booking app\frontend"
flutter pub get
flutter run
```

**Ứng dụng sẽ chạy sau khoảng 1-2 phút tùy theo thiết bị!**

---

Tham khảo:
- **README.md** - Hướng dẫn chi tiết (Tiếng Anh)
- **SETUP_VI.md** - Hướng dẫn chi tiết (Tiếng Việt)  
- **PROJECT_SUMMARY_VI.md** - Tóm tắt dự án

Happy Coding! 🚀
