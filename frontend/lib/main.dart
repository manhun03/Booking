import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/create_new_password_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/message_screen.dart';
import 'screens/message_chat_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/change_booking_date_screen.dart';
import 'screens/change_booking_time_screen.dart';
import 'screens/cancel_booking_screen.dart';
import 'screens/review_booking_screen.dart';
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
import 'screens/hotel_management_screen.dart';
import 'services/api_service.dart';
import 'services/language_service.dart';
import 'utils/theme.dart';
import 'widgets/ai_chat_floating_button.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().restoreSession();
  await LanguageService().restore();
  runApp(const StaySmartApp());
}

class StaySmartApp extends StatelessWidget {
  const StaySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'StaySmart',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Stack(
              children: [
                child ?? const SizedBox.shrink(),
                Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => const AiChatFloatingButton(),
                    ),
                  ],
                ),
              ],
            );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/otp': (context) => const OtpScreen(),
            '/create-new-password': (context) =>
                const CreateNewPasswordScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
            '/home': (context) => const HomeScreen(),
            '/search': (context) => const SearchScreen(),
            '/message': (context) => const MessageScreen(),
            '/booking': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final showHistory = args is Map<String, dynamic> &&
                  (args['showHistory'] == true || args['tab'] == 'history');
              return BookingScreen(initialShowHistory: showHistory);
            },
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
            '/review-booking': (context) {
              final booking = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return ReviewBookingScreen(booking: booking);
            },
            '/more': (context) => const MoreScreen(),
            '/user-profile': (context) => const UserProfileScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/favorite': (context) => const FavoriteScreen(),
            '/favorites': (context) => const FavoriteScreen(),
            '/favourites': (context) => const FavoriteScreen(),
            '/notification': (context) => const NotificationScreen(),
            '/promotion': (context) => const PromotionScreen(),
            '/add-promotion': (context) => const AddPromotionScreen(),
            '/credit-card': (context) => const CreditCardScreen(),
            '/add-card': (context) => const AddCardScreen(),
            '/language': (context) => const LanguageScreen(),
            '/legal-policies': (context) => const LegalPoliciesScreen(),
            '/hotel-management': (context) => const HotelManagementScreen(),
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
                builder: (context) =>
                    RoomDetailScreen(room: room, hotel: hotel),
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
              final checkInDate = args?['checkInDate'] as DateTime?;
              final checkOutDate = args?['checkOutDate'] as DateTime?;
              return MaterialPageRoute(
                builder: (context) => PaymentInformationScreen(
                  room: room,
                  hotel: hotel,
                  customer: customer,
                  roomCount: roomCount,
                  checkInDate: checkInDate,
                  checkOutDate: checkOutDate,
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
              final checkInDate = args?['checkInDate'] as DateTime?;
              final checkOutDate = args?['checkOutDate'] as DateTime?;
              return MaterialPageRoute(
                builder: (context) => PaymentCardScreen(
                  room: room,
                  hotel: hotel,
                  customer: customer,
                  roomCount: roomCount,
                  checkInDate: checkInDate,
                  checkOutDate: checkOutDate,
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
              final checkInDate = args?['checkInDate'] as DateTime?;
              final checkOutDate = args?['checkOutDate'] as DateTime?;
              return MaterialPageRoute(
                builder: (context) => PaymentNoCardScreen(
                  room: room,
                  hotel: hotel,
                  customer: customer,
                  roomCount: roomCount,
                  checkInDate: checkInDate,
                  checkOutDate: checkOutDate,
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
              final checkInDate = args?['checkInDate'] as DateTime?;
              final checkOutDate = args?['checkOutDate'] as DateTime?;
              final booking = args?['booking'] as Map<String, dynamic>?;
              final payment = args?['payment'] as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => BookingSuccessScreen(
                  room: room,
                  hotel: hotel,
                  customer: customer,
                  paymentMethod: paymentMethod,
                  roomCount: roomCount,
                  checkInDate: checkInDate,
                  checkOutDate: checkOutDate,
                  booking: booking,
                  payment: payment,
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
              final checkInDate = args?['checkInDate'] as DateTime?;
              final checkOutDate = args?['checkOutDate'] as DateTime?;
              final booking = args?['booking'] as Map<String, dynamic>?;
              final payment = args?['payment'] as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => BillScreen(
                  room: room,
                  hotel: hotel,
                  customer: customer,
                  paymentMethod: paymentMethod,
                  roomCount: roomCount,
                  checkInDate: checkInDate,
                  checkOutDate: checkOutDate,
                  booking: booking,
                  payment: payment,
                ),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}
