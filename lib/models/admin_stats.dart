class AdminStats {
  final int products;
  final int sales;
  final int commandes;
  final int clients;
  final int payments;
  final int waveRequests;

  AdminStats({
    required this.products,
    required this.sales,
    required this.commandes,
    required this.clients,
    required this.payments,
    required this.waveRequests,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      products: json['products'] ?? 0,
      sales: json['sales'] ?? 0,
      commandes: json['commandes'] ?? 0,
      clients: json['clients'] ?? 0,
      payments: json['payments'] ?? 0,
      waveRequests: json['waveRequests'] ?? 0,
    );
  }
}