import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restream_dart/restream_dart.dart';

import 'services/restream_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const RestreamApp());
}

class RestreamApp extends StatelessWidget {
  const RestreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restream Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  late final RestreamService _restreamService;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _restreamService = RestreamService();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await _restreamService.initialize();
      setState(() {
        _isAuthenticated = _restreamService.isAuthenticated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated 
        ? HomeScreen(restreamService: _restreamService)
        : AuthScreen(
            restreamService: _restreamService,
            onAuthenticated: () {
              setState(() {
                _isAuthenticated = true;
              });
            },
          );
  }
}