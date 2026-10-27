import 'dart:async';

import '../models/incident.dart';

/// Contract for incident persistence. The Firebase version will use
/// Cloud Firestore (documents) and Firebase Storage (photos).
abstract class IncidentService {
  Stream<List<Incident>> watchIncidents();

  /// Saves a new incident; uploads [localImagePath] if provided.
  Future<void> create(Incident incident, {String? localImagePath});
  Future<void> updateStatus(String id, IncidentStatus status);
  Future<void> delete(String id);
}

class MockIncidentService implements IncidentService {
  MockIncidentService() : _items = _seed();

  final List<Incident> _items;
  final _controller = StreamController<List<Incident>>.broadcast();

  List<Incident> _sorted() => List.of(_items)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> _latency([int ms = 700]) =>
      Future.delayed(Duration(milliseconds: ms));

  @override
  Stream<List<Incident>> watchIncidents() async* {
    await _latency();
    yield _sorted();
    yield* _controller.stream;
  }

  @override
  Future<void> create(Incident incident, {String? localImagePath}) async {
    await _latency(1000);
    _items.add(incident.copyWith(
      id: 'inc-${DateTime.now().microsecondsSinceEpoch}',
      imageUrl: localImagePath,
    ));
    _controller.add(_sorted());
  }

  @override
  Future<void> updateStatus(String id, IncidentStatus status) async {
    await _latency();
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) throw StateError('Report no longer exists.');
    final current = _items[index];
    _items[index] = current.copyWith(
      status: status,
      history: [
        ...current.history,
        StatusEvent(status: status, at: DateTime.now()),
      ],
    );
    _controller.add(_sorted());
  }

  @override
  Future<void> delete(String id) async {
    await _latency();
    _items.removeWhere((i) => i.id == id);
    _controller.add(_sorted());
  }

  static List<Incident> _seed() {
    final now = DateTime.now();
    Incident make({
      required String id,
      required String title,
      required String description,
      required IncidentCategory category,
      required String location,
      required IncidentStatus status,
      required Duration age,
      String reporterId = 'student-1',
      String reporterName = 'Amina Hassan',
    }) {
      final created = now.subtract(age);
      final history = <StatusEvent>[
        StatusEvent(status: IncidentStatus.submitted, at: created),
        if (status != IncidentStatus.submitted)
          StatusEvent(
              status: IncidentStatus.inProgress,
              at: created.add(const Duration(hours: 4))),
        if (status == IncidentStatus.resolved)
          StatusEvent(
              status: IncidentStatus.resolved,
              at: created.add(const Duration(hours: 20))),
      ];
      return Incident(
        id: id,
        title: title,
        description: description,
        category: category,
        location: location,
        status: status,
        reporterId: reporterId,
        reporterName: reporterName,
        createdAt: created,
        history: history,
      );
    }

    return [
      make(
        id: 'inc-1',
        title: 'Water shortage',
        description:
            'There has been no water supply in the student residence since this morning. This is affecting many students on the 2nd floor. Kindly check and fix the issue.',
        category: IncidentCategory.water,
        location: 'Student Residence',
        status: IncidentStatus.submitted,
        age: const Duration(hours: 2),
      ),
      make(
        id: 'inc-2',
        title: 'Broken classroom projector',
        description:
            'The projector in Block B, Room 204 does not turn on. Lectures scheduled in this room cannot use slides.',
        category: IncidentCategory.facilities,
        location: 'Block B',
        status: IncidentStatus.inProgress,
        age: const Duration(days: 1),
      ),
      make(
        id: 'inc-3',
        title: 'Overflowing bin',
        description:
            'The bins outside the cafeteria entrance are overflowing and attracting insects.',
        category: IncidentCategory.sanitation,
        location: 'Cafeteria',
        status: IncidentStatus.resolved,
        age: const Duration(days: 3),
      ),
      make(
        id: 'inc-4',
        title: 'Streetlight not working near gate',
        description:
            'The streetlight beside the main gate has been off for three nights. The path is very dark after 7pm.',
        category: IncidentCategory.safety,
        location: 'Main Gate',
        status: IncidentStatus.submitted,
        age: const Duration(hours: 9),
        reporterId: 'student-2',
        reporterName: 'David Nkurunziza',
      ),
      make(
        id: 'inc-5',
        title: 'Flickering lights in library',
        description:
            'Several lights on the second floor of the library flicker constantly, making it hard to study.',
        category: IncidentCategory.electricity,
        location: 'Library',
        status: IncidentStatus.inProgress,
        age: const Duration(days: 2),
        reporterId: 'student-3',
        reporterName: 'Grace Uwase',
      ),
    ];
  }
}
