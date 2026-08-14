import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/config/app_theme.dart';
import 'core/config/theme_controller.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar + dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await dotenv.load(fileName: '.env');

  String? initError;
  try {
    await SupabaseService.initialize();
    // ignore: avoid_print
    print(
      'Supabase status: connected -> client initialized: '
      '${SupabaseService.isInitialized}',
    );
  } catch (e) {
    initError = e.toString();
    // ignore: avoid_print
    print('Supabase status: FAILED to initialize -> $e');
  }

  runApp(CADeskApp(initError: initError));
}

class CADeskApp extends StatefulWidget {
  const CADeskApp({super.key, this.initError});
  final String? initError;

  @override
  State<CADeskApp> createState() => _CADeskAppState();
}

class _CADeskAppState extends State<CADeskApp> {
  // Auth-driven navigation (e.g. redirecting to Dashboard on sign-in) is
  // now centralized in AppRouter's `redirect`, which re-evaluates on
  // every auth state change via GoRouterRefreshStream. No manual listener
  // or navigatorKey needed here anymore.

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;
        // Update status bar icon brightness based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        final darkTheme = AppTheme.dark.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.dark.textTheme),
        );
        final lightTheme = AppTheme.light.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.light.textTheme),
        );

        // If Supabase failed to initialize, short-circuit before GoRouter
        // ever touches AuthService (which itself talks to Supabase) —
        // same guard the old `home:` ternary provided.
        if (widget.initError != null) {
          return MaterialApp(
            title: 'CA Desk',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeController.instance.themeMode,
            home: _SupabaseConnectionErrorScreen(error: widget.initError!),
          );
        }

        return MaterialApp.router(
          title: 'CA Desk',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeController.instance.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

class _SupabaseConnectionErrorScreen extends StatelessWidget {
  const _SupabaseConnectionErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.bg0, colors.bg1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.errorBg,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 32,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connection Failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to connect to Supabase.\nCheck your .env configuration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.bg3,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.glassBorderDim),
                  ),
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
