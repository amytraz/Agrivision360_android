import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _storage = const FlutterSecureStorage();
  
  static const String _accessTokenKey = "access_token";
  static const String _userEmailKey = "user_email";
  static const String _userNameKey = "user_name";
  static const String _userPhotoKey = "user_photo";
  static const String _userPhoneKey = "user_phone";
  static const String _isVerifiedKey = "is_verified";

  String? _accessToken;
  String? _userEmail;
  String? _userName;
  String? _userPhoto;
  String? _userPhone;
  bool _isVerified = false;

  bool get isAuthenticated => _accessToken != null;
  String get userName => _userName ?? "Farmer Friend";
  String? get userPhoto => _userPhoto;

  AuthService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString(_userEmailKey);
    _userName = prefs.getString(_userNameKey);
    _userPhoto = prefs.getString(_userPhotoKey);
    _userPhone = prefs.getString(_userPhoneKey);
    _isVerified = prefs.getBool(_isVerifiedKey) ?? false;
    notifyListeners();
  }

  // --- Mobile Auth ---
  Future<void> sendMobileOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> verifyMobileOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 2));
    if (otp == "123456") {
      _accessToken = "mobile_token_${DateTime.now().millisecondsSinceEpoch}";
      _userPhone = phone;
      _userName = "Farmer ${_userPhone!.substring(_userPhone!.length - 4)}";
      _isVerified = true;
      await _saveSession();
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Email Auth (for Signup) ---
  Future<void> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("${email}_name", name);
    await prefs.setBool("${email}_verified", false);
  }

  Future<bool> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(seconds: 2));
    if (otp == "123456") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("${email}_verified", true);
      return true;
    }
    return false;
  }

  // --- Google Auth ---
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      _accessToken = "google_token_${DateTime.now().millisecondsSinceEpoch}";
      _userEmail = googleUser.email;
      _userName = googleUser.displayName ?? _extractNameFromEmail(googleUser.email);
      _userPhoto = googleUser.photoUrl;
      _isVerified = true; 
      await _saveSession();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  String _extractNameFromEmail(String email) {
    String part = email.split('@')[0].replaceAll(RegExp(r'[0-9.]'), ' ').trim();
    return part.isEmpty ? "Farmer" : part[0].toUpperCase() + part.substring(1);
  }

  Future<void> _saveSession() async {
    await _storage.write(key: _accessTokenKey, value: _accessToken);
    final prefs = await SharedPreferences.getInstance();
    if (_userEmail != null) await prefs.setString(_userEmailKey, _userEmail!);
    if (_userName != null) await prefs.setString(_userNameKey, _userName!);
    if (_userPhoto != null) await prefs.setString(_userPhotoKey, _userPhoto!);
    if (_userPhone != null) await prefs.setString(_userPhoneKey, _userPhone!);
    await prefs.setBool(_isVerifiedKey, _isVerified);
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _accessToken = null;
    notifyListeners();
  }
}
