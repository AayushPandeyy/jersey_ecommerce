import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/firebase_options.dart';
import 'package:jersey_ecommerce/screens/NavigationScreen.dart';
import 'package:jersey_ecommerce/screens/auth/AuthPage.dart';
import 'package:jersey_ecommerce/screens/auth/LoginChecker.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:khalti_flutter/localization/khalti_localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      
      publicKey: "test_public_key_d5d9f63743584dc38753056b0cc737d5", // Test key

      enabledDebugging: true,
      builder: (context, navKey) {
        return MaterialApp(
          title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.marcellusTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        
      ),
      home: LoginChecker(),
      debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
          ],
          // ... rest of your app configuration
        );
      },
    );
  }
}



