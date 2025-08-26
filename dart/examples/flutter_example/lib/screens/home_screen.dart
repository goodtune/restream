import 'package:flutter/material.dart';
import 'package:restream_dart/restream_dart.dart';

import '../services/restream_service.dart';

class HomeScreen extends StatefulWidget {
  final RestreamService restreamService;

  const HomeScreen({
    super.key,
    required this.restreamService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Profile? _profile;
  List<StreamEvent>? _upcomingEvents;
  List<StreamEvent>? _inProgressEvents;
  StreamKey? _streamKey;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        widget.restreamService.getProfile(),
        widget.restreamService.getUpcomingEvents(),
        widget.restreamService.getInProgressEvents(),
        widget.restreamService.getStreamKey(),
      ]);

      setState(() {
        _profile = results[0] as Profile;
        _upcomingEvents = results[1] as List<StreamEvent>;
        _inProgressEvents = results[2] as List<StreamEvent>;
        _streamKey = results[3] as StreamKey;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await widget.restreamService.logout();
      if (mounted) {
        // In a real app, you'd navigate back to auth screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile?.username ?? 'Restream'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.key), text: 'Stream Key'),
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildEventsTab(),
                    _buildStreamKeyTab(),
                    _buildChatTab(),
                  ],
                ),
    );
  }

  Widget _buildProfileTab() {
    if (_profile == null) return const Center(child: Text('No profile data'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Username'),
                    subtitle: Text(_profile!.username),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(_profile!.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.tag),
                    title: const Text('User ID'),
                    subtitle: Text(_profile!.id.toString()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_inProgressEvents?.isNotEmpty == true) ...[
            const Text(
              'In Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._inProgressEvents!.map((event) => _buildEventCard(event)),
            const SizedBox(height: 16),
          ],
          const Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _upcomingEvents?.isEmpty == true
                ? const Center(child: Text('No upcoming events'))
                : ListView.builder(
                    itemCount: _upcomingEvents?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_upcomingEvents![index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(StreamEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          event.status == 'live' ? Icons.radio_button_on : Icons.schedule,
          color: event.status == 'live' ? Colors.red : Colors.orange,
        ),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Text(
              'Status: ${event.status}',
              style: TextStyle(
                color: event.status == 'live' ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (event.scheduledDate != null)
              Text('Scheduled: ${event.scheduledDate!.toLocal()}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStreamKeyTab() {
    if (_streamKey == null) return const Center(child: Text('No stream key data'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stream Configuration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.video_call),
                    title: const Text('RTMP URL'),
                    subtitle: Text(_streamKey!.rtmpUrl),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('RTMP URL copied')),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.key),
                    title: const Text('Stream Key'),
                    subtitle: Text(_streamKey!.key),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stream key copied')),
                        );
                      },
                    ),
                  ),
                  if (_streamKey!.srtUrl != null)
                    ListTile(
                      leading: const Icon(Icons.settings_input_hdmi),
                      title: const Text('SRT URL'),
                      subtitle: Text(_streamKey!.srtUrl!),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('SRT URL copied')),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chat Monitoring',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Real-time chat monitoring would be implemented here using the ChatMonitor from the restream_dart library.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(
            'Features:\n• Real-time chat messages\n• Multi-platform support\n• User join/leave events\n• Connection status',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}