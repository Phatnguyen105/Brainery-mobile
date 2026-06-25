import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_content_management_screen.dart';
import '../../features/admin/presentation/admin_course_management_screen.dart';
import '../../features/admin/presentation/admin_lookup_management_screen.dart';
import '../../features/admin/presentation/admin_order_management_screen.dart';
import '../../features/admin/presentation/admin_user_management_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/courses/presentation/course_detail_screen.dart';
import '../../features/courses/presentation/course_list_screen.dart';
import '../../features/learning/presentation/course_player_screen.dart';
import '../../features/main/presentation/main_navigation.dart';
import '../../features/orders/data/order_models.dart';
import '../../features/orders/presentation/order_list_screen.dart';
import '../../features/orders/presentation/payment_screen.dart';
import '../../features/profile/presentation/device_management_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.adminCourses,
        builder: (context, state) => const AdminCourseManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.adminContent,
        builder: (context, state) => const AdminContentManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.adminLookups,
        builder: (context, state) => const AdminLookupManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.adminUsers,
        builder: (context, state) => const AdminUserManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.adminOrders,
        builder: (context, state) => const AdminOrderManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.instructor,
        builder: (context, state) => const MainNavigation(tab: 'instructor'),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const MainNavigation(tab: 'home'),
      ),
      GoRoute(
        path: RouteNames.learning,
        builder: (context, state) => const MainNavigation(tab: 'learning'),
      ),
      GoRoute(
        path: RouteNames.wishlist,
        builder: (context, state) => const MainNavigation(tab: 'wishlist'),
      ),
      GoRoute(
        path: RouteNames.cart,
        builder: (context, state) => const MainNavigation(tab: 'cart'),
      ),
      GoRoute(
        path: RouteNames.orders,
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/payment/:orderId',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is OrderModel) return PaymentScreen(order: extra);
          return const OrderListScreen();
        },
      ),
      GoRoute(
        path: RouteNames.devices,
        builder: (context, state) => const DeviceManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const MainNavigation(tab: 'profile'),
      ),
      GoRoute(
        path: RouteNames.courses,
        builder: (context, state) => CourseListScreen(
          initialCategoryId: state.uri.queryParameters['categoryId'],
        ),
      ),
      GoRoute(
        path: '/courses/:courseId',
        builder: (context, state) =>
            CourseDetailScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/courses/:courseId/learn',
        builder: (context, state) => CoursePlayerScreen(
          courseId: state.pathParameters['courseId']!,
          initialLessonId: state.uri.queryParameters['lessonId'],
        ),
      ),
    ],
  );
});
