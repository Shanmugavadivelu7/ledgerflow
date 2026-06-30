import '../../../core/api/api_client.dart';
import '../models/dashboard_stats.dart';

class DashboardRepository {
  Future<DashboardStats> fetchStats() async {
    final res = await ApiClient.dio.get('/dashboard');
    return DashboardStats.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
