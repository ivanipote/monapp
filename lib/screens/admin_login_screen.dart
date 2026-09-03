import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admin_api_service.dart';
import 'admin_stats_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AdminApiService _apiService = AdminApiService();

  String _password = '';
  bool _isLoading = false;
  String _errorMessage = '';

  // ✅ Vérifier si déjà connecté
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminStatsScreen()),
      );
    }
  }

  void _onDigitPressed(String digit) {
    if (_password.length < 6) {
      setState(() {
        _password += digit;
        _errorMessage = '';
      });
      // ✅ Si 6 chiffres, auto-login
      if (_password.length == 6) {
        _login();
      }
    }
  }

  void _deleteLastDigit() {
    if (_password.isNotEmpty) {
      setState(() {
        _password = _password.substring(0, _password.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _login() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre email.';
      });
      return;
    }

    if (_password.length != 6) {
      setState(() {
        _errorMessage = 'Code à 6 chiffres requis.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.loginAdmin(email, _password);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final token = result['token'] ?? 'session';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', token);
      await prefs.setString('admin_email', email);
      await prefs.setInt('admin_id', result['admin']['id'] ?? 1);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminStatsScreen()),
      );
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Erreur de connexion';
        _password = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email admin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Affichage du code (●●●●●●)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 30,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      _password.length > index ? '●' : '',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),

            // ✅ Pavé numérique
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _numButton('1'),
                      _numButton('2'),
                      _numButton('3'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _numButton('4'),
                      _numButton('5'),
                      _numButton('6'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _numButton('7'),
                      _numButton('8'),
                      _numButton('9'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 60),
                      _numButton('0'),
                      _deleteButton(),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _numButton(String digit) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _onDigitPressed(digit),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          elevation: 2,
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _deleteLastDigit,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.red[100],
          foregroundColor: Colors.red,
          elevation: 2,
        ),
        child: const Icon(Icons.backspace, size: 28),
      ),
    );
  }
}