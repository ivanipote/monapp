import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    // ✅ 1. Afficher l'URL et les données envoyées
    final url = Uri.parse('${Constants.apiUrl}/api/client/login');
    print('📤 URL: $url');
    print('📤 Email: $email');
    print('📤 Password: $password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    // ✅ 2. Afficher la réponse brute
    print('📥 Statut: ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'user': data['user']};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['error'] ?? 'Erreur inconnue'};
    }
  }
}