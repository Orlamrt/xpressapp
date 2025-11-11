import '../../entities/link_tutor_result.dart';
import '../../repositories/tutor_link_repository.dart';

class LinkTutorWithPatientUseCase {
  const LinkTutorWithPatientUseCase({
    required this.repository,
  });

  final TutorLinkRepository repository;

  Future<LinkTutorResult> call({
    required String patientUuid,
    required String tutorEmail,
  }) {
    return repository.linkTutorWithPatient(
      patientUuid: patientUuid,
      tutorEmail: tutorEmail,
    );
  }
}
