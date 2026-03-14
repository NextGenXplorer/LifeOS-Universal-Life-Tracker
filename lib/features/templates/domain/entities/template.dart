enum TemplateCategory { lifestyle, health, career, finance, productivity }

class Template {
  final String id;
  final String name;
  final String description;
  final TemplateCategory category;
  final String icon;
  final Map<String, dynamic> data;
  final bool isBuiltin;
  final DateTime? createdAt;

  const Template({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.data,
    this.isBuiltin = false,
    this.createdAt,
  });
}
