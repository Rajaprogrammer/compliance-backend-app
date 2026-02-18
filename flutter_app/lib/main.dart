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
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  
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
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'ComplianceOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return authProvider.isAuthenticated ? const MainShell() : const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
