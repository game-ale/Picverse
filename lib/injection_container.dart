import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/local/local_cache_service.dart';
import 'package:picverse/core/local/offline_queue_service.dart';
import 'package:picverse/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:picverse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:picverse/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:picverse/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:picverse/features/post/data/repositories/post_repository_impl.dart';
import 'package:picverse/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:picverse/features/search/data/repositories/search_repository_impl.dart';
import 'package:picverse/features/admin/domain/repositories/admin_repository.dart';
import 'package:picverse/features/auth/domain/repositories/auth_repository.dart';
import 'package:picverse/features/feed/domain/repositories/feed_repository.dart';
import 'package:picverse/features/notification/domain/repositories/notification_repository.dart';
import 'package:picverse/features/post/domain/repositories/post_repository.dart';
import 'package:picverse/features/profile/domain/repositories/profile_repository.dart';
import 'package:picverse/features/search/domain/repositories/search_repository.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_event.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:picverse/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:picverse/features/post/presentation/bloc/post_bloc.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:picverse/features/search/presentation/bloc/search_bloc.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/services/connectivity_service.dart';
import 'package:picverse/core/services/firestore_service.dart';
import 'package:picverse/core/services/storage_service.dart';

class InjectionContainer {
  // Services
  late final AuthService authService;
  late final FirestoreService firestoreService;
  late final StorageService storageService;
  late final ConnectivityService connectivityService;
  late final LocalCacheService localCacheService;
  late final OfflineQueueService offlineQueueService;

  // Repositories (abstract types)
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final PostRepository postRepository;
  late final FeedRepository feedRepository;
  late final NotificationRepository notificationRepository;
  late final SearchRepository searchRepository;
  late final AdminRepository adminRepository;

  Future<void> init() async {
    // ─── Services ───
    authService = AuthService();
    firestoreService = FirestoreService();
    storageService = StorageService();
    connectivityService = ConnectivityService();
    await connectivityService.init();
    localCacheService = LocalCacheService();
    offlineQueueService = OfflineQueueService();

    // ─── Repositories (concrete → abstract) ───
    authRepository = AuthRepositoryImpl(
      authService: authService,
      firestoreService: firestoreService,
    );
    profileRepository = ProfileRepositoryImpl(
      firestoreService: firestoreService,
      storageService: storageService,
      cacheService: localCacheService,
      connectivityService: connectivityService,
    );
    postRepository = PostRepositoryImpl(
      firestoreService: firestoreService,
      storageService: storageService,
      cacheService: localCacheService,
      offlineQueue: offlineQueueService,
      connectivityService: connectivityService,
    );
    feedRepository = FeedRepositoryImpl(
      firestoreService: firestoreService,
      cacheService: localCacheService,
      connectivityService: connectivityService,
    );
    notificationRepository = NotificationRepositoryImpl(
      firestoreService: firestoreService,
    );
    searchRepository = SearchRepositoryImpl(firestoreService: firestoreService);
    adminRepository = AdminRepositoryImpl(firestoreService: firestoreService);
  }

  /// Build [RepositoryProvider] list for [MultiRepositoryProvider].
  List<RepositoryProvider> get repositoryProviders => [
    RepositoryProvider<AuthService>.value(value: authService),
    RepositoryProvider<FirestoreService>.value(value: firestoreService),
    RepositoryProvider<AdminRepository>.value(value: adminRepository),
  ];

  /// Build [BlocProvider] list for [MultiBlocProvider].
  List<BlocProvider> get blocProviders => [
    BlocProvider<AuthBloc>(
      create: (_) =>
          AuthBloc(authRepository: authRepository)..add(AuthCheckRequested()),
    ),
    BlocProvider<ProfileBloc>(
      create: (_) => ProfileBloc(
        profileRepository: profileRepository,
        postRepository: postRepository,
        authService: authService,
      ),
    ),
    BlocProvider<FeedBloc>(
      create: (_) => FeedBloc(
        feedRepository: feedRepository,
        postRepository: postRepository,
        authService: authService,
        connectivityService: connectivityService,
        cacheService: localCacheService,
      ),
    ),
    BlocProvider<PostBloc>(
      create: (_) => PostBloc(
        postRepository: postRepository,
        authRepository: authRepository,
        authService: authService,
      ),
    ),
    BlocProvider<NotificationBloc>(
      create: (_) => NotificationBloc(
        notificationRepository: notificationRepository,
        authService: authService,
      ),
    ),
    BlocProvider<SearchBloc>(
      create: (_) => SearchBloc(searchRepository: searchRepository),
    ),
    BlocProvider<AdminBloc>(
      create: (_) => AdminBloc(adminRepository: adminRepository),
    ),
  ];
}
