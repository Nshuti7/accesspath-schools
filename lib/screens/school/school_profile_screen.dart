import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/school_provider.dart';
import '../../strings.dart';
import '../../validators.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/district_field.dart';
import '../../widgets/school_type_field.dart';
import '../../widgets/submit_button.dart';

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _district = '';
  String _type = '';
  bool _prefilled = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final saved = await context.read<SchoolProvider>().updateDetails(
      name: _nameController.text.trim(),
      district: _district,
      type: _type,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? AppStrings.schoolSaved : AppStrings.errorSaveSchool,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.schoolProfile)),
      body: DataGate(builder: _buildForm),
    );
  }

  Widget _buildForm(BuildContext context) {
    final school = context.watch<SchoolProvider>().school!;
    // Fill the form once from the loaded school, then leave edits alone.
    if (!_prefilled) {
      _nameController.text = school.name;
      _district = school.district;
      _type = school.type;
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.schoolName,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                DistrictField(
                  initialValue: school.district,
                  onChanged: (value) => _district = value,
                ),
                const SizedBox(height: 16),
                SchoolTypeField(
                  initialValue: school.type,
                  onChanged: (value) => _type = value,
                ),
                const SizedBox(height: 24),
                SubmitButton(
                  label: AppStrings.saveChanges,
                  isBusy: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
