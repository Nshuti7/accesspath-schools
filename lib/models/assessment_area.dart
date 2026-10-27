import 'package:flutter/material.dart';

/// Display details for one of the six assessment areas. The [id] matches the
/// `area` field in checklist.json.
class AssessmentArea {
  const AssessmentArea({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;

  static const all = [
    AssessmentArea(
      id: 'entrances_exits',
      name: 'Entrances and exits',
      icon: Icons.door_front_door_outlined,
    ),
    AssessmentArea(
      id: 'ramps_pathways',
      name: 'Ramps and pathways',
      icon: Icons.accessible_forward,
    ),
    AssessmentArea(
      id: 'classrooms_labs',
      name: 'Classrooms and labs',
      icon: Icons.school_outlined,
    ),
    AssessmentArea(id: 'toilets', name: 'Toilets', icon: Icons.wc),
    AssessmentArea(
      id: 'signage',
      name: 'Signage',
      icon: Icons.signpost_outlined,
    ),
    AssessmentArea(
      id: 'safety',
      name: 'Safety',
      icon: Icons.health_and_safety_outlined,
    ),
  ];

  static AssessmentArea? byId(String id) {
    for (final area in all) {
      if (area.id == id) return area;
    }
    return null;
  }
}
