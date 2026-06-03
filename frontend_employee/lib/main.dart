import 'package:flutter/material.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_extended_screens.dart';
import 'screens/admin_portal_screens.dart';
import 'screens/auth_gate_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/revenue_detail_screen.dart';
import 'screens/hotel_list_screen.dart';
import 'screens/hotel_form_screen.dart';
import 'screens/room_list_screen.dart';
import 'screens/room_form_screen.dart';
import 'screens/owner_room_tools_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/booking_management_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/review_list_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/settings_menu_screen.dart';
import 'screens/policy_config_screen.dart';
import 'screens/bank_info_screen.dart';

void main() {
  runApp(const StaySmartApp());
}

class StaySmartApp extends StatelessWidget {
  const StaySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStay Hotel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3F63B5),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGateScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-users': (context) => const AdminUserManagementScreen(),
        '/admin-roles': (context) => const AdminRolePermissionScreen(),
        '/admin-hotels': (context) => const AdminHotelManagementScreen(),
        '/admin-bookings': (context) => const AdminBookingManagementScreen(),
        '/admin-payments': (context) => const AdminPaymentManagementScreen(),
        '/admin-reviews': (context) => const AdminReviewModerationScreen(),
        '/admin-notifications': (context) =>
            const AdminNotificationManagementScreen(),
        '/admin-system-configs': (context) => const AdminSystemConfigScreen(),
        '/admin-audit-logs': (context) => const AdminAuditLogScreen(),
        '/admin-integrations': (context) =>
            const AdminIntegrationHealthScreen(),
        '/admin-locations': (context) => const AdminLocationManagementScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),

        '/home': (context) => const HomeScreen(),
        '/revenue-detail': (context) => const RevenueDetailScreen(),

        '/hotel-list': (context) => const HotelListScreen(),
        '/hotel-form': (context) => HotelFormScreen(
          hotel:
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?,
        ),
        '/room-list': (context) => RoomListScreen(
          hotel:
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?,
        ),
        '/room-form': (context) {
          final arguments =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return RoomFormScreen(
            room: arguments?['room'] as Map<String, dynamic>?,
            initialHotel: arguments?['hotel'] as Map<String, dynamic>?,
          );
        },
        '/room-tools': (context) => const OwnerRoomToolsScreen(),

        '/booking': (context) => const BookingManagementScreen(),
        '/booking-detail': (context) => BookingDetailScreen(
          bookingId: ModalRoute.of(context)?.settings.arguments as int?,
        ),
        '/transaction': (context) => const TransactionHistoryScreen(),

        '/notifications': (context) => const NotificationScreen(),
        '/reviews': (context) => const ReviewListScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/chat-detail': (context) => ChatDetailScreen(
          conversation:
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?,
        ),

        '/settings': (context) => const SettingsMenuScreen(),
        '/policy-config': (context) => const PolicyConfigScreen(),
        '/bank-info': (context) => const BankInfoScreen(),
      },
    );
  }
}
