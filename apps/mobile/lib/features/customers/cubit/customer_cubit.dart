import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import 'customer_state.dart';

export 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repo;

  CustomerCubit(this._repo) : super(const CustomerInitial());

  Future<void> load() async {
    emit(const CustomerLoading());
    try {
      final customers = await _repo.fetchAll();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<bool> create({required String name, String? phone}) async {
    try {
      await _repo.create(name: name, phone: phone);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
