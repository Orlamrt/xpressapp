import '../../domain/entities/link_tutor_result.dart';

class LinkTutorResponseModel {
  const LinkTutorResponseModel({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  LinkTutorResult toEntity() {
    return LinkTutorResult(success: success, message: message);
  }
}
