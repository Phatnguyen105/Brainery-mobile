import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';

class AdminLookupApi {
  const AdminLookupApi(this._client);

  final ApiClient _client;

  Future<List<CategoryModel>> categories() {
    return _client.getData<List<CategoryModel>>(
      '/api/admin/categories',
      parse: (json) => _readList(json).map(CategoryModel.fromJson).toList(),
    );
  }

  Future<List<TagModel>> tags() {
    return _client.getData<List<TagModel>>(
      '/api/admin/tags',
      parse: (json) => _readList(json).map(TagModel.fromJson).toList(),
    );
  }

  Future<CategoryModel> createCategory(String name, String slug) {
    return _client.postData<CategoryModel>(
      '/api/admin/categories',
      data: {'name': name, 'slug': slug},
      parse: CategoryModel.fromJson,
    );
  }

  Future<CategoryModel> updateCategory(String id, String name, String slug) {
    return _client.putData<CategoryModel>(
      '/api/admin/categories/$id',
      data: {'name': name, 'slug': slug},
      parse: CategoryModel.fromJson,
    );
  }

  Future<void> deleteCategory(String id) async {
    await _client.deleteData<Object?>(
      '/api/admin/categories/$id',
      parse: (_) => null,
    );
  }

  Future<TagModel> createTag(String name, String slug) {
    return _client.postData<TagModel>(
      '/api/admin/tags',
      data: {'name': name, 'slug': slug},
      parse: TagModel.fromJson,
    );
  }

  Future<TagModel> updateTag(String id, String name, String slug) {
    return _client.putData<TagModel>(
      '/api/admin/tags/$id',
      data: {'name': name, 'slug': slug},
      parse: TagModel.fromJson,
    );
  }

  Future<void> deleteTag(String id) async {
    await _client.deleteData<Object?>(
      '/api/admin/tags/$id',
      parse: (_) => null,
    );
  }

  List<Object?> _readList(Object? value) {
    if (value is List) return value;
    return const [];
  }
}
