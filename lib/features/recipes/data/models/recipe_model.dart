class Recipe {
  final String id;
  final String title;
  final String ingredients;
  final String steps;
  final String imagePath;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.imagePath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'imagePath': imagePath,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      ingredients: map['ingredients'],
      steps: map['steps'],
      imagePath: map['imagePath'] ?? '',
    );
  }
}
