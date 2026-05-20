import 'package:go_router/go_router.dart';
import 'package:smart_scanner/features/card_scanner/presentation/card_scanner_screen.dart';
import 'package:smart_scanner/features/passbook_scanner/passbook_scanner_screen.dart';
import 'package:smart_scanner/core/home_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String cardScanner = '/card-scanner';
  static const String passbookScanner = '/passbook-scanner';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: cardScanner,
        builder: (context, state) => const CardScannerScreen(),
      ),
      GoRoute(
        path: passbookScanner,
        builder: (context, state) => const PassbookScannerScreen(),
      ),
    ],
  );
}
