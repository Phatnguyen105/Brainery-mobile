class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalPrice,
    this.userEmail,
    this.createdAt,
  });

  final String id;
  final String? userEmail;
  final String status;
  final double totalAmount;
  final double discountAmount;
  final double finalPrice;
  final DateTime? createdAt;

  factory OrderModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return OrderModel(
      id: map['id']?.toString() ?? '',
      userEmail: map['userEmail']?.toString(),
      status: map['status']?.toString() ?? 'Pending',
      totalAmount: double.tryParse(map['totalAmount']?.toString() ?? '') ?? 0,
      discountAmount:
          double.tryParse(map['discountAmount']?.toString() ?? '') ?? 0,
      finalPrice: double.tryParse(map['finalPrice']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.amount,
    required this.status,
    this.transactionCode,
    this.checkoutUrl,
    this.qrCode,
    this.createdAt,
  });

  final String id;
  final String orderId;
  final String provider;
  final double amount;
  final String status;
  final String? transactionCode;
  final String? checkoutUrl;
  final String? qrCode;
  final DateTime? createdAt;

  bool get isSuccess => status.toLowerCase() == 'success';

  factory TransactionModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      provider: map['provider']?.toString() ?? 'payos-sandbox',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0,
      status: map['status']?.toString() ?? 'Pending',
      transactionCode: map['transactionCode']?.toString(),
      checkoutUrl: map['checkoutUrl']?.toString(),
      qrCode: map['qrCode']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
    );
  }
}
