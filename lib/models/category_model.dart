class SubCategory {
  final String id;
  final String title;

  SubCategory({required this.id, required this.title});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      title: json['title'],
    );
  }
}

class Category {
  final String categoryId;
  final String categoryTitle;
  final String icon;
  final String description;
  final List<SubCategory> subCategories;

  Category({
    required this.categoryId,
    required this.categoryTitle,
    required this.icon,
    required this.description,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var list = json['subCategories'] as List;
    List<SubCategory> subCatList =
        list.map((i) => SubCategory.fromJson(i)).toList();

    return Category(
      categoryId: json['categoryId'],
      categoryTitle: json['categoryTitle'],
      icon: json['icon'],
      description: json['description'],
      subCategories: subCatList,
    );
  }
}
