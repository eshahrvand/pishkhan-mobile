import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../domain/entities/personal_information.dart';

String jobInformationLabel(JobInformationKind kind) => switch (kind) {
  JobInformationKind.designer => S.current.profileDesigner,
  JobInformationKind.teacher => S.current.profileTeacher,
  JobInformationKind.professor => S.current.profileProfessor,
  JobInformationKind.homemaker => S.current.profileHomemaker,
};
String phoneCountdownLabel(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
