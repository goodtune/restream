import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/restream_service.dart';

class AuthScreen extends StatefulWidget {
  final RestreamService restreamService;
  final VoidCallback onAuthenticated;

  const AuthScreen({
    super.key,
    required this.restreamService,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  Future<void> _startAuthentication() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      // Start OAuth flow
      final authUrl = await widget.restreamService.startAuthFlow();
      
      // Launch browser
      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(
          Uri.parse(authUrl),
          mode: LaunchMode.externalApplication,
        );
        
        // In a real app, you'd handle the deep link callback here
        // For this example, we'll show a dialog with instructions
        _showCallbackInstructions();
      } else {
        throw Exception('Could not launch authentication URL');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAuthenticating = false;
      });
    }
  }

  void _showCallbackInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication'),
        content: const Text(
          'After authorizing in your browser, you will be redirected back to the app. '
          'In a real implementation, this would be handled automatically via deep links.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManualCodeEntry();
            },
            child: const Text('Enter Code Manually'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isAuthenticating = false;
              });
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showManualCodeEntry() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Authorization Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Copy the authorization code from the redirect URL and paste it here:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Authorization Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isAuthenticating = false;
              });
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(context).pop();
                await _completeAuthentication(code);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeAuthentication(String authCode) async {
    try {
      await widget.restreamService.completeAuthFlow(authCode);
      widget.onAuthenticated();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restream Authentication'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.live_tv,
              size: 120,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              'Welcome to Restream',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connect your Restream.io account to manage your streams and monitor chat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _startAuthentication,
                icon: _isAuthenticating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  _isAuthenticating ? 'Authenticating...' : 'Connect to Restream',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your credentials are stored securely on your device.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}