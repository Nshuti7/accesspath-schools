import 'package:accesspath_schools/models/school.dart';
import 'package:accesspath_schools/models/uganda_districts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('district list is unique, sorted and includes Kampala', () {
    expect(ugandaDistricts.toSet(), hasLength(ugandaDistricts.length));
    expect([...ugandaDistricts]..sort(), ugandaDistricts);
    expect(ugandaDistricts, contains('Kampala'));
  });

  test('school details survive a round trip through the map', () {
    const school = School(
      id: 's1',
      name: 'Kololo Primary',
      createdBy: 'u1',
      district: 'Kampala',
      type: School.typeBoth,
    );
    final copy = School.fromMap('s1', school.toMap());
    expect(copy.district, 'Kampala');
    expect(copy.type, School.typeBoth);
  });

  test('copyWith changes only the given fields', () {
    const school = School(id: 's1', name: 'A', createdBy: 'u1');
    final updated = school.copyWith(district: 'Gulu');
    expect(updated.district, 'Gulu');
    expect(updated.name, 'A');
    expect(updated.createdBy, 'u1');
  });
}
