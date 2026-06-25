import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';

class WishlistApi {
  const WishlistApi(this._client);

  final ApiClient _client;

  Future<List<CourseSummary>> findWishlist() {
    return _client.getData<List<CourseSummary>>(
      '/api/me/wishlist',
      parse: (json) =>
          (json is List ? json : const []).map(CourseSummary.fromJson).toList(),
    );
  }

  Future<void> add(String courseId) {
    return _client.postData<void>('/api/me/wishlist/$courseId', parse: (_) {});
  }

  Future<void> remove(String courseId) {
    return _client.deleteData<void>(
      '/api/me/wishlist/$courseId',
      parse: (_) {},
    );
  }
}
