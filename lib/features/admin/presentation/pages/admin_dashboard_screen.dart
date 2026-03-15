import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:picverse/features/admin/presentation/bloc/admin_event.dart';
import 'package:picverse/features/admin/presentation/pages/admin_overview_tab.dart';
import 'package:picverse/features/admin/presentation/pages/admin_posts_tab.dart';
import 'package:picverse/features/admin/presentation/pages/admin_reports_tab.dart';
import 'package:picverse/features/admin/presentation/pages/admin_users_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final _tabs = const [
    AdminOverviewTab(),
    AdminUsersTab(),
    AdminPostsTab(),
    AdminReportsTab(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: isDark ? AppColors.grey400 : AppColors.grey500,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.read<AdminBloc>().add(AdminLoadDashboard());
              break;
            case 1:
              context.read<AdminBloc>().add(AdminLoadUsers());
              break;
            case 2:
              context.read<AdminBloc>().add(AdminLoadPosts());
              break;
            case 3:
              context.read<AdminBloc>().add(AdminLoadReports());
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
