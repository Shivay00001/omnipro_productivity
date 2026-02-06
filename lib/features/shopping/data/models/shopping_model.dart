class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final bool isCompleted;

  ShoppingItem({
    required this.id,
    required this.name,
    this.category = 'General',
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
