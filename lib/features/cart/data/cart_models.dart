import '../../courses/data/course_models.dart';

class CartModel {
  const CartModel({
    required this.id,
    required this.items,
    required this.totalAmount,
  });

  final String? id;
  final List<CourseSummary> items;
  final double totalAmount;

  factory CartModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return CartModel(
      id: map['id']?.toString(),
      items:
          (map['items'] as List<dynamic>?)
              ?.map(CourseSummary.fromJson)
              .toList() ??
          const [],
      totalAmount: double.tryParse(map['totalAmount']?.toString() ?? '') ?? 0,
    );
  }

  static const empty = CartModel(id: null, items: [], totalAmount: 0);
}
