class ProfileService {
  static Future<bool> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
  }) async {
    return true;
  }

  static Future<bool> changePassword({
    required String token,
    required String newPassword,
  }) async {
    return true;
  }
}
