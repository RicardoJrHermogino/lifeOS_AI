class MemoryModel {
  MemoryModel({
    required this.id,
    required this.userId,
    required this.rawCaptureId,
    required this.title,
    required this.summary,
    required this.eventDate,
    required this.emotions,
    required this.people,
    required this.places,
    required this.topics,
    required this.goals,
    required this.decisions,
    required this.actions,
    required this.sensitivity,
    required this.confidence,
    required this.status,
    required this.isUserCorrected,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? rawCaptureId;
  final String title;
  final String summary;
  final DateTime eventDate;
  final List<String> emotions;
  final List<String> people;
  final List<String> places;
  final List<String> topics;
  final List<String> goals;
  final List<String> decisions;
  final List<String> actions;
  final String? sensitivity;
  final Map<String, double> confidence;
  final String status; // candidate | saved | archived | deleted
  final bool isUserCorrected;
  final DateTime createdAt;
  final DateTime updatedAt;

  static List<String> _strList(dynamic v) =>
      (v as List?)?.map((e) => e as String).toList() ?? const [];

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    final conf = <String, double>{};
    final rawConf = json['confidence'];
    if (rawConf is Map) {
      rawConf.forEach((k, v) {
        if (v is num) conf[k as String] = v.toDouble();
      });
    }
    return MemoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rawCaptureId: json['rawCaptureId'] as String?,
      title: json['title'] as String,
      summary: json['summary'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      emotions: _strList(json['emotions']),
      people: _strList(json['people']),
      places: _strList(json['places']),
      topics: _strList(json['topics']),
      goals: _strList(json['goals']),
      decisions: _strList(json['decisions']),
      actions: _strList(json['actions']),
      sensitivity: json['sensitivity'] as String?,
      confidence: conf,
      status: json['status'] as String,
      isUserCorrected: json['isUserCorrected'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
