import 'package:flutter_test/flutter_test.dart';
import 'package:blog_agent/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BlogAgentApp());
    // Verify the app renders without crashing
    expect(find.byType(BlogAgentApp), findsOneWidget);
  });
}
