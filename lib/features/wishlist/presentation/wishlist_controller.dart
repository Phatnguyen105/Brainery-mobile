import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import '../data/wishlist_api.dart';

final wishlistApiProvider = Provider<WishlistApi>((ref) {
  return WishlistApi(ref.watch(apiClientProvider));
});

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, List<CourseSummary>>(
      WishlistController.new,
    );

class WishlistController extends AsyncNotifier<List<CourseSummary>> {
  @override
  Future<List<CourseSummary>> build() async {
    return ref.read(wishlistApiProvider).findWishlist();
  }

  Future<void> add(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(wishlistApiProvider).add(courseId);
      return ref.read(wishlistApiProvider).findWishlist();
    });
  }

  Future<void> remove(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(wishlistApiProvider).remove(courseId);
      return ref.read(wishlistApiProvider).findWishlist();
    });
  }
}
