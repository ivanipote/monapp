import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admin_api_service.dart';
import '../models/admin_stats.dart';
import 'admin_login_screen.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final AdminApiService _apiService = AdminApiService();
  AdminStats? _stats;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getStats(token);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _stats = AdminStats.fromJson(result['stats']);
      });
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Erreur de chargement';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_email');
    await prefs.remove('admin_id');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Admin Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _statCard(
                        '📦 Produits',
                        _stats!.products.toString(),
                        Colors.blue,
                      ),
                      _statCard(
                        '💰 Ventes',
                        '${_stats!.sales} FCFA',
                        Colors.green,
                      ),
                      _statCard(
                        '📋 Commandes',
                        _stats!.commandes.toString(),
                        Colors.orange,
                      ),
                      _statCard(
                        '👤 Clients',
                        _stats!.clients.toString(),
                        Colors.purple,
                      ),
                      _statCard(
                        '💳 Paiements',
                        _stats!.payments.toString(),
                        Colors.teal,
                      ),
                      _statCard(
                        '🌊 Demandes Wave',
                        _stats!.waveRequests.toString(),
                        Colors.indigo,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}