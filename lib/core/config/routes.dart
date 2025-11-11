import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:xpressatec/core/bindings/auth_binding.dart';
import 'package:xpressatec/core/bindings/home_binding.dart';
import 'package:xpressatec/presentation/features/auth/screens/login_screen.dart';
import 'package:xpressatec/presentation/features/calendar/screens/tutor_calendar_screen.dart';
import 'package:xpressatec/presentation/features/home/screens/home_screen.dart';
import 'package:xpressatec/presentation/features/settings/screens/about_screen.dart';
import 'package:xpressatec/presentation/features/settings/screens/download_pictograms_screen.dart';
import 'package:xpressatec/presentation/features/settings/screens/settings_screen.dart';
import 'package:xpressatec/presentation/features/splash/screens/splash_screen.dart';
import 'package:xpressatec/presentation/features/therapists/screens/communication_therapist_marketplace_screen.dart';

import '../../presentation/features/audio_testing/audio_testing_screen.dart';
import '../../presentation/features/auth/screens/register_screen.dart';
import '../../presentation/features/package_download/screens/package_download_screen.dart';
import '../../presentation/features/customization/screens/customization_screen.dart';
import '../../core/bindings/communication_therapist_binding.dart';
import '../../core/bindings/link_tutor_binding.dart';
import '../../core/bindings/scan_qr_binding.dart';
import '../../presentation/features/profile/screens/link_tutor_screen.dart';
import '../../presentation/features/profile/screens/scan_qr_screen.dart';
import '../../core/bindings/tutor_calendar_binding.dart';

// Route constants
class Routes {
  static const String splash = '/';
  static const String packageDownload = '/package-download';
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/home';
  static const String linkTutor = '/link-tutor';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String customization = '/customization';
  static const String downloadPictograms = '/download-pictograms';
  static const String scanQr = '/scan-qr';
  static const String tutorCalendar = '/tutor-calendar';
  static const String communicationTherapists = '/communication-therapists';
  // static const String audioTesting = '/audio-testing';
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.packageDownload, // 🆕 ADD THIS
      page: () => const PackageDownloadScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.linkTutor,
      page: () => const LinkTutorScreen(),
      binding: LinkTutorBinding(),
    ),
    GetPage(
      name: Routes.scanQr,
      page: () => const ScanQrScreen(),
      binding: ScanQrBinding(),
    ),
    GetPage(
      name: Routes.tutorCalendar,
      page: () => const TutorCalendarScreen(),
      binding: TutorCalendarBinding(),
    ),
    GetPage(
      name: Routes.communicationTherapists,
      page: () => const CommunicationTherapistMarketplaceScreen(),
      binding: CommunicationTherapistBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
    ),
    GetPage(
      name: Routes.customization,
      page: () => const CustomizationScreen(),
    ),
    GetPage(
      name: Routes.downloadPictograms,
      page: () => const DownloadPictogramsScreen(),
    ),

    // GetPage(
    //   name: Routes.audioTesting,
    //   page: () => const AudioTestingScreen(),
    // ),
  ];
}