import 'package:flutter/material.dart';

import '../models/school.dart';
import '../strings.dart';

class SchoolTypeField extends StatelessWidget {
  const SchoolTypeField({
    super.key,
    this.initialValue = '',
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: School.types.contains(initialValue) ? initialValue : null,
      decoration: const InputDecoration(labelText: AppStrings.schoolType),
      items: [
        for (final type in School.types)
          DropdownMenuItem(
            value: type,
            child: Text(AppStrings.schoolTypeLabel(type)),
          ),
      ],
      validator: (value) =>
          value == null ? AppStrings.errorChooseSchoolType : null,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
