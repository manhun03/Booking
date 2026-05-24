import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/create_new_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/message_screen.dart';
import 'screens/message_chat_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/change_booking_date_screen.dart';
import 'screens/change_booking_time_screen.dart';
import 'screens/cancel_booking_screen.dart';
import 'screens/more_screen.dart';
import 'screens/hotel_detail_screen.dart';
import 'screens/room_list_screen.dart';
import 'screens/room_detail_screen.dart';
import 'screens/booking_form_screen.dart';
import 'screens/payment_information_screen.dart';
import 'screens/payment_card_screen.dart';
import 'screens/payment_no_card_screen.dart';
import 'screens/booking_success_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/promotion_screen.dart';
import 'screens/add_promotion_screen.dart';
import 'screens/credit_card_screen.dart';
import 'screens/add_card_screen.dart';
import 'screens/language_screen.dart';
import 'screens/legal_policies_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const StaySmartApp());
}

class StaySmartApp extends StatelessWidget {
  const StaySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaySmart',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/create-new-password': (context) => const CreateNewPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/message': (context) => const MessageScreen(),
        '/booking': (context) => const BookingScreen(),
        '/booking-detail': (context) {
          final booking = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return BookingDetailScreen(booking: booking);
        },
        '/change-booking-date': (context) {
          final booking = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ChangeBookingDateScreen(booking: booking);
        },
        '/change-booking-time': (context) {
          final booking = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ChangeBookingTimeScreen(booking: booking);
        },
        '/cancel-booking': (context) {
          final booking = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return CancelBookingScreen(booking: booking);
        },
        '/more': (context) => const MoreScreen(),
        '/user-profile': (context) => const UserProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/favorite': (context) => const FavoriteScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/promotion': (context) => const PromotionScreen(),
        '/add-promotion': (context) => const AddPromotionScreen(),
        '/credit-card': (context) => const CreditCardScreen(),
        '/add-card': (context) => const AddCardScreen(),
        '/language': (context) => const LanguageScreen(),
        '/legal-policies': (context) => const LegalPoliciesScreen(),
        '/room-list': (context) => const RoomListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/hotel-detail') {
          final hotel = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
            settings: settings,
          );
        }
        if (settings.name == '/message-chat') {
          final contact = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MessageChatScreen(contact: contact),
            settings: settings,
          );
        }
        if (settings.name == '/room-list') {
          final hotel = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => RoomListScreen(hotel: hotel),
            settings: settings,
          );
        }
        if (settings.name == '/room-detail') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => RoomDetailScreen(room: room, hotel: hotel),
            settings: settings,
          );
        }
        if (settings.name == '/booking-form') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          final roomCount = args?['roomCount'] as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) => BookingFormScreen(
              room: room,
              hotel: hotel,
              roomCount: roomCount,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/payment-information') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          final customer = args?['customer'] as Map<String, dynamic>?;
          final roomCount = args?['roomCount'] as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) => PaymentInformationScreen(
              room: room,
              hotel: hotel,
              customer: customer,
              roomCount: roomCount,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/payment-card') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          final customer = args?['customer'] as Map<String, dynamic>?;
          final roomCount = args?['roomCount'] as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) => PaymentCardScreen(
              room: room,
              hotel: hotel,
              customer: customer,
              roomCount: roomCount,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/payment-no-card') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          final customer = args?['customer'] as Map<String, dynamic>?;
          final roomCount = args?['roomCount'] as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) => PaymentNoCardScreen(
              room: room,
              hotel: hotel,
              customer: customer,
              roomCount: roomCount,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/booking-success') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          final customer = args?['customer'] as Map<String, dynamic>?;
          final paymentMethod = args?['paymentMethod'] as String?;
          final roomCount = args?['roomCount'] as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              room: room,
              hotel: hotel,
              customer: customer,
              paymentMethod: paymentMethod,
              roomCount: roomCount,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/bill') {
          final args = settings.arguments as Map<String, dynamic>?;
          final room = args?['room'] as Map<String, dynamic>?;
          final hotel = args?['hotel'] as Map<String, dynamic>?;
          final customer = args?['customer'] as Map<String, dynamic>?;
          final paymentMethod = args?['paymentMethod'] as String?;
          final roomCount = args?['roomCount'] as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) => BillScreen(
              room: room,
              hotel: hotel,
              customer: customer,
              paymentMethod: paymentMethod,
              roomCount: roomCount,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
