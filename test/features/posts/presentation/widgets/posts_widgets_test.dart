import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/features/posts/presentation/widgets/post_card.dart';

void main() {
  group('PostCard Widget', () {
    testWidgets('displays title and author', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(title: 'Test Post', author: 'Test Author'),
          ),
        ),
      );

      expect(find.text('Test Post'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: 'Tap Test',
              author: 'Author',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PostCard));
      expect(tapped, isTrue);
    });

    testWidgets('displays tags list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: 'Tagged Post',
              author: 'Author',
              tag: ['Flutter', 'Dart'],
            ),
          ),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });
  });
}
