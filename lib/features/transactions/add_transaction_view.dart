import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';
import 'package:bookkeeping_app/core/utils/money.dart';
import 'package:bookkeeping_app/core/utils/validators.dart';
import 'package:bookkeeping_app/core/widgets/app_button.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';

class AddTransactionView extends ConsumerStatefulWidget {
  final String? initialFriendId;

  const AddTransactionView({super.key, this.initialFriendId});

  @override
  ConsumerState<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends ConsumerState<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedFriendId;
  TransactionDirection _direction = TransactionDirection.owedToUser;
  String _category = 'Food & Drinks';
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Food & Drinks',
    'Shopping',
    'Entertainment',
    'Travel',
    'Bills & Utilities',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFriendId = widget.initialFriendId;
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFriendId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a friend')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final money = Money.parse(_amountController.text);
      final newTx = Transaction(
        id: const Uuid().v4(),
        friendId: _selectedFriendId!,
        description: _descController.text.trim(),
        amountMinor: money.minorUnits,
        direction: _direction,
        category: _category,
        date: _date,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(transactionsListProvider.notifier).addTransaction(newTx);
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Direction Selector Segmented Buttons
              SegmentedButton<TransactionDirection>(
                segments: const [
                  ButtonSegment(
                    value: TransactionDirection.owedToUser,
                    label: Text(
                      'Owed to me (+)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    icon: Icon(Icons.arrow_upward, color: AppColors.credit),
                  ),
                  ButtonSegment(
                    value: TransactionDirection.owes,
                    label: Text(
                      'I owe (-)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    icon: Icon(Icons.arrow_downward, color: AppColors.debt),
                  ),
                ],
                selected: {_direction},
                onSelectionChanged: (set) =>
                    setState(() => _direction = set.first),
              ),
              const SizedBox(height: 20),

              // Friend Dropdown
              friendsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading friends: $e'),
                data: (friends) {
                  if (_selectedFriendId == null && friends.isNotEmpty) {
                    _selectedFriendId = friends.first.id;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedFriendId,
                    decoration: const InputDecoration(
                      labelText: 'Friend',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: friends
                        .map(
                          (f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedFriendId = val),
                    validator: (val) =>
                        val == null ? 'Please select a friend' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                  hintText: 'e.g. Dinner, Movie, Uber',
                ),
                validator: Validators.validateDescription,
              ),
              const SizedBox(height: 16),

              // Category Field
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Optional Notes',
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              AppButton(
                label: 'Save Transaction',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
