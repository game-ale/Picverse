import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picverse/core/local/hive_adapters.dart';
import 'package:picverse/core/theme/app_theme.dart';
import 'package:picverse/core/theme/theme_cubit.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/injection_container.dart';
import 'package:picverse/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(PostModelAdapter());

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Theme preference
  final themeCubit = ThemeCubit();
  await themeCubit.init();

  // Dependency injection
  final di = InjectionContainer();
  await di.init();

  runApp(PicverseApp(di: di, themeCubit: themeCubit));
}

class PicverseApp extends StatelessWidget {
  final InjectionContainer di;
  final ThemeCubit themeCubit;

  const PicverseApp({super.key, required this.di, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: themeCubit,
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
                  return MaterialApp.router(
                    title: 'Picverse',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    routerConfig: router,
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
