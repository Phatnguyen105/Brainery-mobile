import '../../features/auth/data/auth_models.dart';
import 'route_names.dart';

String routeForUser(UserModel user) {
  if (user.isAdmin) return RouteNames.admin;
  if (user.isInstructor) return RouteNames.instructor;
  return RouteNames.home;
}
