import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  final Map<int, bool> _initializedScreens = {};

  int get selectedIndex => _selectedIndex;

  bool isScreenInitialized(int index) {
    return _initializedScreens[index] ?? false;
  }

  void markScreenAsInitialized(int index) {
    _initializedScreens[index] = true;
    notifyListeners();
  }

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
