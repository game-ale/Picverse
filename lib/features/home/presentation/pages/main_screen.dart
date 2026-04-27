import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _paths = [
    '/',
    '/search',
    '/create-post',
    '/notifications',
    '/profile',
  ];

  int _currentIndex = 0;

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.cardDarkBorder : AppColors.grey200,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: isDark ? AppColors.grey900 : Colors.white,
          selectedItemColor: isDark
              ? AppColors.primaryPurple
              : AppColors.primaryDark,
          unselectedItemColor: isDark ? AppColors.grey500 : AppColors.grey400,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l10n.text('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_outlined),
              activeIcon: const Icon(Icons.search_rounded),
              label: l10n.text('search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_box_outlined),
              activeIcon: const Icon(Icons.add_box_rounded),
              label: l10n.text('post'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: const Icon(Icons.favorite_rounded),
              label: l10n.text('notifications'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person_rounded),
              label: l10n.text('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
