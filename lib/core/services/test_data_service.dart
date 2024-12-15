import '../../data/models/post_model.dart';
import '../../data/models/rating_model.dart';
import 'trait_service.dart';
import 'dart:math';

class TestDataService {
  static final Random _random = Random();

  static const String _longText = '''
Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications from a single codebase for any web browser, Fuchsia, Android, iOS, Linux, macOS, and Windows.

Key Features of Flutter:

1. Hot Reload
Flutter's hot reload feature helps you quickly and easily experiment, build UIs, add features, and fix bugs. Hot reload works by injecting updated source code files into the running Dart Virtual Machine (VM).

2. Widget-Based
Everything in Flutter is a widget. Widgets are the basic building blocks of a Flutter app's user interface. Each widget is an immutable declaration of part of the user interface.

3. Cross-Platform Development
With Flutter, you can create beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. This means you can write your code once and deploy it across multiple platforms.

4. Performance
Flutter's widgets incorporate all critical platform differences such as scrolling, navigation, icons, and fonts to provide full native performance on both iOS and Android.

5. Customizable
Flutter provides a rich set of customizable widgets that you can modify according to your needs. You can create your own custom widgets or modify existing ones.

Best Practices for Flutter Development:

1. Code Organization
- Keep your code organized using proper folder structure
- Follow consistent naming conventions
- Use separate files for different widgets
- Implement proper state management

2. Performance Optimization
- Minimize unnecessary widget rebuilds
- Use const constructors when possible
- Implement proper list view optimization
- Handle memory leaks properly

3. Error Handling
- Implement proper error handling mechanisms
- Use try-catch blocks appropriately
- Handle null safety properly
- Implement proper error reporting

4. Testing
- Write unit tests for business logic
- Implement widget tests for UI components
- Perform integration testing
- Use proper mocking when needed

5. State Management
- Choose appropriate state management solution
- Keep state management consistent
- Avoid unnecessary state updates
- Implement proper data flow

6. Asset Management
- Optimize image assets
- Use proper asset organization
- Implement proper asset caching
- Handle different screen sizes

7. Platform-Specific Code
- Handle platform differences properly
- Implement platform-specific features correctly
- Use conditional imports when needed
- Handle platform-specific permissions

8. Documentation
- Write clear and concise documentation
- Document complex logic properly
- Use proper commenting style
- Keep documentation up-to-date

9. Dependency Management
- Keep dependencies up-to-date
- Avoid unnecessary dependencies
- Handle dependency conflicts properly
- Use proper version constraints

10. Security
- Implement proper security measures
- Handle sensitive data properly
- Use secure communication channels
- Implement proper authentication

This comprehensive guide should help you understand the basics of Flutter development and follow best practices in your projects. Remember to keep learning and staying updated with the latest Flutter developments and improvements.
''';

  static List<PostModel> generateTestPosts({int count = 10}) {
    return List.generate(count, (index) {
      final id = 'post_$index';
      final userId = index % 3 == 0 ? 'user_1' : 'user_${2 + (index % 3)}';
      final username =
          userId == 'user_1' ? 'Test User' : 'User ${2 + (index % 3)}';

      final ratings = List.generate(
        3,
        (rIndex) => RatingModel(
          value: 3.0 + (rIndex % 3),
          userId: 'user_${rIndex + 2}',
          createdAt: DateTime.now().subtract(Duration(days: rIndex)),
        ),
      );

      final category = switch (index % 4) {
        0 => 'cooking',
        1 => 'diy',
        2 => 'fitness',
        3 => 'programming',
        _ => 'general',
      };
      final traits = TraitService.getTraitsForCategory(category);

      return PostModel(
        id: id,
        userId: userId,
        username: username,
        userProfileImage: 'https://i.pravatar.cc/150?u=$userId',
        title: 'Test Post $index',
        description: 'Test description for post $index',
        steps: generateTestSteps(count: 5 + _random.nextInt(3)), // 5-7 steps
        createdAt: DateTime.now().subtract(Duration(days: index)),
        likes: List.generate(index, (i) => 'user_${2 + (i % 3)}'),
        comments: List.generate(index ~/ 2, (i) => 'comment_$i'),
        status: PostStatus.active,
        ratings: ratings,
        userTraits: traits,
        updatedAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static PostModel generateLongTestPost() {
    const userId = 'user_1';
    final ratings = List.generate(
      3,
      (rIndex) => RatingModel(
        value: 4.0 + (rIndex % 2),
        userId: 'user_${rIndex + 2}',
        createdAt: DateTime.now().subtract(Duration(days: rIndex)),
      ),
    );

    final traits = TraitService.getTraitsForCategory('programming');

    return PostModel(
      id: 'long_test_post',
      userId: userId,
      username: 'Test User',
      userProfileImage: 'https://i.pravatar.cc/150?u=$userId',
      title: 'Complete Programming Tutorial',
      description: 'A comprehensive guide with 20 detailed steps',
      steps: generateDetailedSteps(),
      createdAt: DateTime.now(),
      likes: List.generate(10, (i) => 'user_${2 + (i % 3)}'),
      comments: List.generate(5, (i) => 'comment_$i'),
      status: PostStatus.active,
      ratings: ratings,
      userTraits: traits,
      updatedAt: DateTime.now(),
    );
  }

  static List<PostStep> generateDetailedSteps() {
    final steps = <PostStep>[];

    // Long text introduction
    steps.add(PostStep(
      id: 'step_1',
      type: StepType.text,
      title: 'Introduction',
      description: 'Getting started with programming',
      content: {
        'text': _longText,
      },
    ));

    // Code example
    steps.add(PostStep(
      id: 'step_2',
      type: StepType.code,
      title: 'Your First Program',
      description: 'Writing Hello World',
      content: {
        'code': '''void main() {
  print("Hello, World!");
}''',
        'language': 'dart',
      },
    ));

    // Image with explanation
    steps.add(PostStep(
      id: 'step_3',
      type: StepType.image,
      title: 'Visual Concept',
      description: 'Understanding the flow',
      content: {
        'imageUrl': 'https://picsum.photos/500/300?random=3',
        'caption': 'Program flow diagram',
      },
    ));

    // Document reference
    steps.add(PostStep(
      id: 'step_4',
      type: StepType.document,
      title: 'Documentation',
      description: 'Essential reading material',
      content: {
        'documentUrl': 'https://example.com/docs/intro.pdf',
        'summary': 'Introduction to programming concepts',
      },
    ));

    // More code
    steps.add(PostStep(
      id: 'step_5',
      type: StepType.code,
      title: 'Variables and Types',
      description: 'Understanding data types',
      content: {
        'code': '''var name = "John";
int age = 30;
double height = 1.75;
bool isStudent = true;''',
        'language': 'dart',
      },
    ));

    // Link to resources
    steps.add(PostStep(
      id: 'step_6',
      type: StepType.link,
      title: 'Additional Resources',
      description: 'Helpful learning materials',
      content: {
        'url': 'https://example.com/resources',
        'description': 'Curated list of programming resources',
      },
    ));

    // Quiz to test knowledge
    steps.add(PostStep(
      id: 'step_7',
      type: StepType.quiz,
      title: 'Knowledge Check',
      description: 'Test your understanding',
      content: {
        'question': 'What is the output of print("Hello" + " World")?',
        'options': [
          'Hello World',
          'HelloWorld',
          'Error',
          'None of the above',
        ],
      },
    ));

    // Video tutorial
    steps.add(PostStep(
      id: 'step_8',
      type: StepType.video,
      title: 'Video Explanation',
      description: 'Visual guide to concepts',
      content: {
        'videoUrl': 'https://example.com/tutorial.mp4',
        'description': 'Detailed walkthrough of programming concepts',
      },
    ));

    // More code examples
    steps.add(PostStep(
      id: 'step_9',
      type: StepType.code,
      title: 'Functions',
      description: 'Writing reusable code',
      content: {
        'code': '''int add(int a, int b) {
  return a + b;
}

void main() {
  print(add(5, 3));  // Outputs: 8
}''',
        'language': 'dart',
      },
    ));

    // Text explanation
    steps.add(PostStep(
      id: 'step_10',
      type: StepType.text,
      title: 'Best Practices',
      description: 'Writing clean code',
      content: {
        'text': _longText,
      },
    ));

    // Another code example
    steps.add(PostStep(
      id: 'step_11',
      type: StepType.code,
      title: 'Classes',
      description: 'Object-oriented programming',
      content: {
        'code': '''class Person {
  String name;
  int age;
  
  Person(this.name, this.age);
  
  void sayHello() {
    print("Hello, I'm \$name");
  }
}''',
        'language': 'dart',
      },
    ));

    // Image diagram
    steps.add(PostStep(
      id: 'step_12',
      type: StepType.image,
      title: 'Class Diagram',
      description: 'Visual representation of classes',
      content: {
        'imageUrl': 'https://picsum.photos/500/300?random=12',
        'caption': 'UML class diagram example',
      },
    ));

    // Practice exercise
    steps.add(PostStep(
      id: 'step_13',
      type: StepType.text,
      title: 'Practice Exercise',
      description: 'Try it yourself',
      content: {
        'text': _longText,
      },
    ));

    // Solution
    steps.add(PostStep(
      id: 'step_14',
      type: StepType.code,
      title: 'Exercise Solution',
      description: 'Sample solution',
      content: {
        'code': '''class Car {
  String brand;
  String model;
  int year;
  
  Car(this.brand, this.model, this.year);
  
  void displayDetails() {
    print("\$year \$brand \$model");
  }
}''',
        'language': 'dart',
      },
    ));

    // Quiz
    steps.add(PostStep(
      id: 'step_15',
      type: StepType.quiz,
      title: 'Class Quiz',
      description: 'Test your OOP knowledge',
      content: {
        'question': 'What is encapsulation?',
        'options': [
          'Bundling data and methods that work on that data within a single unit',
          'Creating multiple copies of an object',
          'Converting one type to another',
          'Connecting two classes together',
        ],
      },
    ));

    // Documentation
    steps.add(PostStep(
      id: 'step_16',
      type: StepType.document,
      title: 'Further Reading',
      description: 'Advanced topics',
      content: {
        'documentUrl': 'https://example.com/docs/advanced.pdf',
        'summary': 'Detailed guide to advanced programming concepts',
      },
    ));

    // Link collection
    steps.add(PostStep(
      id: 'step_17',
      type: StepType.link,
      title: 'External Resources',
      description: 'Additional learning materials',
      content: {
        'url': 'https://example.com/advanced-resources',
        'description':
            'Collection of advanced programming tutorials and articles',
      },
    ));

    // Final code example
    steps.add(PostStep(
      id: 'step_18',
      type: StepType.code,
      title: 'Complete Example',
      description: 'Putting it all together',
      content: {
        'code': '''void main() {
  var car = Car("Toyota", "Corolla", 2023);
  car.displayDetails();
  
  var person = Person("Alice", 25);
  person.sayHello();
}''',
        'language': 'dart',
      },
    ));

    // Summary text
    steps.add(PostStep(
      id: 'step_19',
      type: StepType.text,
      title: 'Summary',
      description: 'Review of key concepts',
      content: {
        'text': _longText,
      },
    ));

    // Final quiz
    steps.add(PostStep(
      id: 'step_20',
      type: StepType.quiz,
      title: 'Final Assessment',
      description: 'Test your overall understanding',
      content: {
        'question':
            'Which of these is a pillar of Object-Oriented Programming?',
        'options': [
          'Inheritance',
          'Documentation',
          'Compilation',
          'Debugging',
        ],
      },
    ));

    return steps;
  }

  static List<PostStep> generateTestSteps({int count = 3}) {
    // Define all possible step types
    final allStepTypes = StepType.values.toList();

    // Shuffle the step types to get random order
    allStepTypes.shuffle(_random);

    // Generate steps with different types
    return List.generate(
      count,
      (index) {
        // Use modulo to cycle through shuffled types
        final stepType = allStepTypes[index % allStepTypes.length];

        // Generate content based on step type
        final content = <String, dynamic>{};
        final stepNumber = index + 1;

        switch (stepType) {
          case StepType.text:
            content['text'] = index % 3 == 0 ? _longText : 
                'This is step $stepNumber with text content explaining the process.';
            break;
          case StepType.image:
            content['imageUrl'] =
                'https://picsum.photos/500/300?random=step_$index';
            content['caption'] = 'Image caption for step $stepNumber';
            break;
          case StepType.code:
            content['code'] = '''
void main() {
  print("Hello from step $stepNumber!");
}''';
            content['language'] = 'dart';
            break;
          case StepType.video:
            content['videoUrl'] = 'https://example.com/video$index.mp4';
            content['description'] = 'Video description for step $stepNumber';
            break;
          case StepType.audio:
            content['audioUrl'] = 'https://example.com/audio$index.mp3';
            content['description'] = 'Audio description for step $stepNumber';
            break;
          case StepType.quiz:
            content['question'] = 'What is the purpose of step $stepNumber?';
            content['options'] = [
              'Option A for step $stepNumber',
              'Option B for step $stepNumber',
              'Option C for step $stepNumber',
              'Option D for step $stepNumber'
            ];
            break;
          case StepType.ar:
            content['arModel'] = 'model$index.glb';
            content['instructions'] = 'AR instructions for step $stepNumber';
            break;
          case StepType.vr:
            content['vrScene'] = 'scene$index.gltf';
            content['instructions'] = 'VR instructions for step $stepNumber';
            break;
          case StepType.document:
            content['documentUrl'] = 'https://example.com/doc$index.pdf';
            content['summary'] = 'Document summary for step $stepNumber';
            break;
          case StepType.link:
            content['url'] = 'https://example.com/resource$index';
            content['description'] = 'External resource for step $stepNumber';
            break;
        }

        return PostStep(
          id: 'step_$index',
          title: 'Step $stepNumber',
          description: 'This is step $stepNumber',
          type: stepType,
          content: content,
        );
      },
    );
  }

  static Map<String, dynamic> generateTestAnalytics() {
    return {
      'totalViews': 1000,
      'totalLikes': 500,
      'totalComments': 250,
      'averageRating': 4.5,
      'totalPosts': 25,
      'topCategories': [
        {'name': 'cooking', 'count': 10},
        {'name': 'fitness', 'count': 8},
        {'name': 'diy', 'count': 7},
      ],
      'engagement': {
        'daily': 85,
        'weekly': 450,
        'monthly': 1800,
      },
      'userGrowth': {
        'followers': 300,
        'following': 250,
      },
    };
  }
}
