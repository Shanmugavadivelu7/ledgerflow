import '../../../core/api/api_client.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class SaleRepository {
  Future<List<Sale>> fetchAll() async {
    final res = await ApiClient.dio.get('/sales');
    final list = res.data['data'] as List;
    return list.map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Sale>> fetchToday() async {
    final res = await ApiClient.dio.get('/sales/today');
    final list = res.data['data'] as List;
    return list.map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Sale>> fetchByCustomer(String customerId) async {
    final res = await ApiClient.dio.get('/sales/customer/$customerId');
    final list = res.data['data'] as List;
    return list.map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Sale> fetchById(String id) async {
    final res = await ApiClient.dio.get('/sales/$id');
    return Sale.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Sale> create({
    required String customerId,
    required String paymentStatus,
    required List<SaleItem> items,
  }) async {
    final res = await ApiClient.dio.post('/sales', data: {
      'customerId': customerId,
      'paymentStatus': paymentStatus,
      'items': items.map((e) => e.toJson()).toList(),
    });
    return Sale.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await ApiClient.dio.delete('/sales/$id');
  }
}
