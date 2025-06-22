import 'package:flutter/material.dart';


class ProfileProvider with ChangeNotifier {
  String _name = "ชื่อ–นามสกุล";

  String get name => _name;

  void setName(String newName) {
    _name = newName;
    notifyListeners(); // แจ้งผู้ฟังให้รีเฟรช
  }

  String get initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    } else if (parts.isNotEmpty) {
      return parts[0][0];
    }
    return '?';
  }
}
