import 'package:flutter/material.dart';
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
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),

        '/home': (context) => const HomeScreen(),
        '/revenue-detail': (context) => const RevenueDetailScreen(),

        '/hotel-list': (context) => const HotelListScreen(),
        '/hotel-form': (context) => const HotelFormScreen(),
        '/room-list': (context) => const RoomListScreen(),
        '/room-form': (context) => const RoomFormScreen(),

        '/booking': (context) => const BookingManagementScreen(),        
        '/booking-detail': (context) => const BookingDetailScreen(),
        '/transaction': (context) => const TransactionHistoryScreen(),

        '/notifications': (context) => const NotificationScreen(),
        '/reviews': (context) => const ReviewListScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/chat-detail': (context) => const ChatDetailScreen(),

        '/settings': (context) => const SettingsMenuScreen(),
        '/policy-config': (context) => const PolicyConfigScreen(),
        '/bank-info': (context) => const BankInfoScreen(),
      },
    );
  }
}