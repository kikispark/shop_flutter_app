import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  //It mixes in ChangeNotifier, which allows widgets listening to it to rebuild when notifyListeners() is called.

  String? _token; // Stores the authentication token from Firebase
  DateTime? _expiryDate; //stores when the token will expire
  String? _userId;
  Timer? _authTimer; // Timer to automatically log out when the token expires

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(
          DateTime.now(),
        ) && //Checks _expiryDate is after the current time (meaning the token is still valid — it hasn’t expired yet).
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
    //Future : The result of an asynchronous computation.
    //Method used for both signup and login.
    String email,
    String password,
    String urlSegment, //urlSegment is either "signUp" or "signInWithPassword".
  ) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAYtMa8NgdUhuzlkY1awKmcnBreLUzaynE', //This builds the Firebase Auth REST API URL.
    );
    try {
      final response = await http.post(
        //http.post its a function from http package to send http requests to a server
        url,
        body: json.encode({
          //convert dart object into json format
          //The body is the actual data you are sending to the server in your POST request.
          // Servers usually expect data in a structured format — often JSON.
          'email': email,
          'password': password,
          'returnSecureToken': true, //tells Firebase to return a token
        }),
      );
      final responseData = json.decode(
        response.body,
      ); //Decodes JSON into a Dart map. take the type Map<String, dynamic> but dosnt display that in print (terminal)
      print('responseData from auth <3333333 $responseData');
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ), //converts it into an integer ,Duration is a Dart class that represents a length of time
      );
      // _autoLogout();
      // notifyListeners();
      // final prefs = await SharedPreferences.getInstance();
      // final userData = json.encode(
      //   {
      //     'token': _token,
      //     'userId': _userId,
      //     'expiryDate': _expiryDate.toIso8601String(),
      //   },
      // );
      // prefs.setString('userData', userData);
      _autoLogout();
      notifyListeners();
      final prefs =
          await SharedPreferences.getInstance(); //Retrieves the SharedPreferences instance, which lets you store key-value pairs locally on the device.
      //SharedPreferences can only store simple types: String, int, double, bool, List<String>.
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString(
        //.setString() takes a String and stores it under the key 'userData'.
        'userData',
        userData,
      ); //Saves the JSON string under the key 'userData'.
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    print('Checking for stored userData...');

    if (!prefs.containsKey('userData')) {
      print('No userData found in SharedPreferences');
      return false;
    }

    final storedData = prefs.getString('userData');
    print('Stored userData: $storedData');

    final extractedUserData =
        json.decode(storedData!)
            as Map<
              String,
              Object
            >; //dynamic → you can do anything with the value (no compile-time checks).

    // Object → values are treated as objects; safer because you cannot accidentally call arbitrary
    final expiryDate = DateTime.parse(
      extractedUserData['expiryDate'] as String,
    );

    print('Stored expiry date: $expiryDate');
    print('Current time: ${DateTime.now()}');
    print('Is token expired? ${expiryDate.isBefore(DateTime.now())}');

    if (expiryDate.isBefore(DateTime.now())) {
      print('Token expired, returning false');
      return false;
    }

    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    print('Auto-login successful');
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
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
    //this function is for autologout if expire token
    if (_authTimer != null) {
      // There is an existing Timer running or scheduled

      _authTimer
          ?.cancel(); //cancel So you don’t have multiple timers running if the user logs in again.
    }
    if (_expiryDate != null) {
      final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
      print('Time to expiry: $timeToExpiry seconds');
      print('Current time: ${DateTime.now()}');
      print('Expiry time: $_expiryDate');
      if (timeToExpiry > 0) {
        //timeToExpiry > 0 means the token is still valid — the expiration time is in the future.
        _authTimer = Timer(
          Duration(seconds: timeToExpiry),
          logout,
        ); //The timer is used for auto-logout: it automatically calls the logout() function exactly when the token expires.
        // creates a countdown timer.
        // The timer waits for timeToExpiry seconds.
        // When the timer finishes counting down, it automatically calls the logout() method.
      } else {
        //Token already expired → logout immediately
        print('Token already expired, logging out immediately');
        logout();
      }
    }
  }
}
