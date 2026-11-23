import 'package:flutter/material.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How does debt & credit balance tracking work?',
      'a': 'When you pay for a friend, select "Owed to me (+)" (Credit). When a friend pays for you, select "I owe (-)" (Debt). The net balance shows whether you are owed money overall or owe money.',
    },
    {
      'q': 'How do I settle a balance with a friend?',
      'a': 'You can settle individual transactions by opening the transaction and tapping "Mark as Settled". Or open the friend\'s profile and tap "Settle All" to clear the entire running balance.',
    },
    {
      'q': 'Is my financial data stored online?',
      'a': 'No. BookKeeping is strictly offline-first. All your records, transactions, and friend balances are stored locally and privately on your device.',
    },
    {
      'q': 'How do I change currency symbol?',
      'a': 'Go to Settings > Currency and choose between USD (\$), EUR (€), GBP (£), or ETB (Br). All summaries will automatically update.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _faqs[index];
          return Card(
            child: ExpansionTile(
              title: Text(
                item['q']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item['a']!,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
