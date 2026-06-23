import 'package:flutter/material.dart';
import '../machine_models/auth/officer_auth_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  String _enteredCode = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _sessionToken;
  String? _officerName;
  
  String get enteredCode => _enteredCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get sessionToken => _sessionToken;
  String? get officerName => _officerName;
  
  void updateCode(String code) {
    _enteredCode = code;
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearCode() {
    _enteredCode = '';
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> authenticateOfficer(int machineId) async {
    if (_enteredCode.length != 6) {
      _errorMessage = 'Please enter 6-digit code';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = OfficerAuthRequest(
        code: _enteredCode,
        machineId: machineId,
      );
      
      final response = await _apiService.authenticateOfficer(request);
      
      if (response.success) {
        _isAuthenticated = true;
        _sessionToken = response.sessionToken;
        _officerName = response.officerName;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Invalid code. Please try again.';
        _enteredCode = ''; 
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection anomaly occurred.';
      _enteredCode = '';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void resetAuth() {
    _enteredCode = '';
    _isLoading = false;
    _errorMessage = null;
    _isAuthenticated = false;
    _sessionToken = null;
    _officerName = null;
    notifyListeners();
  }
}