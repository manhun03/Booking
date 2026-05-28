import 'package:flutter/foundation.dart';

import 'language_store.dart';

class LanguageService extends ChangeNotifier {
  factory LanguageService() => _instance;

  LanguageService._();

  static final LanguageService _instance = LanguageService._();

  static const String vietnamese = 'vi';
  static const String english = 'en';

  String _code = vietnamese;

  String get code => _code;

  bool get isVietnamese => _code == vietnamese;

  String get displayName => isVietnamese ? 'Tiếng Việt' : 'English';

  Future<void> restore() async {
    final storedCode = readStoredLanguageCode();
    if (_isSupported(storedCode)) {
      _code = storedCode!;
    }
  }

  Future<void> setLanguage(String code) async {
    if (!_isSupported(code) || code == _code) return;
    _code = code;
    writeStoredLanguageCode(code);
    notifyListeners();
  }

  String t(String key) {
    return _translations[_code]?[key] ?? _translations[english]?[key] ?? key;
  }

  bool _isSupported(String? code) {
    return code == vietnamese || code == english;
  }
}

const Map<String, Map<String, String>> _translations = {
  LanguageService.vietnamese: {
    'nav.home': 'Trang chủ',
    'nav.message': 'Tin nhắn',
    'nav.booking': 'Đặt phòng',
    'nav.search': 'Tìm kiếm',
    'nav.menu': 'Menu',
    'language.title': 'Ngôn ngữ',
    'language.subtitle':
        'Chọn ngôn ngữ hiển thị cho ứng dụng và website StaySmart.',
    'language.current': 'Ngôn ngữ hiện tại',
    'language.applies':
        'Thay đổi này sẽ áp dụng cho phần cài đặt và các màn hình đã hỗ trợ ngay sau khi bạn chọn ngôn ngữ mới.',
    'language.choose': 'Chọn ngôn ngữ',
    'language.vietnamese': 'Tiếng Việt',
    'language.english': 'Tiếng Anh',
    'language.saved': 'Đã đổi ngôn ngữ',
    'profile.title': 'Thông tin',
    'profile.accountSettings': 'Cài đặt tài khoản',
    'profile.subtitle':
        'Quản lý hồ sơ, thông tin liên hệ và các thiết lập tài khoản StaySmart.',
    'profile.member': 'Thành viên StaySmart',
    'profile.loading': 'Đang tải hồ sơ',
    'profile.bookings': 'Đặt phòng',
    'profile.savedHotels': 'Khách sạn đã lưu',
    'profile.favorites': 'Yêu thích',
    'profile.promotions': 'Ưu đãi',
    'profile.edit': 'Chỉnh sửa hồ sơ',
    'profile.editShort': 'Chỉnh sửa',
    'profile.logout': 'Đăng xuất',
    'profile.quickSettings': 'Thiết lập nhanh',
    'profile.quickSettingsSubtitle':
        'Mở nhanh các khu vực quản lý tài khoản thường dùng.',
    'profile.home': 'Trang chủ',
    'profile.bankAccount': 'Tài khoản ngân hàng',
    'profile.history': 'Lịch sử thuê',
    'profile.paymentCards': 'Thẻ thanh toán',
    'profile.notifications': 'Thông báo',
    'profile.language': 'Ngôn ngữ',
    'profile.policies': 'Chính sách',
    'profile.email': 'Địa chỉ email',
    'profile.emailVerified': 'Đã xác minh',
    'profile.emailUnverified': 'Chưa xác minh',
    'profile.verifyEmail': 'Xác minh email',
    'profile.sendVerification': 'Gửi mã',
    'profile.sendingVerification': 'Đang gửi',
    'profile.phone': 'Số điện thoại',
    'profile.password': 'Mật khẩu',
    'profile.changePassword': 'Đổi mật khẩu',
    'profile.status': 'Trạng thái',
    'profile.missingEmail': 'Chưa có email',
    'profile.notUpdated': 'Chưa cập nhật',
    'more.title': 'Menu',
    'more.subtitle':
        'Quản lý tài khoản, ưu đãi, cài đặt và các tác vụ hỗ trợ trong cùng một khu vực.',
    'more.accountSettings': 'Cài đặt tài khoản',
    'more.accountSettingsSubtitle': 'Quản lý hồ sơ và thông tin cá nhân',
    'more.favoritesSubtitle': 'Xem khách sạn và phòng bạn đã lưu',
    'more.promotionsSubtitle': 'Áp dụng ưu đãi khách sạn có giới hạn',
    'more.languageSubtitle': 'Đổi ngôn ngữ ứng dụng',
    'more.privacyPolicy': 'Chính sách bảo mật',
    'more.privacyPolicySubtitle':
        'Điều khoản, quyền riêng tư và chính sách đặt phòng',
    'more.logoutSubtitle': 'Đăng xuất khỏi tài khoản',
    'more.user': 'Người dùng StaySmart',
    'more.memberAccount': 'Tài khoản thành viên',
    'more.quickActions': 'Thao tác nhanh',
    'more.quickActionsSubtitle':
        'Các mục được sắp xếp dạng lưới để thao tác nhanh trên website.',
    'changePassword.title': 'Đổi mật khẩu',
    'changePassword.subtitle':
        'Cập nhật mật khẩu đăng nhập cho tài khoản customer của bạn.',
    'changePassword.current': 'Mật khẩu hiện tại',
    'changePassword.new': 'Mật khẩu mới',
    'changePassword.confirm': 'Xác nhận mật khẩu mới',
    'changePassword.save': 'Lưu mật khẩu',
    'changePassword.saving': 'Đang lưu',
    'changePassword.currentRequired': 'Vui lòng nhập mật khẩu hiện tại',
    'changePassword.newRequired': 'Vui lòng nhập mật khẩu mới',
    'changePassword.confirmRequired': 'Vui lòng xác nhận mật khẩu mới',
    'changePassword.strong':
        'Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt',
    'changePassword.mismatch': 'Mật khẩu xác nhận không khớp',
    'changePassword.success': 'Đã đổi mật khẩu thành công',
    'changePassword.customerOnly':
        'Chỉ tài khoản customer mới được đổi mật khẩu tại đây.',
    'changePassword.loginRequired': 'Bạn cần đăng nhập để đổi mật khẩu.',
    'emailVerification.title': 'Xác minh email',
    'emailVerification.subtitle':
        'Nhập mã xác minh được gửi tới email của bạn để hoàn tất xác minh tài khoản.',
    'emailVerification.token': 'Mã xác minh',
    'emailVerification.generatedToken': 'Mã xác minh đã tạo',
    'emailVerification.sendSuccess': 'Đã gửi mã xác minh email',
    'emailVerification.verify': 'Xác minh',
    'emailVerification.verifying': 'Đang xác minh',
    'emailVerification.tokenRequired': 'Vui lòng nhập mã xác minh',
    'emailVerification.success': 'Email đã được xác minh',
    'emailVerification.customerOnly':
        'Chỉ tài khoản customer mới được xác minh email tại đây.',
    'emailVerification.loginRequired': 'Bạn cần đăng nhập để xác minh email.',
  },
  LanguageService.english: {
    'nav.home': 'Home',
    'nav.message': 'Message',
    'nav.booking': 'Booking',
    'nav.search': 'Search',
    'nav.menu': 'Menu',
    'language.title': 'Language',
    'language.subtitle':
        'Choose the display language for the StaySmart app and website.',
    'language.current': 'Current language',
    'language.applies':
        'This change applies to settings and supported screens immediately after you choose a new language.',
    'language.choose': 'Choose language',
    'language.vietnamese': 'Vietnamese',
    'language.english': 'English',
    'language.saved': 'Language changed',
    'profile.title': 'Information',
    'profile.accountSettings': 'Account Settings',
    'profile.subtitle':
        'Manage your profile, contact information and StaySmart account settings.',
    'profile.member': 'StaySmart member',
    'profile.loading': 'Loading profile',
    'profile.bookings': 'Bookings',
    'profile.savedHotels': 'Saved hotels',
    'profile.favorites': 'Favorites',
    'profile.promotions': 'Promotions',
    'profile.edit': 'Edit profile',
    'profile.editShort': 'Edit',
    'profile.logout': 'Logout',
    'profile.quickSettings': 'Quick settings',
    'profile.quickSettingsSubtitle':
        'Open frequently used account management areas quickly.',
    'profile.home': 'Home',
    'profile.bankAccount': 'Bank account',
    'profile.history': 'Rental history',
    'profile.paymentCards': 'Payment cards',
    'profile.notifications': 'Notifications',
    'profile.language': 'Language',
    'profile.policies': 'Policies',
    'profile.email': 'Email address',
    'profile.emailVerified': 'Verified',
    'profile.emailUnverified': 'Unverified',
    'profile.verifyEmail': 'Verify email',
    'profile.sendVerification': 'Send code',
    'profile.sendingVerification': 'Sending',
    'profile.phone': 'Phone number',
    'profile.password': 'Password',
    'profile.changePassword': 'Change password',
    'profile.status': 'Status',
    'profile.missingEmail': 'No email',
    'profile.notUpdated': 'Not updated',
    'more.title': 'Menu',
    'more.subtitle':
        'Manage account, promotions, settings and support actions in one place.',
    'more.accountSettings': 'Account Settings',
    'more.accountSettingsSubtitle':
        'Manage your profile and personal information',
    'more.favoritesSubtitle': 'Review hotels and rooms you saved',
    'more.promotionsSubtitle': 'Apply deals and limited hotel offers',
    'more.languageSubtitle': 'Change app language',
    'more.privacyPolicy': 'Privacy Policy',
    'more.privacyPolicySubtitle': 'Terms, privacy and booking policies',
    'more.logoutSubtitle': 'Sign out of your account',
    'more.user': 'StaySmart User',
    'more.memberAccount': 'Member account',
    'more.quickActions': 'Quick actions',
    'more.quickActionsSubtitle':
        'Items are arranged in a grid for quick actions on the website.',
    'changePassword.title': 'Change password',
    'changePassword.subtitle':
        'Update the login password for your customer account.',
    'changePassword.current': 'Current password',
    'changePassword.new': 'New password',
    'changePassword.confirm': 'Confirm new password',
    'changePassword.save': 'Save password',
    'changePassword.saving': 'Saving',
    'changePassword.currentRequired': 'Please enter your current password',
    'changePassword.newRequired': 'Please enter your new password',
    'changePassword.confirmRequired': 'Please confirm your new password',
    'changePassword.strong':
        'Password must be at least 8 characters and include uppercase, lowercase, number and special character',
    'changePassword.mismatch': 'Confirmation password does not match',
    'changePassword.success': 'Password changed successfully',
    'changePassword.customerOnly':
        'Only customer accounts can change password here.',
    'changePassword.loginRequired': 'You need to sign in to change password.',
    'emailVerification.title': 'Verify email',
    'emailVerification.subtitle':
        'Enter the verification code sent to your email to complete account verification.',
    'emailVerification.token': 'Verification code',
    'emailVerification.generatedToken': 'Generated verification code',
    'emailVerification.sendSuccess': 'Email verification code sent',
    'emailVerification.verify': 'Verify',
    'emailVerification.verifying': 'Verifying',
    'emailVerification.tokenRequired': 'Please enter the verification code',
    'emailVerification.success': 'Email has been verified',
    'emailVerification.customerOnly':
        'Only customer accounts can verify email here.',
    'emailVerification.loginRequired': 'You need to sign in to verify email.',
  },
};
