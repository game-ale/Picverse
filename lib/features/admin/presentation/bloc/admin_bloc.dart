import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/features/admin/domain/repositories/admin_repository.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_event.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const AdminState()) {
    on<AdminLoadDashboard>(_onLoadDashboard);
    on<AdminLoadUsers>(_onLoadUsers);
    on<AdminLoadPosts>(_onLoadPosts);
    on<AdminLoadReports>(_onLoadReports);
    on<AdminBanUser>(_onBanUser);
    on<AdminUnbanUser>(_onUnbanUser);
    on<AdminDeletePost>(_onDeletePost);
    on<AdminResolveReport>(_onResolveReport);
    on<AdminDismissReport>(_onDismissReport);
  }

  Future<void> _onLoadDashboard(
    AdminLoadDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final stats = await _adminRepository.getStats();
      final reports = await _adminRepository.getPendingReports();
      emit(state.copyWith(
        status: AdminStatus.loaded,
        stats: stats,
        reports: reports,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadUsers(
    AdminLoadUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final users = await _adminRepository.getAllUsers();
      emit(state.copyWith(status: AdminStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadPosts(
    AdminLoadPosts event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final posts = await _adminRepository.getAllPosts();
      emit(state.copyWith(status: AdminStatus.loaded, posts: posts));
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadReports(
    AdminLoadReports event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final reports = await _adminRepository.getPendingReports();
      emit(state.copyWith(status: AdminStatus.loaded, reports: reports));
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onBanUser(
    AdminBanUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.banUser(event.userId);
      add(AdminLoadUsers());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to ban user'));
    }
  }

  Future<void> _onUnbanUser(
    AdminUnbanUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.unbanUser(event.userId);
      add(AdminLoadUsers());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to unban user'));
    }
  }

  Future<void> _onDeletePost(
    AdminDeletePost event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.deletePost(event.postId);
      add(AdminLoadPosts());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete post'));
    }
  }

  Future<void> _onResolveReport(
    AdminResolveReport event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.resolveReport(event.reportId);
      add(AdminLoadReports());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to resolve report'));
    }
  }

  Future<void> _onDismissReport(
    AdminDismissReport event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.dismissReport(event.reportId);
      add(AdminLoadReports());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to dismiss report'));
    }
  }
}
