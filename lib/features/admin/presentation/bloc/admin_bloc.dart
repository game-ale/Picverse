import 'package:picverse/core/constants/app_constants.dart';
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
    on<AdminLoadMoreUsers>(_onLoadMoreUsers);
    on<AdminLoadPosts>(_onLoadPosts);
    on<AdminLoadMorePosts>(_onLoadMorePosts);
    on<AdminLoadReports>(_onLoadReports);
    on<AdminLoadMoreReports>(_onLoadMoreReports);
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
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          users: users,
          usersHasReachedEnd: users.length < AppConstants.feedPageSize,
        ),
      );
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
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          posts: posts,
          postsHasReachedEnd: posts.length < AppConstants.feedPageSize,
        ),
      );
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
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          reports: reports,
          reportsHasReachedEnd: reports.length < AppConstants.feedPageSize,
        ),
      );
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

  Future<void> _onLoadMoreUsers(
    AdminLoadMoreUsers event,
    Emitter<AdminState> emit,
  ) async {
    if (state.usersLoadingMore || state.usersHasReachedEnd) return;
    emit(state.copyWith(usersLoadingMore: true));
    try {
      final nextLimit = state.users.length + AppConstants.feedPageSize;
      final users = await _adminRepository.getAllUsers(nextLimit);
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          users: users,
          usersLoadingMore: false,
          usersHasReachedEnd: users.length < nextLimit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(usersLoadingMore: false));
    }
  }

  Future<void> _onLoadMorePosts(
    AdminLoadMorePosts event,
    Emitter<AdminState> emit,
  ) async {
    if (state.postsLoadingMore || state.postsHasReachedEnd) return;
    emit(state.copyWith(postsLoadingMore: true));
    try {
      final nextLimit = state.posts.length + AppConstants.feedPageSize;
      final posts = await _adminRepository.getAllPosts(nextLimit);
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          posts: posts,
          postsLoadingMore: false,
          postsHasReachedEnd: posts.length < nextLimit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(postsLoadingMore: false));
    }
  }

  Future<void> _onLoadMoreReports(
    AdminLoadMoreReports event,
    Emitter<AdminState> emit,
  ) async {
    if (state.reportsLoadingMore || state.reportsHasReachedEnd) return;
    emit(state.copyWith(reportsLoadingMore: true));
    try {
      final nextLimit = state.reports.length + AppConstants.feedPageSize;
      final reports = await _adminRepository.getPendingReports(nextLimit);
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          reports: reports,
          reportsLoadingMore: false,
          reportsHasReachedEnd: reports.length < nextLimit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(reportsLoadingMore: false));
    }
  }
}
