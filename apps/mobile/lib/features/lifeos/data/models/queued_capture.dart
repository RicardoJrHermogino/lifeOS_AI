enum QueuedCaptureStatus { pending, syncing, failed }

/// A capture created while offline (or that failed to upload), persisted locally
/// until it can be synced. [syncId] is the idempotency key the backend uses to
/// avoid creating duplicates on retry.
class QueuedCapture {
  QueuedCapture({
    required this.syncId,
    required this.type,
    required this.body,
    required this.audioUrl,
    required this.mood,
    required this.createdAt,
    this.status = QueuedCaptureStatus.pending,
  });

  final String syncId;
  final String type; // text | voice
  final String? body;
  final String? audioUrl;
  final String? mood;
  final DateTime createdAt;
  final QueuedCaptureStatus status;

  QueuedCapture copyWith({QueuedCaptureStatus? status}) {
    return QueuedCapture(
      syncId: syncId,
      type: type,
      body: body,
      audioUrl: audioUrl,
      mood: mood,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'syncId': syncId,
    'type': type,
    'body': body,
    'audioUrl': audioUrl,
    'mood': mood,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };

  factory QueuedCapture.fromJson(Map<String, dynamic> json) {
    return QueuedCapture(
      syncId: json['syncId'] as String,
      type: json['type'] as String,
      body: json['body'] as String?,
      audioUrl: json['audioUrl'] as String?,
      mood: json['mood'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: QueuedCaptureStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => QueuedCaptureStatus.pending,
      ),
    );
  }
}
