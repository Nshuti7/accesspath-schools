import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/gap.dart';
import '../../providers/action_provider.dart';
import '../../providers/assessment_provider.dart';
import '../auth/auth_validators.dart';
import '../../strings.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/submit_button.dart';
import 'due_date_field.dart';

class AssignActionScreen extends StatefulWidget {
  const AssignActionScreen({super.key, required this.gapId});

  final String gapId;

  @override
  State<AssignActionScreen> createState() => _AssignActionScreenState();
}

class _AssignActionScreenState extends State<AssignActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate;
  bool _isSaving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save(Gap gap) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final saved = await context.read<ActionProvider>().addAction(
      gap: gap,
      title: _titleController.text.trim(),
      ownerName: _ownerController.text.trim(),
      dueDate: _dueDate!,
      notes: _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (saved) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.actionSaved)),
      );
      context.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.errorSaveAction)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.assignAction)),
      body: DataGate(
        builder: (context) => _buildBody(context.watch<AssessmentProvider>()),
      ),
    );
  }

  Widget _buildBody(AssessmentProvider assessment) {
    final gap = assessment.gapById(widget.gapId);
    if (gap == null) {
      return const Center(child: Text(AppStrings.gapNotFound));
    }

    // Pre-fill once, after the gap has loaded, without overwriting edits.
    if (!_prefilled) {
      _titleController.text = gap.title;
      _prefilled = true;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.actionTitle,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.ownerName,
                    hintText: AppStrings.ownerHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                DueDateField(onChanged: (date) => _dueDate = date),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.notesOptional,
                  ),
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                SubmitButton(
                  label: AppStrings.saveAction,
                  isBusy: _isSaving,
                  onPressed: () => _save(gap),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
