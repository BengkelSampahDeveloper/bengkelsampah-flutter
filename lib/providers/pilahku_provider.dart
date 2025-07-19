import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/pilahku_model.dart';
import '../services/api_service.dart';

class PilahkuProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _storageKey = 'pilahku_items';

  List<PilahkuItemModel> _items = [];
  List<String> _selectedItemIds = [];
  String? _selectedBranchFilter;
  bool _isLoading = false;
  Set<String> _disabledItemIds = {}; // Track disabled items

  List<PilahkuItemModel> get items => _items;
  List<String> get selectedItemIds => _selectedItemIds;
  String? get selectedBranchFilter => _selectedBranchFilter;
  bool get isLoading => _isLoading;
  bool get hasItems => _items.isNotEmpty;
  bool get hasSelectedItems => _selectedItemIds.isNotEmpty;
  bool get isAllSelected =>
      _items.isNotEmpty && _selectedItemIds.length == _items.length;
  Set<String> get disabledItemIds => _disabledItemIds;

  // Check if item is disabled
  bool isItemDisabled(String itemId) => _disabledItemIds.contains(itemId);

  // Get enabled items only
  List<PilahkuItemModel> get enabledItems =>
      _items.where((item) => !_disabledItemIds.contains(item.id)).toList();

  // Get disabled items only
  List<PilahkuItemModel> get disabledItems =>
      _items.where((item) => _disabledItemIds.contains(item.id)).toList();

  // Get filtered items based on branch filter
  List<PilahkuItemModel> get filteredItems {
    if (_selectedBranchFilter == null) {
      return _items;
    }
    return _items
        .where((item) => item.bankSampahId == _selectedBranchFilter)
        .toList();
  }

  // Get unique branches from items
  List<String> get availableBranches {
    final branches = <String>[];
    for (final item in _items) {
      if (!branches.contains(item.bankSampahId)) {
        branches.add(item.bankSampahId);
      }
    }
    return branches;
  }

  // Get branch names for filter
  List<Map<String, String>> get branchFilterOptions {
    final options = <Map<String, String>>[];
    for (final item in _items) {
      final exists = options.any((option) => option['id'] == item.bankSampahId);
      if (!exists) {
        options.add({
          'id': item.bankSampahId,
          'name': item.bankSampahNama,
        });
      }
    }
    return options;
  }

  // Calculate total price for selected items
  double get totalSelectedPrice {
    return _items
        .where((item) => _selectedItemIds.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.totalHarga);
  }

  // Calculate total weight for selected items
  double get totalSelectedWeight {
    return _items
        .where((item) => _selectedItemIds.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.estimasiBerat);
  }

  // Load items from secure storage
  Future<void> loadItems() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final itemsJson = await _storage.read(key: _storageKey);
      if (itemsJson != null && itemsJson.isNotEmpty) {
        final List<dynamic> itemsList = json.decode(itemsJson);
        _items = _parseItemsSafely(itemsList);
      } else {
        _items = [];
      }
    } catch (e) {
      debugPrint('Error loading pilahku items: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Parse items safely with validation
  List<PilahkuItemModel> _parseItemsSafely(List<dynamic> itemsList) {
    final List<PilahkuItemModel> loadedItems = [];

    for (final itemData in itemsList) {
      try {
        if (itemData is Map<String, dynamic>) {
          final item = PilahkuItemModel.fromJson(itemData);
          if (_isValidItem(item)) {
            loadedItems.add(item);
          }
        }
      } catch (e) {
        debugPrint('Error parsing item: $e');
      }
    }

    return loadedItems;
  }

  // Validate item data
  bool _isValidItem(PilahkuItemModel item) {
    return item.id.isNotEmpty &&
        item.sampahNama.isNotEmpty &&
        item.bankSampahId.isNotEmpty;
  }

  // Save items to secure storage
  Future<void> _saveItems() async {
    try {
      final validItems = _items.where(_isValidItem).toList();
      final itemsJson =
          json.encode(validItems.map((item) => item.toJson()).toList());
      await _storage.write(key: _storageKey, value: itemsJson);
    } catch (e) {
      debugPrint('Error saving pilahku items: $e');
    }
  }

  // Add item to pilahku
  Future<void> addItem(PilahkuItemModel item) async {
    if (!_isValidItem(item)) {
      debugPrint('Invalid item data, skipping add');
      return;
    }

    try {
      debugPrint(
          'Adding item to pilahku: ${item.sampahNama} - Service Type: ${item.bankSampahTipeLayanan}');

      final existingIndex = _items.indexWhere((existing) =>
          existing.sampahId == item.sampahId &&
          existing.bankSampahId == item.bankSampahId);

      if (existingIndex != -1) {
        debugPrint(
            'Updating existing item with service type: ${item.bankSampahTipeLayanan}');
        _items[existingIndex] = _items[existingIndex].copyWith(
          estimasiBerat:
              _items[existingIndex].estimasiBerat + item.estimasiBerat,
          bankSampahTipeLayanan: item.bankSampahTipeLayanan ??
              _items[existingIndex].bankSampahTipeLayanan,
        );
      } else {
        debugPrint(
            'Adding new item with service type: ${item.bankSampahTipeLayanan}');
        _items.add(item);
      }

      await _saveItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item to pilahku: $e');
    }
  }

  // Remove item from pilahku
  Future<void> removeItem(String itemId) async {
    if (itemId.isEmpty) return;

    try {
      _items.removeWhere((item) => item.id == itemId);
      _selectedItemIds.remove(itemId);
      await _saveItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing item from pilahku: $e');
    }
  }

  // Remove multiple items
  Future<void> removeSelectedItems() async {
    try {
      final validIds = _selectedItemIds.where((id) => id.isNotEmpty).toList();
      _items.removeWhere((item) => validIds.contains(item.id));
      _selectedItemIds.clear();
      await _saveItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing selected items from pilahku: $e');
    }
  }

  // Update item weight
  Future<void> updateItemWeight(String itemId, double newWeight) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(estimasiBerat: newWeight);
      await _saveItems();
      notifyListeners();
    }
  }

  // Update item branch and price
  Future<void> updateItemBranch(String itemId, String newBankSampahId,
      String newBankSampahNama, double newHargaPerSatuan) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        bankSampahId: newBankSampahId,
        bankSampahNama: newBankSampahNama,
        hargaPerSatuan: newHargaPerSatuan,
      );
      await _saveItems();
      notifyListeners();
    }
  }

  // Update item service type
  Future<void> updateItemServiceType(String itemId, String? serviceType) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        bankSampahTipeLayanan: serviceType,
      );
      await _saveItems();
      notifyListeners();
    }
  }

  // Migrate existing items to include service type (for backward compatibility)
  Future<void> migrateServiceTypes() async {
    bool hasChanges = false;

    debugPrint('Starting service type migration for ${_items.length} items');

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].bankSampahTipeLayanan == null) {
        debugPrint(
            'Migrating item ${_items[i].sampahNama} to include service type');
        // Set default service type for items without it
        _items[i] = _items[i].copyWith(
          bankSampahTipeLayanan: 'tempat', // Default to drop-off service
        );
        hasChanges = true;
      } else {
        debugPrint(
            'Item ${_items[i].sampahNama} already has service type: ${_items[i].bankSampahTipeLayanan}');
      }
    }

    if (hasChanges) {
      debugPrint('Saving migrated items with service types');
      await _saveItems();
      notifyListeners();
    } else {
      debugPrint('No items needed migration');
    }
  }

  // Selection methods
  void selectItem(String itemId) {
    try {
      if (itemId.isNotEmpty && !_selectedItemIds.contains(itemId)) {
        _selectedItemIds.add(itemId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error selecting item: $e');
    }
  }

  void unselectItem(String itemId) {
    try {
      if (itemId.isNotEmpty) {
        _selectedItemIds.remove(itemId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error unselecting item: $e');
    }
  }

  void selectAll() {
    try {
      _selectedItemIds =
          _items.map((item) => item.id).where((id) => id.isNotEmpty).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting all items: $e');
    }
  }

  void unselectAll() {
    try {
      _selectedItemIds.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error unselecting all items: $e');
    }
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      unselectAll();
    } else {
      selectAll();
    }
  }

  // Filter methods
  void setBranchFilter(String? branchId) {
    _selectedBranchFilter = branchId;
    notifyListeners();
  }

  void clearBranchFilter() {
    _selectedBranchFilter = null;
    notifyListeners();
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    _items.clear();
    _selectedItemIds.clear();
    _selectedBranchFilter = null;
    await _storage.delete(key: _storageKey);
    notifyListeners();
  }

  // Check if item exists in pilahku
  bool isItemInPilahku(int sampahId, String bankSampahId) {
    return _items.any((item) =>
        item.sampahId == sampahId && item.bankSampahId == bankSampahId);
  }

  // Get existing item if exists
  PilahkuItemModel? getExistingItem(int sampahId, String bankSampahId) {
    try {
      return _items.firstWhere((item) =>
          item.sampahId == sampahId && item.bankSampahId == bankSampahId);
    } catch (e) {
      return null;
    }
  }

  // Cek status pilahku items sebelum setor
  Future<Map<String, dynamic>> checkPilahkuItems(
      List<PilahkuItemModel> items) async {
    final api = ApiService();
    final List<Map<String, dynamic>> mapped = items
        .map((item) => {
              'bank_sampah_id': int.tryParse(item.bankSampahId) ?? 0,
              'sampah_id': item.sampahId,
              'tipe_layanan': item.bankSampahTipeLayanan ?? '',
              'detail_sampah': {
                'nama': item.sampahNama,
                'satuan': item.sampahSatuan,
                'deskripsi': item.sampahDeskripsi,
              },
              'harga': item.hargaPerSatuan,
            })
        .toList();
    return await api.checkPilahkuItems(mapped);
  }

  // Auto-disable items based on check results
  void autoDisableItems(List<dynamic> checkResults) {
    _disabledItemIds.clear();

    for (final result in checkResults) {
      final bankSampahId = result['bank_sampah_id'].toString();
      final sampahId = result['sampah_id'].toString();
      final status = result['status'];

      // Find items that match this bank_sampah_id and sampah_id
      for (final item in _items) {
        if (item.bankSampahId == bankSampahId &&
            item.sampahId.toString() == sampahId) {
          // Disable items that have bank_sampah_not_found or sampah_not_found
          if (status == 'bank_sampah_not_found' ||
              status == 'sampah_not_found') {
            _disabledItemIds.add(item.id);
            // Remove from selected items if disabled
            _selectedItemIds.remove(item.id);
          }
        }
      }
    }

    notifyListeners();
  }

  // Update items based on check results
  Future<void> updateItemsFromCheckResults(List<dynamic> checkResults) async {
    bool hasUpdates = false;

    for (final result in checkResults) {
      final bankSampahId = result['bank_sampah_id'].toString();
      final sampahId = result['sampah_id'].toString();
      final status = result['status'];
      final changes = result['changes'];

      if (changes == null || changes is! Map<String, dynamic>) continue;

      // Find items that match this bank_sampah_id and sampah_id
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        if (item.bankSampahId == bankSampahId &&
            item.sampahId.toString() == sampahId) {
          PilahkuItemModel updatedItem = item;

          // Update tipe layanan if changed
          if (status == 'tipe_layanan_changed' &&
              changes['tipe_layanan'] != null) {
            updatedItem = updatedItem.copyWith(
              bankSampahTipeLayanan: changes['tipe_layanan'].toString(),
            );
            hasUpdates = true;
          }

          // Update detail sampah if changed
          if (status == 'detail_sampah_changed' &&
              changes['detail_sampah'] != null) {
            final detailChanges = changes['detail_sampah'];
            if (detailChanges is Map<String, dynamic>) {
              if (detailChanges['nama'] != null &&
                  detailChanges['nama'] is Map<String, dynamic>) {
                final namaChange =
                    detailChanges['nama'] as Map<String, dynamic>;
                if (namaChange['new'] != null) {
                  updatedItem = updatedItem.copyWith(
                    sampahNama: namaChange['new'].toString(),
                  );
                }
              }
              if (detailChanges['satuan'] != null &&
                  detailChanges['satuan'] is Map<String, dynamic>) {
                final satuanChange =
                    detailChanges['satuan'] as Map<String, dynamic>;
                if (satuanChange['new'] != null) {
                  updatedItem = updatedItem.copyWith(
                    sampahSatuan: satuanChange['new'].toString(),
                  );
                }
              }
              if (detailChanges['deskripsi'] != null &&
                  detailChanges['deskripsi'] is Map<String, dynamic>) {
                final deskripsiChange =
                    detailChanges['deskripsi'] as Map<String, dynamic>;
                if (deskripsiChange['new'] != null) {
                  updatedItem = updatedItem.copyWith(
                    sampahDeskripsi: deskripsiChange['new'].toString(),
                  );
                }
              }
              hasUpdates = true;
            }
          }

          // Update harga if changed
          if (status == 'harga_changed' && changes['harga'] != null) {
            final newHarga = double.tryParse(changes['harga'].toString()) ??
                item.hargaPerSatuan;
            updatedItem = updatedItem.copyWith(
              hargaPerSatuan: newHarga,
            );
            hasUpdates = true;
          }

          // Update the item in the list
          _items[i] = updatedItem;
        }
      }
    }

    // Save to storage if there were updates
    if (hasUpdates) {
      await _saveItems();
      notifyListeners();
    }
  }

  // Remove all disabled items
  Future<void> removeDisabledItems() async {
    try {
      _items.removeWhere((item) => _disabledItemIds.contains(item.id));
      _selectedItemIds.removeWhere((id) => _disabledItemIds.contains(id));
      _disabledItemIds.clear();
      await _saveItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing disabled items: $e');
    }
  }

  // Clear disabled items tracking (for testing/reset)
  void clearDisabledItems() {
    _disabledItemIds.clear();
    notifyListeners();
  }
}
