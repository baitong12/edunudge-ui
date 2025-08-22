
import 'package:flutter/material.dart';


class ProfileProvider with ChangeNotifier {
  String _name = '';
  String _lastname = '';
  String _email = '';
  String _phone = '';

  
  String get name => _name;
  String get lastname => _lastname;
  String get email => _email;
  String get phone => _phone;

  
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

  
  String get initials {
    final nameInitial = _name.isNotEmpty ? _name[0] : '';
    final lastnameInitial = _lastname.isNotEmpty ? _lastname[0] : '';
    if (nameInitial.isNotEmpty && lastnameInitial.isNotEmpty) {
      return nameInitial + lastnameInitial;
    }
    return '';
  }
}