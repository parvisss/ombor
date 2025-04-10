class CashFlowModel {
  final String id;
  final String categoryId;
  final String title;
  final String? comment;
  final int isPositive;
  final num amount;
  final String time;
  final int isArchived;

  CashFlowModel({
    required this.id,
    required this.categoryId,
    required this.title,
    this.comment,
    required this.isPositive,
    required this.amount,
    required this.time,
    this.isArchived = 0,
    // Boshlang'ich qiymati 0 (false)
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
      isArchived: map['isArchived'] as int? ?? 0,
      // Agar mavjud bo'lmasa, 0
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
      'time': time,
      'isArchived': isArchived,
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
    int? isArchived,
  }) {
    return CashFlowModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      isPositive: isPositive ?? this.isPositive,
      amount: amount ?? this.amount,
      time: time ?? this.time,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
