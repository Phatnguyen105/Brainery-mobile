import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import 'order_models.dart';

class OrderApi {
  const OrderApi(this._client);

  final ApiClient _client;

  Future<PageResult<OrderModel>> orders() {
    return _client.getData<PageResult<OrderModel>>(
      '/api/me/orders',
      queryParameters: {'size': 50},
      parse: (json) => PageResult.fromJson(json, OrderModel.fromJson),
    );
  }

  Future<PageResult<OrderModel>> adminOrders() {
    return _client.getData<PageResult<OrderModel>>(
      '/api/admin/orders',
      queryParameters: {'size': 50},
      parse: (json) => PageResult.fromJson(json, OrderModel.fromJson),
    );
  }

  Future<OrderModel> checkout() {
    return _client.postData<OrderModel>(
      '/api/me/orders/checkout',
      data: {'paymentMethod': 'PAYOS', 'orderSource': 'Android'},
      parse: OrderModel.fromJson,
    );
  }

  Future<TransactionModel> createTransaction(OrderModel order, String provider) {
    return _client.postData<TransactionModel>(
      '/api/me/payments/${order.id}/transactions',
      data: {
        'provider': provider,
        'amount': order.finalPrice,
        'storePlatform': 'Web',
      },
      parse: TransactionModel.fromJson,
    );
  }

  Future<TransactionModel> confirmSandbox(TransactionModel transaction) {
    return _client.postData<TransactionModel>(
      '/api/payments/webhook/${transaction.provider}',
      data: {
        'event': 'PAYMENT_SUCCESS',
        'transactionId': transaction.id,
        'orderId': transaction.orderId,
        'amount': transaction.amount,
      },
      parse: TransactionModel.fromJson,
    );
  }

  Future<OrderModel> markPaid(String orderId) {
    return _client.patchData<OrderModel>(
      '/api/admin/orders/$orderId/mark-paid',
      parse: OrderModel.fromJson,
    );
  }
}
