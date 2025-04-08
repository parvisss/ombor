class CategoryModel {
  String id;
  String title;
  num balance;
  String time;
  int isArchived;

  CategoryModel({
    required this.id,
    required this.title,
    required this.balance,
    required this.time,
    required this.isArchived,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      title: map['title'] as String,
      balance: map['balance'] as num, // ✅ to‘g‘rilandi
      time: map['time'] as String,
      isArchived: map['isArchived'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'balance': balance, 'time': time};
  }

  CategoryModel copyWith({
    String? id,
    String? title,
    num? balance, // ✅ to‘g‘rilandi
    String? time,
    int? isArchived,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      balance: balance ?? this.balance,
      time: time ?? this.time,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
