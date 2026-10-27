enum IncidentStatus {
  submitted('Submitted'),
  inProgress('In Progress'),
  resolved('Resolved');

  const IncidentStatus(this.label);
  final String label;
}

enum IncidentCategory {
  facilities('Facilities'),
  water('Water'),
  electricity('Electricity'),
  safety('Safety'),
  sanitation('Sanitation'),
  furniture('Furniture');

  const IncidentCategory(this.label);
  final String label;
}

class StatusEvent {
  const StatusEvent({required this.status, required this.at});
  final IncidentStatus status;
  final DateTime at;
}

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.history,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final List<StatusEvent> history;

  /// Local file path (mock backend) or download URL (Firebase Storage).
  final String? imageUrl;

  DateTime? timeOf(IncidentStatus s) {
    for (final e in history) {
      if (e.status == s) return e.at;
    }
    return null;
  }

  Incident copyWith({
    String? id,
    IncidentStatus? status,
    List<StatusEvent>? history,
    String? imageUrl,
  }) =>
      Incident(
        id: id ?? this.id,
        title: title,
        description: description,
        category: category,
        location: location,
        status: status ?? this.status,
        reporterId: reporterId,
        reporterName: reporterName,
        createdAt: createdAt,
        history: history ?? this.history,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

class IncidentStats {
  const IncidentStats({
    required this.total,
    required this.submitted,
    required this.inProgress,
    required this.resolved,
  });

  final int total;
  final int submitted;
  final int inProgress;
  final int resolved;

  factory IncidentStats.of(Iterable<Incident> items) {
    var s = 0, p = 0, r = 0;
    for (final i in items) {
      switch (i.status) {
        case IncidentStatus.submitted:
          s++;
        case IncidentStatus.inProgress:
          p++;
        case IncidentStatus.resolved:
          r++;
      }
    }
    return IncidentStats(
        total: s + p + r, submitted: s, inProgress: p, resolved: r);
  }
}
