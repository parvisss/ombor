class CashFlowModel {
  final String id;
  final String categoryId;
  final String title;
  final String? comment;
  final int isPositive;
  final num amount;
  final String time;

  CashFlowModel({
    required this.id,
    required this.categoryId,
    required this.title,
    this.comment,
    required this.isPositive,
    required this.amount,
    required this.time,
  });

  factory CashFlowModel.fromMap(Map<String, dynamic> map) {
    return CashFlowModel(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      title: map['title'] as String,
      comment: map['comment'] as String?,
      isPositive: map['isPositive'] as int,
      amount: map['amount'] as num,
      time: map['time'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'comment': comment,
      'isPositive': isPositive,
      'amount': amount,
      'time':time,
    };
  }

  CashFlowModel copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? comment,
    int? isPositive,
    num? amount,
    String? time,
  }) {
    return CashFlowModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      isPositive: isPositive ?? this.isPositive,
      amount: amount ?? this.amount,
      time: time??this.time,
    );
  }
}
