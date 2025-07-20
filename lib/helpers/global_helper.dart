import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class GlobalIdentifierManager {
  static final GlobalIdentifierManager _instance =
      GlobalIdentifierManager._internal();
  factory GlobalIdentifierManager() => _instance;
  GlobalIdentifierManager._internal();

  // ValueNotifier for reactive updates
  final ValueNotifier<String> identifierNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> nameNotifier = ValueNotifier<String>('');

  // Secure storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get current identifier value
  String get currentIdentifier => identifierNotifier.value;
  String get currentName => nameNotifier.value;

  // Load identifier from secure storage
  Future<void> loadIdentifier() async {
    try {
      final userDataStr = await _storage.read(key: 'user');
      if (userDataStr != null) {
        final userData = Map<String, dynamic>.from(jsonDecode(userDataStr));
        identifierNotifier.value = userData['identifier'] ?? '';
        nameNotifier.value = userData['name'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading identifier: $e');
      identifierNotifier.value = '';
      nameNotifier.value = '';
    }
  }

  // Update identifier in secure storage and notify listeners
  Future<void> updateIdentifier(String newIdentifier) async {
    try {
      final userDataStr = await _storage.read(key: 'user');
      if (userDataStr != null) {
        final userData = Map<String, dynamic>.from(jsonDecode(userDataStr));
        userData['identifier'] = newIdentifier;
        await _storage.write(key: 'user', value: jsonEncode(userData));
        identifierNotifier.value = newIdentifier;
      }
    } catch (e) {
      debugPrint('Error updating identifier: $e');
    }
  }

  Future<void> updateName(String newName) async {
    try {
      final userDataStr = await _storage.read(key: 'user');
      if (userDataStr != null) {
        final userData = Map<String, dynamic>.from(jsonDecode(userDataStr));
        userData['name'] = newName;
        await _storage.write(key: 'user', value: jsonEncode(userData));
        nameNotifier.value = newName;
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
    }
  }

  // Listen to identifier changes
  void addListener(VoidCallback listener) {
    identifierNotifier.addListener(listener);
    nameNotifier.addListener(listener);
  }

  // Remove listener
  void removeListener(VoidCallback listener) {
    identifierNotifier.removeListener(listener);
    nameNotifier.removeListener(listener);
  }

  // Clear identifier (for logout)
  void clearIdentifier() {
    identifierNotifier.value = '';
    nameNotifier.value = '';
  }

  // Dispose resources
  void dispose() {
    identifierNotifier.dispose();
    nameNotifier.dispose();
  }
}

// Number formatting helper
class NumberFormatter {
  static String formatNumber(dynamic number) {
    try {
      if (number == null) return '0';

      // Convert to double for formatting
      double numValue;
      if (number is String) {
        numValue = double.tryParse(number) ?? 0.0;
      } else if (number is int) {
        numValue = number.toDouble();
      } else if (number is double) {
        numValue = number;
      } else {
        numValue = 0.0;
      }

      // Format with locale (Indonesian format: 123,456.78)
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(numValue);
    } catch (e) {
      debugPrint('Error formatting number: $e');
      return '0';
    }
  }

  // Simple number formatting without decimal places for home and profile screens
  static String formatSimpleNumber(dynamic number) {
    try {
      if (number == null) return '0';

      // Convert to double for formatting
      double numValue;
      if (number is String) {
        numValue = double.tryParse(number) ?? 0.0;
      } else if (number is int) {
        numValue = number.toDouble();
      } else if (number is double) {
        numValue = number;
      } else {
        numValue = 0.0;
      }

      // Format with locale without decimal places (Indonesian format: 123,456)
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(numValue);
    } catch (e) {
      debugPrint('Error formatting simple number: $e');
      return '0';
    }
  }
}
