import '../../../core/api/api_client.dart';
import '../models/customer.dart';

class CustomerRepository {
  Future<List<Customer>> fetchAll() async {
    final res = await ApiClient.dio.get('/customers');
    final list = res.data['data'] as List;
    return list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Customer> create({required String name, String? phone}) async {
    final res = await ApiClient.dio.post('/customers', data: {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return Customer.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
