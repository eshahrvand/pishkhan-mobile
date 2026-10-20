import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../domain/entities/personal_information.dart';

String occupationLabel(OccupationKind kind) => switch (kind) {
  OccupationKind.designer => S.current.profileDesigner,
  OccupationKind.teacher => S.current.profileTeacher,
  OccupationKind.professor => S.current.profileProfessor,
  OccupationKind.homemaker => S.current.profileHomemaker,
};
String phoneCountdownLabel(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
