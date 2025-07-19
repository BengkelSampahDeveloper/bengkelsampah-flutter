import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  bool _isLoading = false;
  bool _hasMorePages = true;
  int _currentPage = 1;
  String? _error;

  List<EventModel> get events => _events;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;
  String? get error => _error;

  Future<void> loadEvents({bool refresh = false}) async {
    if (refresh) {
      _events = [];
      _currentPage = 1;
      _hasMorePages = true;
    }

    if (!_hasMorePages || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getEvents(page: _currentPage);

      if (response['status'] == 'success') {
        final List<dynamic> data = response['data']['events'];

        final List<EventModel> newEvents =
            data.map((event) => EventModel.fromJson(event)).toList();

        _events.addAll(newEvents);
        _hasMorePages = response['data']['pagination']['has_more_pages'];
        _currentPage++;
        _error = null;
      } else {
        _error = response['message'] ?? 'Gagal memuat event';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil event';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEventDetail(int id) async {
    _isLoading = true;
    _error = null;
    _selectedEvent = null;
    notifyListeners();

    try {
      final response = await _apiService.getEventDetail(id);
      if (response['status'] == 'success') {
        _selectedEvent = EventModel.fromJson(response['data']['event']);
        _error = null;
      } else {
        _error = response['message'] ?? 'Gagal memuat detail event';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil detail event';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleJoin(int eventId) async {
    try {
      final response = await _apiService.toggleJoinEvent(eventId);
      if (response['status'] == 'success') {
        final data = response['data'];
        final userHasJoined = data['user_has_joined'] ?? false;

        // Update the selected event if it's the same event
        if (_selectedEvent != null && _selectedEvent!.id == eventId) {
          // Create a new event object with updated isJoined status
          _selectedEvent = EventModel(
            id: _selectedEvent!.id,
            title: _selectedEvent!.title,
            description: _selectedEvent!.description,
            cover: _selectedEvent!.cover,
            startDatetime: _selectedEvent!.startDatetime,
            endDatetime: _selectedEvent!.endDatetime,
            location: _selectedEvent!.location,
            maxParticipants: _selectedEvent!.maxParticipants,
            status: _selectedEvent!.status,
            participantsCount: _selectedEvent!.participantsCount,
            hasResult: _selectedEvent!.hasResult,
            createdAt: _selectedEvent!.createdAt,
            updatedAt: _selectedEvent!.updatedAt,
            adminName: _selectedEvent!.adminName,
            resultDescription: _selectedEvent!.resultDescription,
            savedWasteAmount: _selectedEvent!.savedWasteAmount,
            actualParticipants: _selectedEvent!.actualParticipants,
            resultPhotos: _selectedEvent!.resultPhotos,
            resultSubmittedAt: _selectedEvent!.resultSubmittedAt,
            resultSubmittedByName: _selectedEvent!.resultSubmittedByName,
            participants: _selectedEvent!.participants,
            isJoined: userHasJoined,
          );
        }

        // Update the event in the list if it exists
        final eventIndex = _events.indexWhere((event) => event.id == eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          _events[eventIndex] = EventModel(
            id: event.id,
            title: event.title,
            description: event.description,
            cover: event.cover,
            startDatetime: event.startDatetime,
            endDatetime: event.endDatetime,
            location: event.location,
            maxParticipants: event.maxParticipants,
            status: event.status,
            participantsCount: event.participantsCount,
            hasResult: event.hasResult,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            adminName: event.adminName,
            resultDescription: event.resultDescription,
            savedWasteAmount: event.savedWasteAmount,
            actualParticipants: event.actualParticipants,
            resultPhotos: event.resultPhotos,
            resultSubmittedAt: event.resultSubmittedAt,
            resultSubmittedByName: event.resultSubmittedByName,
            participants: event.participants,
            isJoined: userHasJoined,
          );
        }

        notifyListeners();
      } else {
        _error = response['message'] ?? 'Gagal bergabung/meninggalkan event';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat bergabung/meninggalkan event';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadEvents(refresh: true);
  }
}
