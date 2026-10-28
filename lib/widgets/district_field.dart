import 'package:flutter/material.dart';

import '../models/uganda_districts.dart';
import '../strings.dart';
import '../validators.dart';

/// Searchable district picker. Choosing "Other" shows a text box for a
/// district that is not in the list yet.
class DistrictField extends StatefulWidget {
  const DistrictField({
    super.key,
    this.initialValue = '',
    required this.onChanged,
  });

  final String initialValue;

  /// Called with the district name, or the typed name when "Other" is chosen.
  final ValueChanged<String> onChanged;

  @override
  State<DistrictField> createState() => _DistrictFieldState();
}

class _DistrictFieldState extends State<DistrictField> {
  static const _other = AppStrings.otherDistrict;

  final _otherController = TextEditingController();
  final _searchController = TextEditingController();
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  String? _selection;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (ugandaDistricts.contains(initial)) {
      _selection = initial;
    } else if (initial.isNotEmpty) {
      _selection = _other;
      _otherController.text = initial;
    }
    _searchController.addListener(_matchTypedName);
  }

  @override
  void dispose() {
    _otherController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Typing a full district name counts as choosing it, so people who type
  /// "Kampala" and move on are not told to choose a district.
  void _matchTypedName() {
    final typed = _searchController.text.trim().toLowerCase();
    String? match;
    for (final district in [...ugandaDistricts, _other]) {
      if (district.toLowerCase() == typed) match = district;
    }
    if (match == _selection) return;
    // Editing the text away from the chosen name clears the choice, so the
    // box never shows one district while the form saves another.
    if (match == null && _selection == null) return;
    _select(match);
  }

  void _select(String? value) {
    _fieldKey.currentState?.didChange(value);
    setState(() => _selection = value);
    _report();
  }

  void _report() {
    widget.onChanged(
      _selection == _other ? _otherController.text.trim() : _selection ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormField<String>(
          key: _fieldKey,
          initialValue: _selection,
          validator: (value) =>
              value == null ? AppStrings.errorChooseDistrict : null,
          builder: (state) => DropdownMenu<String>(
            controller: _searchController,
            initialSelection: _selection,
            expandedInsets: EdgeInsets.zero,
            // Typing filters the long list, e.g. "Kab" for Kabale.
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 320,
            label: const Text(AppStrings.district),
            errorText: state.errorText,
            dropdownMenuEntries: [
              for (final district in [...ugandaDistricts, _other])
                DropdownMenuEntry(value: district, label: district),
            ],
            onSelected: _select,
          ),
        ),
        if (_selection == _other) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _otherController,
            decoration: const InputDecoration(
              labelText: AppStrings.districtName,
            ),
            textCapitalization: TextCapitalization.words,
            validator: validateRequired,
            onChanged: (_) => _report(),
          ),
        ],
      ],
    );
  }
}
