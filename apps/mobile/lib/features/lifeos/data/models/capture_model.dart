class CaptureModel {
  CaptureModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.body,
    required this.audioUrl,
    required this.transcript,
    required this.transcriptCorrected,
    required this.mood,
    required this.status,
    required this.syncId,
    required this.capturedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String type; // voice | text
  final String? body;
  final String? audioUrl;
  final String? transcript;
  final bool transcriptCorrected;
  final String? mood;
  final String status; // pending | transcribing | extracting | done | failed
  final String? syncId;
  final DateTime capturedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CaptureModel.fromJson(Map<String, dynamic> json) {
    return CaptureModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      body: json['body'] as String?,
      audioUrl: json['audioUrl'] as String?,
      transcript: json['transcript'] as String?,
      transcriptCorrected: json['transcriptCorrected'] as bool? ?? false,
      mood: json['mood'] as String?,
      status: json['status'] as String,
      syncId: json['syncId'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
