class RouteNames {
  const RouteNames._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const learning = '/learning';
  static const wishlist = '/wishlist';
  static const cart = '/cart';
  static const orders = '/orders';
  static const devices = '/devices';
  static const profile = '/profile';
  static const courses = '/courses';
  static const instructor = '/instructor';
  static const admin = '/admin';
  static const adminCourses = '/admin/courses';
  static const adminContent = '/admin/content';
  static const adminLookups = '/admin/lookups';
  static const adminUsers = '/admin/users';
  static const adminOrders = '/admin/orders';

  static String courseDetail(String id) => '/courses/$id';
  static String courseLearn(String id) => '/courses/$id/learn';
  static String payment(String orderId) => '/payment/$orderId';
}
