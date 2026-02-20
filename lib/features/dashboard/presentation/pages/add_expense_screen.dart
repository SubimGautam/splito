import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/add_expense_view_model.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String groupId;
  final List<String> members;

  const AddExpenseScreen({super.key, required this.groupId, required this.members});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  late List<TextEditingController> _paymentControllers;
  late List<TextEditingController> _splitControllers;

  @override
  void initState() {
    super.initState();
    _paymentControllers = List.generate(widget.members.length, (i) => TextEditingController());
    _splitControllers = List.generate(widget.members.length, (i) => TextEditingController());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (var c in _paymentControllers) c.dispose();
    for (var c in _splitControllers) c.dispose();
    super.dispose();
  }

  void _autoCalculateSplits() {
    final total = double.tryParse(_amountController.text) ?? 0;
    if (total <= 0) return;
    final equalShare = total / widget.members.length;
    for (int i = 0; i < widget.members.length; i++) {
      _splitControllers[i].text = equalShare.toStringAsFixed(2);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final total = double.parse(_amountController.text);
    final payments = <Map<String, dynamic>>[];
    final splits = <Map<String, dynamic>>[];

    for (int i = 0; i < widget.members.length; i++) {
      final paid = double.tryParse(_paymentControllers[i].text) ?? 0;
      if (paid > 0) payments.add({'name': widget.members[i], 'amount': paid});
      final owes = double.tryParse(_splitControllers[i].text) ?? 0;
      if (owes > 0) splits.add({'name': widget.members[i], 'amount': owes});
    }

    final totalPayments = payments.fold(0.0, (s, p) => s + p['amount']);
    if ((totalPayments - total).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payments total $totalPayments must equal $total')));
      return;
    }

    final totalSplits = splits.fold(0.0, (s, sp) => s + sp['amount']);
    if ((totalSplits - total).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Splits total $totalSplits must equal $total')));
      return;
    }

    final notifier = ref.read(addExpenseViewModelProvider.notifier);
    await notifier.createExpense(
      description: _descriptionController.text,
      totalAmount: total,
      payments: payments,
      splits: splits,
      groupId: widget.groupId,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addExpenseViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
              onChanged: (_) => _autoCalculateSplits(),
            ),
            const SizedBox(height: 20),
            const Text('💰 Who paid how much?', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(widget.members.length, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 100, child: Text(widget.members[i])),
                  Expanded(
                    child: TextFormField(
                      controller: _paymentControllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Amount paid', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            const Text('💸 Who owes how much?', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(widget.members.length, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 100, child: Text(widget.members[i])),
                  Expanded(
                    child: TextFormField(
                      controller: _splitControllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Amount owed', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(onPressed: _submit, child: const Text('Add Expense')),
          ],
        ),
      ),
    );
  }
}