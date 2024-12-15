import '../../data/models/trait_model.dart';

class TraitService {
  static final Map<String, List<TraitModel>> _categoryTraits = {
    'cooking': [
      TraitModel(
        id: 'exp',
        name: 'Experience',
        iconData: '0xe25a',
        value: '10+ years',
        category: 'cooking',
        displayOrder: 0,
      ),
      TraitModel(
        id: 'spec',
        name: 'Specialty',
        iconData: '0xe4c6',
        value: 'Pastry Chef',
        category: 'cooking',
        displayOrder: 1,
      ),
      TraitModel(
        id: 'cert',
        name: 'Certification',
        iconData: '0xe8e8',
        value: 'Culinary Arts',
        category: 'cooking',
        displayOrder: 2,
      ),
    ],
    'diy': [
      TraitModel(
        id: 'exp',
        name: 'Experience',
        iconData: '0xe1b1',
        value: '5+ years',
        category: 'diy',
        displayOrder: 0,
      ),
      TraitModel(
        id: 'spec',
        name: 'Specialty',
        iconData: '0xe3ae',
        value: 'Woodworking',
        category: 'diy',
        displayOrder: 1,
      ),
      TraitModel(
        id: 'tools',
        name: 'Tools',
        iconData: '0xf035b',
        value: 'Power Tools',
        category: 'diy',
        displayOrder: 2,
      ),
    ],
    'fitness': [
      TraitModel(
        id: 'cert',
        name: 'Certification',
        iconData: '0xe8e8',
        value: 'Personal Trainer',
        category: 'fitness',
        displayOrder: 0,
      ),
      TraitModel(
        id: 'spec',
        name: 'Specialty',
        iconData: '0xef4c',
        value: 'HIIT',
        category: 'fitness',
        displayOrder: 1,
      ),
      TraitModel(
        id: 'exp',
        name: 'Experience',
        iconData: '0xe614',
        value: '7+ years',
        category: 'fitness',
        displayOrder: 2,
      ),
    ],
    'programming': [
      TraitModel(
        id: 'lang',
        name: 'Languages',
        iconData: '0xe86f',
        value: 'React, Flutter',
        category: 'programming',
        displayOrder: 0,
      ),
      TraitModel(
        id: 'exp',
        name: 'Experience',
        iconData: '0xe8e8',
        value: '8+ years',
        category: 'programming',
        displayOrder: 1,
      ),
      TraitModel(
        id: 'role',
        name: 'Role',
        iconData: '0xe7fd',
        value: 'Senior Dev',
        category: 'programming',
        displayOrder: 2,
      ),
    ],
  };

  static List<TraitModel> getTraitsForCategory(String category) {
    final traits = _categoryTraits[category.toLowerCase()] ?? getDefaultTraits();
    return List.from(traits)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  static List<TraitModel> getDefaultTraits() {
    return [
      TraitModel(
        id: 'exp',
        name: 'Experience',
        iconData: '0xe8e8',
        value: 'Beginner',
        category: 'general',
        displayOrder: 0,
      ),
      TraitModel(
        id: 'focus',
        name: 'Focus',
        iconData: '0xe7fd',
        value: 'General',
        category: 'general',
        displayOrder: 1,
      ),
    ];
  }

  static List<String> getAvailableCategories() {
    return _categoryTraits.keys.toList();
  }

  static bool isValidCategory(String category) {
    return _categoryTraits.containsKey(category.toLowerCase());
  }
}
