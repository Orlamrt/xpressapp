import '../../domain/entities/link_tutor_result.dart';
import '../../domain/repositories/tutor_link_repository.dart';
import '../datasources/remote/tutor_link_api_datasource.dart';

class TutorLinkRepositoryImpl implements TutorLinkRepository {
  TutorLinkRepositoryImpl({
    required this.datasource,
  });

  final TutorLinkApiDatasource datasource;

  @override
  Future<LinkTutorResult> linkTutorWithPatient({
    required String patientUuid,
    required String tutorEmail,
  }) async {
    final response = await datasource.linkTutorWithPatient(
      patientUuid: patientUuid,
      tutorEmail: tutorEmail,
    );

    return response.toEntity();
  }
}
