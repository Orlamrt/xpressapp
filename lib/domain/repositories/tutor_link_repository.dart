import '../entities/link_tutor_result.dart';

abstract class TutorLinkRepository {
  Future<LinkTutorResult> linkTutorWithPatient({
    required String patientUuid,
    required String tutorEmail,
  });
}
