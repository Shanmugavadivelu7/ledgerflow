import '../../../core/api/api_client.dart';
import '../models/report.dart';

class ReportRepository {
  Future<Report> fetch({required String type, String? customerId}) async {
    final params = <String, String>{'type': type};
    if (customerId != null) params['customerId'] = customerId;
    final res = await ApiClient.dio.get('/reports', queryParameters: params);
    return Report.fromJson(res.data['data'] as Map<String, dynamic>, type);
  }
}
