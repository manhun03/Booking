import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/message_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/more_screen.dart';
import 'screens/hotel_detail_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const HHBNBookingApp());
}

class HHBNBookingApp extends StatelessWidget {
  const HHBNBookingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HHBN Booking',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/message': (context) => const MessageScreen(),
        '/booking': (context) => const BookingScreen(),
        '/more': (context) => const MoreScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/hotel-detail') {
          final hotel = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
