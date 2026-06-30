import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;

  DashboardCubit(this._repo) : super(const DashboardInitial());

  Future<void> load() async {
    emit(const DashboardLoading());
    try {
      final stats = await _repo.fetchStats();
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
