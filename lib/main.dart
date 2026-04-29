import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picverse/core/local/hive_adapters.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/local/fallback_localization_delegates.dart';
import 'package:picverse/core/local/language_cubit.dart';
import 'package:picverse/core/theme/app_theme.dart';
import 'package:picverse/core/theme/theme_cubit.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/core/services/push_notification_service.dart';
import 'package:picverse/injection_container.dart';
import 'package:picverse/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use native Firebase config files on mobile platforms.
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(PostModelAdapter());

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Theme preference
  final themeCubit = ThemeCubit();
  await themeCubit.init();
  final languageCubit = LanguageCubit();
  await languageCubit.init();

  // Dependency injection
  final di = InjectionContainer();
  await di.init();
  await di.pushNotificationService.init();

  runApp(
    PicverseApp(
      di: di,
      themeCubit: themeCubit,
      languageCubit: languageCubit,
    ),
  );
}

class PicverseApp extends StatelessWidget {
  final InjectionContainer di;
  final ThemeCubit themeCubit;
  final LanguageCubit languageCubit;

  const PicverseApp({
    super.key,
    required this.di,
    required this.themeCubit,
    required this.languageCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: languageCubit),
      ],
      child: MultiRepositoryProvider(
        providers: di.repositoryProviders,
        child: MultiBlocProvider(
          providers: di.blocProviders,
          child: Builder(
            builder: (context) {
              final authBloc = context.read<AuthBloc>();
              final router = AppRouter.router(authBloc);

              return BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return BlocBuilder<LanguageCubit, Locale>(
                    builder: (context, locale) {
                      return MaterialApp.router(
                        title: 'Picverse',
                        debugShowCheckedModeBanner: false,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: themeMode,
                        locale: locale,
                        supportedLocales:
                            AppLocalizations.supportedLocales,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          AppMaterialLocalizationsDelegate(),
                          GlobalWidgetsLocalizations.delegate,
                          AppCupertinoLocalizationsDelegate(),
                        ],
                        routerConfig: router,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
