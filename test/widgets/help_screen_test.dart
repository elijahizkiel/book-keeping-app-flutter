import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/features/help/help_view.dart';

void main() {
  testWidgets('HelpView displays FAQs and expands answers', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpView()));

    expect(find.text('Help & FAQs'), findsOneWidget);
    expect(
      find.text('How does debt & credit balance tracking work?'),
      findsOneWidget,
    );
    expect(
      find.text('How do I settle a balance with a friend?'),
      findsOneWidget,
    );
    expect(find.text('Is my financial data stored online?'), findsOneWidget);

    // Tap to expand first FAQ
    await tester.tap(
      find.text('How does debt & credit balance tracking work?'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'When you pay for a friend, select "Owed to me (+)" (Credit). When a friend pays for you, select "I owe (-)" (Debt). The net balance shows whether you are owed money overall or owe money.',
      ),
      findsOneWidget,
    );
  });
}
