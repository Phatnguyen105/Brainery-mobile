import '../../../core/network/api_client.dart';
import 'cart_models.dart';

class CartApi {
  const CartApi(this._client);

  final ApiClient _client;

  Future<CartModel> findCart() {
    return _client.getData<CartModel>(
      '/api/me/cart',
      parse: CartModel.fromJson,
    );
  }

  Future<CartModel> addItem(String courseId) {
    return _client.postData<CartModel>(
      '/api/me/cart/items/$courseId',
      parse: CartModel.fromJson,
    );
  }

  Future<CartModel> removeItem(String courseId) {
    return _client.deleteData<CartModel>(
      '/api/me/cart/items/$courseId',
      parse: CartModel.fromJson,
    );
  }
}
