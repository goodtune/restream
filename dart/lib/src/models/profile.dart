import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

/// User profile information from the /profile endpoint.
@JsonSerializable()
class Profile {
  /// User ID.
  final int id;
  
  /// Username.
  final String username;
  
  /// Email address.
  final String email;

  const Profile({
    required this.id,
    required this.username,
    required this.email,
  });

  /// Creates a Profile from JSON data.
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// Converts this Profile to JSON.
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() {
    return 'Profile Information:\n'
           '  ID: $id\n'
           '  Username: $username\n'
           '  Email: $email';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}