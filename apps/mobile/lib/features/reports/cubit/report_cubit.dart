import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/report.dart';
import '../repositories/report_repository.dart';
import 'report_state.dart';

export 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repo;

  ReportCubit(this._repo) : super(const ReportInitial());

  Future<void> load({required String type, String? customerId}) async {
    emit(const ReportLoading());
    try {
      final report = await _repo.fetch(type: type, customerId: customerId);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
