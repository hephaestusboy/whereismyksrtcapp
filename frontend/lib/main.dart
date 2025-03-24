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
        path: YesQRPage.routePath,
        builder: (context, state) => const YesQRPage(),
      ),
      GoRoute(
        path: YesMapPage.routePath,
        builder: (context, state) {
          final String busId = state.extra as String; // Retrieve the busId
          return YesMapPage(busId: busId);
        },
      ),
      GoRoute(
        path: '/no-map',
        name: NoMapPage.routeName,
        builder: (context, state) {
          final routeInfo = state.extra as Map<String, dynamic>? ?? {
            'destination': 'Unknown',
            'busId': '1',
            'latitude': 0,
            'longitude': 0,
            'speed': 0,
            'updated_at': 'Unknown',
          };

          return NoMapPage(
            busId: routeInfo['busId'],
            routeInfo: routeInfo,
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
