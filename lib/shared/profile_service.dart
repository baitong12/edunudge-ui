
class ProfileService {

  static Future<bool> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
  }) async {

    print('Updating profile with: name=$name, email=$email, phone=$phone');
    return true; 
  }

  static Future<bool> changePassword({
    required String token,
    required String newPassword,
  }) async {

    print('Changing password...');
    return true;
  }
}