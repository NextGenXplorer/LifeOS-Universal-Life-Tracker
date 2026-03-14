import '../domain/entities/template.dart';

class LifestyleTemplates {
  static final studentTemplate = Template(
    id: 'template_student',
    name: 'Student Life',
    description: 'Track classes, assignments, study habits, and student budget',
    category: TemplateCategory.lifestyle,
    icon: 'school',
    data: {
      'activities': [
        {'name': 'Studying', 'icon': 'book', 'color': 0xFF6C63FF},
        {'name': 'Classes', 'icon': 'school', 'color': 0xFF42A5F5},
        {'name': 'Assignments', 'icon': 'assignment', 'color': 0xFFFFA726},
      ],
      'habits': [
        {'title': 'Study 2 hours', 'frequency': 'daily', 'icon': 'book'},
        {'title': 'Review notes', 'frequency': 'daily', 'icon': 'note'},
        {'title': 'Exercise', 'frequency': 'weekly', 'icon': 'fitness_center'},
      ],
      'expenseCategories': [
        {'name': 'Textbooks', 'budget': 200},
        {'name': 'Food', 'budget': 300},
        {'name': 'Transport', 'budget': 100},
      ],
    },
  );

  static final professionalTemplate = Template(
    id: 'template_professional',
    name: 'Professional',
    description: 'Work tasks, meetings, career goals, and professional development',
    category: TemplateCategory.career,
    icon: 'work',
    data: {
      'activities': [
        {'name': 'Meetings', 'icon': 'people', 'color': 0xFF6C63FF},
        {'name': 'Deep Work', 'icon': 'laptop', 'color': 0xFF00BFA6},
        {'name': 'Emails', 'icon': 'email', 'color': 0xFF42A5F5},
      ],
      'habits': [
        {'title': 'Inbox Zero', 'frequency': 'daily', 'icon': 'email'},
        {'title': 'Read industry news', 'frequency': 'daily', 'icon': 'article'},
        {'title': 'Network', 'frequency': 'weekly', 'icon': 'people'},
      ],
    },
  );

  static final fitnessTemplate = Template(
    id: 'template_fitness',
    name: 'Fitness Journey',
    description: 'Workouts, nutrition tracking, and health goals',
    category: TemplateCategory.health,
    icon: 'fitness_center',
    data: {
      'activities': [
        {'name': 'Gym', 'icon': 'fitness_center', 'color': 0xFF00BFA6},
        {'name': 'Cardio', 'icon': 'directions_run', 'color': 0xFFEF5350},
        {'name': 'Meal Prep', 'icon': 'restaurant', 'color': 0xFFFFA726},
      ],
      'habits': [
        {'title': 'Workout', 'frequency': 'daily', 'icon': 'fitness_center'},
        {'title': 'Drink 8 glasses water', 'frequency': 'daily', 'icon': 'water_drop'},
        {'title': 'Sleep 8 hours', 'frequency': 'daily', 'icon': 'bed'},
      ],
      'goals': [
        {'title': 'Lose 10 lbs', 'target': 10, 'unit': 'lbs'},
        {'title': 'Run 5K', 'target': 5, 'unit': 'km'},
      ],
    },
  );

  static final freelancerTemplate = Template(
    id: 'template_freelancer',
    name: 'Freelancer',
    description: 'Client work, time tracking, invoicing, and project management',
    category: TemplateCategory.career,
    icon: 'laptop_mac',
    data: {
      'activities': [
        {'name': 'Client Work', 'icon': 'work', 'color': 0xFF6C63FF},
        {'name': 'Admin', 'icon': 'folder', 'color': 0xFFFFA726},
        {'name': 'Marketing', 'icon': 'campaign', 'color': 0xFF00BFA6},
      ],
      'habits': [
        {'title': 'Client outreach', 'frequency': 'daily', 'icon': 'email'},
        {'title': 'Track time', 'frequency': 'daily', 'icon': 'timer'},
        {'title': 'Invoice clients', 'frequency': 'weekly', 'icon': 'receipt'},
      ],
    },
  );

  static final minimalistTemplate = Template(
    id: 'template_minimalist',
    name: 'Minimalist',
    description: 'Simple tracking with just essentials',
    category: TemplateCategory.lifestyle,
    icon: 'minimalist',
    data: {
      'habits': [
        {'title': 'Meditate', 'frequency': 'daily', 'icon': 'self_improvement'},
        {'title': 'Journal', 'frequency': 'daily', 'icon': 'edit_note'},
      ],
      'tasks': [
        {'title': 'Review day', 'priority': 'high'},
      ],
    },
  );

  static List<Template> get allTemplates => [
    studentTemplate,
    professionalTemplate,
    fitnessTemplate,
    freelancerTemplate,
    minimalistTemplate,
  ];
}
