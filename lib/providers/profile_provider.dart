import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = '';
  String _lastname = '';
  String _email = '';
  String _phone = '';

  // getters
  String get name => _name;
  String get lastname => _lastname;
  String get email => _email;
  String get phone => _phone;

  String get initials {
    String first = _name.isNotEmpty ? _name[0] : '';
    String last = _lastname.isNotEmpty ? _lastname[0] : '';
    return (first + last).toUpperCase();
  }

  // setters
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  set lastname(String value) {
    _lastname = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set phone(String value) {
    _phone = value;
    notifyListeners();
  }

  // Set all data at once
  void setProfileData({
    required String name,
    required String lastname,
    required String email,
    required String phone,
  }) {
    _name = name;
    _lastname = lastname;
    _email = email;
    _phone = phone;
    notifyListeners();
  }
}
