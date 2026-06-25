class ApiConstants {
  const ApiConstants._();

  static const authLogin = '/api/auth/login';
  static const authRegister = '/api/auth/register';
  static const authRefresh = '/api/auth/refresh';
  static const authLogout = '/api/auth/logout';
  static const me = '/api/me';

  static const courses = '/api/courses';
  static const featuredCourses = '/api/courses/featured';
  static const categories = '/api/categories';
  static String courseDetail(String id) => '/api/courses/$id';
}
