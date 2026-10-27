import 'package:flutter/material.dart';

import '../../strings.dart';

/// A form field that opens a date picker, so the due date is validated with
/// the rest of the form.
class DueDateField extends FormField<DateTime> {
  DueDateField({super.key, required ValueChanged<DateTime> onChanged})
    : super(
        validator: (value) => value == null ? AppStrings.errorChooseDate : null,
        builder: (state) {
          final context = state.context;
          final value = state.value;

          Future<void> pick() async {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? today,
              firstDate: today,
              lastDate: DateTime(now.year + 2, now.month, now.day),
              helpText: AppStrings.dueDate,
            );
            if (picked == null) return;
            state.didChange(picked);
            onChanged(picked);
          }

          return InkWell(
            onTap: pick,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: AppStrings.dueDate,
                errorText: state.errorText,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              isEmpty: value == null,
              child: Text(
                value == null
                    ? AppStrings.chooseDate
                    : AppStrings.formatDate(value),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        },
      );
}
