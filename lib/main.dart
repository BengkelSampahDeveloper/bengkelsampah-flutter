import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/providers/detail_profile_provider.dart';
import 'package:bengkelsampah_app/providers/home_provider.dart';
import 'package:bengkelsampah_app/providers/points_provider.dart';
import 'package:bengkelsampah_app/providers/profile_provider.dart';
import 'package:bengkelsampah_app/providers/pilahku_provider.dart';
import 'package:bengkelsampah_app/providers/setoran_provider.dart';
import 'package:bengkelsampah_app/providers/notification_provider.dart';
import 'providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/article_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/address_provider.dart';
import 'providers/katalog_provider.dart';
import 'providers/katalog_detail_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/article_detail_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/points_screen.dart';
import 'screens/katalog_screen.dart';
import 'screens/pilahku_screen.dart';
import 'screens/notification_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase Messaging Service
  await FirebaseMessagingService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DetailProfileProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => KatalogProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => KatalogDetailProvider()),
        ChangeNotifierProvider(create: (_) => PilahkuProvider()),
        ChangeNotifierProvider(create: (_) => SetoranProvider()),
      ],
      child: ResponsiveWrapper(
        child: MaterialApp(
          title: 'Bengkel Sampah',
          debugShowCheckedModeBanner: false,
          // Prevent app from being killed when configuration changes occur
          restorationScopeId: 'bengkelsampah_app',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.color_008B8B,
              primary: AppColors.color_0FB7A6,
              secondary: AppColors.color_40E0D0,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/otp': (context) => const OtpScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
            '/home': (context) => const HomeScreen(),
            '/articles': (context) => const ArticlesScreen(),
            '/article-detail': (context) => ArticleDetailScreen(
                  articleId: 0, // This will be overridden by the navigator
                ),
            '/events': (context) => const EventsScreen(),
            '/event-detail': (context) => EventDetailScreen(
                  eventId: 0, // This will be overridden by the navigator
                ),
            '/points': (context) => const PointsScreen(),
            '/katalog': (context) => const KatalogScreen(),
            '/pilahku': (context) => const PilahkuScreen(),
            '/notification': (context) => const NotificationScreen(),
          },
        ),
      ),
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we're on web platform
    if (UniversalPlatform.isWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Get screen dimensions
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Define mobile breakpoint (typical mobile width)
          const mobileWidth = 430.0;
          const mobileHeight = 932.0;

          // Check if screen is larger than mobile (tablet, laptop, desktop)
          if (screenWidth > mobileWidth || screenHeight > mobileHeight) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: Container(
                    width: mobileWidth,
                    height: mobileHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  ),
                ),
              ),
            );
          } else {
            // Mobile size - show full screen
            return child;
          }
        },
      );
    } else {
      // Non-web platforms (mobile, tablet native apps) - show full screen
      return child;
    }
  }
}
