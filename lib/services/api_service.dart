import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/api/client/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'user': data['user']};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['error'] ?? 'Erreur inconnue'};
    }
  }
}