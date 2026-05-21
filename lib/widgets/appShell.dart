import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ube/view_models/user_view_model.dart';
import 'package:ube/authentication/authentication_page.dart';
import 'package:ube/authentication/auth_service.dart';
import 'package:ube/pages/notification_page.dart';
import 'package:ube/core/utils/route_utils.dart';
import '../pages/dashboard_page.dart';
import '../pages/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _isVisible = true;

  final List<Widget> _pages = const [
    HomePage(),
    NotificationPage(),
    ProfilePage(),
  ];

  void _onNavTap(int index) {
    if (index == 3) {
      _showLogoutDialog();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(onPressed: _logout, child: const Text('Yes')),
        ],
      ),
    );
  }

  void _logout() async {
    Navigator.of(context).pop();

    // Clear user data in ViewModel
    context.read<UserViewModel>().clearUser();

    await AuthService.signOut();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      instantRoute(const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildIcon(IconData icon, int index, {bool isLogout = false}) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 25,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // 🔥 Scroll detector
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isVisible) setState(() => _isVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isVisible) setState(() => _isVisible = true);
          }
          return true;
        },
        child: _pages[_currentIndex],
      ),

      // 🔥 Animated bottom nav
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          offset: _isVisible ? const Offset(0, 0) : const Offset(0, 1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            opacity: _isVisible ? 1 : 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF8B2CF5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIcon(Icons.dashboard_rounded, 0),
                  _buildIcon(Icons.notifications, 1),
                  _buildIcon(Icons.person, 2),
                  _buildIcon(Icons.logout, 3, isLogout: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
