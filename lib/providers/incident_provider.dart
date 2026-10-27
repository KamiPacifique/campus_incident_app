import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._service);

  final IncidentService _service;
  StreamSubscription<List<Incident>>? _sub;

  AppUser? _user;
  List<Incident> _all = [];
  bool _isLoading = false;
  String? _loadError;
  bool _isSubmitting = false;
  String? _actionError;

  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;
  String _query = '';

  // ----- read state ---------------------------------------------------------
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  bool get isSubmitting => _isSubmitting;
  String? get actionError => _actionError;

  IncidentStatus? get statusFilter => _statusFilter;
  IncidentCategory? get categoryFilter => _categoryFilter;
  String get query => _query;
  bool get hasActiveFilters =>
      _statusFilter != null || _categoryFilter != null || _query.isNotEmpty;

  List<Incident> get allIncidents => List.unmodifiable(_all);
  List<Incident> get myIncidents =>
      _all.where((i) => i.reporterId == _user?.uid).toList();

  /// Reports shown on the "My Reports" screen, after search + filters.
  List<Incident> get filteredMine => _applyFilters(myIncidents);

  /// Reports shown on the staff dashboard, after search + filters.
  List<Incident> get filteredAll => _applyFilters(_all);

  IncidentStats get myStats => IncidentStats.of(myIncidents);
  IncidentStats get allStats => IncidentStats.of(_all);

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  // ----- lifecycle ----------------------------------------------------------
  /// Called by the ProxyProvider whenever the auth state changes.
  void updateUser(AppUser? user) {
    final unchanged = user?.uid == _user?.uid &&
        user?.emailVerified == _user?.emailVerified;
    if (unchanged) return;

    _user = user;
    _sub?.cancel();
    _sub = null;
    _all = [];
    _statusFilter = null;
    _categoryFilter = null;
    _query = '';
    _loadError = null;

    if (user != null && user.emailVerified) {
      _listen();
    } else {
      _isLoading = false;
    }
    // Avoid notifying while the widget tree is building.
    Future.microtask(notifyListeners);
  }

  void _listen() {
    _isLoading = true;
    _loadError = null;
    _sub = _service.watchIncidents().listen(
      (items) {
        _all = items;
        _isLoading = false;
        _loadError = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _loadError = 'Could not load reports. Check your connection and retry.';
        notifyListeners();
      },
    );
  }

  void retry() {
    _sub?.cancel();
    _listen();
    notifyListeners();
  }

  // ----- filters ------------------------------------------------------------
  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _query = '';
    notifyListeners();
  }

  List<Incident> _applyFilters(Iterable<Incident> items) {
    final q = _query.toLowerCase();
    return items.where((i) {
      if (_statusFilter != null && i.status != _statusFilter) return false;
      if (_categoryFilter != null && i.category != _categoryFilter) {
        return false;
      }
      if (q.isNotEmpty) {
        final haystack =
            '${i.title} ${i.description} ${i.location} ${i.category.label}'
                .toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  // ----- actions ------------------------------------------------------------
  Future<bool> submit(Incident draft, {String? localImagePath}) => _act(
        () => _service.create(draft, localImagePath: localImagePath),
        track: true,
      );

  Future<bool> updateStatus(String id, IncidentStatus status) {
    // UI guard only. Real enforcement happens in Firestore Security Rules.
    if (!(_user?.isStaff ?? false)) {
      _actionError = 'Only campus staff can update report status.';
      notifyListeners();
      return Future.value(false);
    }
    return _act(() => _service.updateStatus(id, status));
  }

  Future<bool> delete(String id) => _act(() => _service.delete(id));

  Future<bool> _act(Future<void> Function() action, {bool track = false}) async {
    _actionError = null;
    if (track) {
      _isSubmitting = true;
      notifyListeners();
    }
    try {
      await action();
      return true;
    } catch (_) {
      _actionError = 'That did not go through. Check your connection and try again.';
      return false;
    } finally {
      if (track) _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
