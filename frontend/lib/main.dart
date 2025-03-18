import 'package:bus/pages/createacc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/splash.dart';
import 'pages/signin.dart';
import 'pages/popup.dart';
import 'pages/no.dart';
import 'pages/no_map.dart';
import 'pages/yes_qr.dart';
import 'pages/yes_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/create-acc',
        builder: (context, state) => const CreateAccPage(),
      ),

      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInWidget(),
      ),
      GoRoute(
        path: '/popup',
        builder: (context, state) => const PopupPage(),
      ),
      GoRoute(
        path: '/no',
        builder: (context, state) => const NoPage(),
      ),
      GoRoute(
        path: '/yes_qr',
        builder: (context, state) => const YesQRPage(),
      ), // Add more routes as needed
      GoRoute(
        path: '/yes_map',
        builder: (context, state) => const YesMapPage(),
      ),
      GoRoute(
        path: '/no-map',
        builder: (context, state) {
          final String destination =
              state.extra as String? ?? "Unknown Destination";
          return NoMapScreen(
            routeInfo: {
              'destination': destination,
              'busId': '1', // You might want to pass this from somewhere
            },
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      routerConfig: _router,
    );
  }
}
