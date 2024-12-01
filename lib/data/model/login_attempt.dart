class LoginAttempt {
  final String id;
  final String email;
  final DateTime timestamp;
  final bool success;

  LoginAttempt({
    required this.id,
    required this.email,
    required this.timestamp,
    required this.success,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
    };
  }

  factory LoginAttempt.fromMap(Map<String, dynamic> map) {
    return LoginAttempt(
      id: map['id'] as String,
      email: map['email'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      success: map['success'] as bool,
    );
  }

  LoginAttempt copyWith({bool? success}) {
    return LoginAttempt(
      id: id,
      email: email,
      timestamp: timestamp,
      success: success ?? this.success,
    );
  }
}
