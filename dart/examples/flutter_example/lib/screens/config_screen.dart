import 'package:flutter/material.dart';

import '../services/restream_service.dart';

class ConfigScreen extends StatefulWidget {
  final RestreamService restreamService;
  final VoidCallback onConfigured;

  const ConfigScreen({
    super.key,
    required this.restreamService,
    required this.onConfigured,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSecret = true;

  @override
  void initState() {
    super.initState();
    _loadExistingCredentials();
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingCredentials() async {
    final credentials = await widget.restreamService.getStoredCredentials();
    if (mounted) {
      setState(() {
        _clientIdController.text = credentials['clientId'] ?? '';
        _clientSecretController.text = credentials['clientSecret'] ?? '';
      });
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.restreamService.configure(
        clientId: _clientIdController.text.trim(),
        clientSecret: _clientSecretController.text.trim().isEmpty
            ? null
            : _clientSecretController.text.trim(),
      );

      if (mounted) {
        widget.onConfigured();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Configuration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearConfiguration() async {
    setState(() => _isLoading = true);

    try {
      await widget.restreamService.clearCredentials();
      if (mounted) {
        setState(() {
          _clientIdController.clear();
          _clientSecretController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear configuration: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restream Configuration'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _clearConfiguration,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Configuration',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your Restream OAuth application credentials:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  hintText: 'Enter your OAuth Client ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Client ID is required';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientSecretController,
                decoration: InputDecoration(
                  labelText: 'Client Secret (Optional)',
                  hintText: 'Enter your OAuth Client Secret',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureSecret ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureSecret = !_obscureSecret;
                      });
                    },
                  ),
                ),
                obscureText: _obscureSecret,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 8),
              Text(
                'Client Secret is optional for mobile apps. Leave empty if not needed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveConfiguration,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Configuration'),
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to get OAuth credentials:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1. Go to Restream.io Developer Console'),
                      Text('2. Create a new OAuth application'),
                      Text('3. Copy the Client ID and Client Secret'),
                      Text('4. Enter them in the form above'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
