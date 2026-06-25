import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../instructor/presentation/instructor_dashboard_screen.dart';
import '../../learning/presentation/my_learning_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../wishlist/presentation/wishlist_screen.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({required this.tab, super.key});

  final String tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isAdmin = auth.hasValue && (auth.requireValue?.isAdmin ?? false);
    final isInstructor =
        auth.hasValue && (auth.requireValue?.isInstructor ?? false);
    final index = _indexFromTab(
      tab,
      isAdmin: isAdmin,
      isInstructor: isInstructor,
    );
    final children = <Widget>[
      const HomeScreen(),
      const MyLearningScreen(),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
      if (isInstructor) const InstructorDashboardScreen(),
      if (isAdmin) const SizedBox.shrink(),
    ];
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Trang chu',
      ),
      const NavigationDestination(
        icon: Icon(Icons.school_outlined),
        label: 'Hoc tap',
      ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_outline),
        label: 'Yeu thich',
      ),
      const NavigationDestination(
        icon: Icon(Icons.shopping_cart_outlined),
        label: 'Gio hang',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        label: 'Ca nhan',
      ),
      if (isInstructor)
        const NavigationDestination(
          icon: Icon(Icons.co_present_outlined),
          label: 'Giang vien',
        ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          label: 'Quan tri',
        ),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: children),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (next) => context.go(
          _routeFromIndex(next, isAdmin: isAdmin, isInstructor: isInstructor),
        ),
        destinations: destinations,
      ),
    );
  }

  int _indexFromTab(
    String tab, {
    required bool isAdmin,
    required bool isInstructor,
  }) {
    return switch (tab) {
      'learning' => 1,
      'wishlist' => 2,
      'cart' => 3,
      'profile' => 4,
      'instructor' when isInstructor => 5,
      'admin' when isAdmin && isInstructor => 6,
      'admin' when isAdmin => 5,
      _ => 0,
    };
  }

  String _routeFromIndex(
    int index, {
    required bool isAdmin,
    required bool isInstructor,
  }) {
    if (index == 1) return RouteNames.learning;
    if (index == 2) return RouteNames.wishlist;
    if (index == 3) return RouteNames.cart;
    if (index == 4) return RouteNames.profile;
    if (index == 5 && isInstructor) return RouteNames.instructor;
    if (index == 5 && isAdmin) return RouteNames.admin;
    if (index == 6 && isAdmin) return RouteNames.admin;
    return RouteNames.home;
  }
}
