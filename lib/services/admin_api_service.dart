import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class AdminApiService {
  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/api/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'admin': data['admin'],
        'token': data['token'] ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      };
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['error'] ?? 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> getStats(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/api/admin/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'stats': data};
    } else {
      return {'success': false, 'error': 'Erreur lors du chargement des stats'};
    }
  }
}