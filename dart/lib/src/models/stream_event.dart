import 'package:json_annotation/json_annotation.dart';

import 'event_destination.dart';

part 'stream_event.g.dart';

/// Stream event information representing a streaming session.
@JsonSerializable()
class StreamEvent {
  /// Event ID.
  final String id;
  
  /// Show ID if available.
  final String? showId;
  
  /// Current status of the event (e.g., 'live', 'ended', 'scheduled').
  final String status;
  
  /// Event title.
  final String title;
  
  /// Event description.
  final String description;
  
  /// Whether this is an instant stream.
  final bool isInstant;
  
  /// Whether this is record-only mode.
  final bool isRecordOnly;
  
  /// Cover image URL if available.
  final String? coverUrl;
  
  /// Scheduled start time as Unix timestamp in seconds.
  final int? scheduledFor;
  
  /// Actual start time as Unix timestamp in seconds.
  final int? startedAt;
  
  /// End time as Unix timestamp in seconds.
  final int? finishedAt;
  
  /// List of destinations where this event is broadcast.
  final List<EventDestination> destinations;

  const StreamEvent({
    required this.id,
    this.showId,
    required this.status,
    required this.title,
    required this.description,
    required this.isInstant,
    required this.isRecordOnly,
    this.coverUrl,
    this.scheduledFor,
    this.startedAt,
    this.finishedAt,
    required this.destinations,
  });

  /// Creates a StreamEvent from JSON data.
  factory StreamEvent.fromJson(Map<String, dynamic> json) =>
      _$StreamEventFromJson(json);

  /// Converts this StreamEvent to JSON.
  Map<String, dynamic> toJson() => _$StreamEventToJson(this);

  /// Gets the scheduled date as a DateTime if available.
  DateTime? get scheduledDate =>
      scheduledFor != null ? DateTime.fromMillisecondsSinceEpoch(scheduledFor! * 1000) : null;

  /// Gets the started date as a DateTime if available.
  DateTime? get startedDate =>
      startedAt != null ? DateTime.fromMillisecondsSinceEpoch(startedAt! * 1000) : null;

  /// Gets the finished date as a DateTime if available.
  DateTime? get finishedDate =>
      finishedAt != null ? DateTime.fromMillisecondsSinceEpoch(finishedAt! * 1000) : null;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('Event: $title')
      ..writeln('  ID: $id')
      ..writeln('  Status: $status')
      ..writeln('  Description: $description')
      ..writeln('  Instant: ${isInstant ? 'Yes' : 'No'}')
      ..writeln('  Record Only: ${isRecordOnly ? 'Yes' : 'No'}');

    if (showId != null) {
      buffer.writeln('  Show ID: $showId');
    }

    if (scheduledDate != null) {
      buffer.writeln('  Scheduled: ${scheduledDate!.toUtc().toIso8601String()}');
    }

    if (startedDate != null) {
      buffer.writeln('  Started: ${startedDate!.toUtc().toIso8601String()}');
    }

    if (finishedDate != null) {
      buffer.writeln('  Finished: ${finishedDate!.toUtc().toIso8601String()}');
    }

    if (coverUrl != null) {
      buffer.writeln('  Cover URL: $coverUrl');
    }

    // Always show destinations section, even if empty
    buffer.writeln('  Destinations (${destinations.length}):');
    for (final dest in destinations) {
      final destStr = dest.toString().replaceAll('\n', '\n  ');
      buffer.writeln('  $destStr');
    }

    return buffer.toString().trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}