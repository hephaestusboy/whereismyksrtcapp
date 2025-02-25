import 'package:flutter/material.dart';
import 'pages/splash.dart' as splash;
import 'pages/signin.dart' as signin;
import 'pages/slideshow.dart' as slideshow;
import 'pages/popup.dart' as popup;
import 'pages/yes.dart' as yes;
import 'pages/no.dart' as no;
import 'pages/yes_2.dart' as yes_2;
import 'pages/createacc.dart' as createacc; // Import createacc.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/yes_2') {
          final qrData = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => yes_2.Yes2Page(qrData: qrData),
          );
        }
        return null; // Use default routes
      },
      routes: {
        '/': (context) => splash.SplashPage(),
        '/signin': (context) => signin.SignInWidget(),
        '/slideshow': (context) => slideshow.SlideShowPage(),
        '/popup': (context) => popup.PopupPage(),
        '/yes': (context) => yes.YesPage(),
        '/no': (context) => no.NoPage(),
        '/createacc': (context) => createacc.CreateAccPage(), // Added Create Account Page
      },
    );
  }
}
