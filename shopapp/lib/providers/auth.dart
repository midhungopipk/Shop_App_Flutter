import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token = '';
  DateTime? _expiryTime = DateTime.now();
  String _userId = '';
  Timer? _authTimer;
  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryTime != null &&
        _expiryTime!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=[api key]');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      // print(json.decode(response.body));
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryTime = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryTime": _expiryTime!.toIso8601String(),
      });

      prefs.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("userData")) {
      return false;
    }
    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, dynamic>;
    final expiryTime =
        DateTime.parse(extractedUserData['expiryTime'].toString());
    print("${expiryTime.isBefore(DateTime.now())} expiry time is before ");
    if (expiryTime.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expiryTime = expiryTime;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    print('logout is called');
    _token = '';
    _userId = '';
    _expiryTime = null;
    print(_authTimer);
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryTime!.difference(DateTime.now()).inSeconds;
    print("$timeToExpiry is time to expiry");
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
