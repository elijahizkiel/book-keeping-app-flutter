import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/core/widgets/app_card.dart';
import 'package:bookkeeping_app/domain/entities/user_preferences.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Theme Selector
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.palette_outlined),
                    SizedBox(width: 12),
                    Text(
                      'Appearance Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                DropdownButton<AppThemePreference>(
                  value: prefs.themePreference,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: AppThemePreference.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: AppThemePreference.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: AppThemePreference.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(preferencesStateProvider.notifier).setTheme(val);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Currency Selector
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.currency_exchange),
                    SizedBox(width: 12),
                    Text(
                      'Currency',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: prefs.currencyCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                    DropdownMenuItem(value: 'ETB', child: Text('ETB (Br)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      final symbols = {
                        'USD': '\$',
                        'EUR': '€',
                        'GBP': '£',
                        'ETB': 'Br',
                      };
                      ref
                          .read(preferencesStateProvider.notifier)
                          .setCurrency(val, symbols[val] ?? val);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Information & Support',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          AppCard(
            onTap: () => context.push('/help'),
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 12),
                    Text(
                      'Help & FAQs',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            onTap: () => context.push('/onboarding'),
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_outlined),
                    SizedBox(width: 12),
                    Text(
                      'Replay Onboarding Guide',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Data Management',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          AppCard(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset All Data?'),
                  content: const Text(
                    'This will clear all transactions, friends, and reset preferences. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(preferencesStateProvider.notifier)
                            .resetAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All data has been reset'),
                            ),
                          );
                        }
                      },
                      child: const Text('Reset Everything'),
                    ),
                  ],
                ),
              );
            },
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Reset All Data',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
