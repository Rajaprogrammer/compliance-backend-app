import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'widgets/loading_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: AppConstants.firebaseApiKey,
      authDomain: AppConstants.firebaseAuthDomain,
      projectId: AppConstants.firebaseProjectId,
      storageBucket: AppConstants.firebaseStorageBucket,
      messagingSenderId: AppConstants.firebaseMessagingSenderId,
      appId: AppConstants.firebaseAppId,
    ),
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ComplianceOSApp());
}

class ComplianceOSApp extends StatelessWidget {
  const ComplianceOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer2<AppProvider, AuthProvider>(
        builder: (context, appProvider, authProvider, _) {
          // Wait for preferences to load
          if (!appProvider.isInitialized) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                body: Center(child: LoadingIndicator(size: 48)),
              ),
            );
          }

          return MaterialApp(
            title: 'ComplianceOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            home: authProvider.isAuthenticated 
                ? const MainShell() 
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
