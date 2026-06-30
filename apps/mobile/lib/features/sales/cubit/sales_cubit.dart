import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/sale.dart';
import '../repositories/sale_repository.dart';
import 'sales_state.dart';

export 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SaleRepository _repo;
  bool _showingToday = true;

  SalesCubit(this._repo) : super(const SalesInitial());

  bool get showingToday => _showingToday;

  Future<void> loadToday() async {
    _showingToday = true;
    emit(const SalesLoading());
    try {
      final sales = await _repo.fetchToday();
      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> loadAll() async {
    _showingToday = false;
    emit(const SalesLoading());
    try {
      final sales = await _repo.fetchAll();
      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      if (_showingToday) {
        await loadToday();
      } else {
        await loadAll();
      }
    } catch (_) {}
  }
}
