import 'package:get/get.dart';
import '../../data/datasources/local/local_asset_storage.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/marketplace_api_datasource.dart';
import '../../data/datasources/remote/api_auth_datasource.dart';
import '../../data/datasources/remote/firebase_storage_datasource.dart';
import '../../data/datasources/remote/firestore_datasource.dart'; // 🆕 ADD
import '../../data/datasources/remote/media_api_datasource.dart';
import '../../data/datasources/remote/tutor_link_api_datasource.dart';
import '../../data/datasources/local/audio_package_manager.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/phrase_repository_impl.dart'; // 🆕 ADD
import '../../data/repositories/tutor_link_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/phrase_repository.dart'; // 🆕 ADD
import '../../domain/repositories/tutor_link_repository.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/get_patient_qr_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/tutor/link_tutor_with_patient_usecase.dart';
import '../../domain/usecases/phrase/save_phrase_usecase.dart'; // 🆕 ADD
import '../../domain/usecases/phrase/get_user_phrases_usecase.dart'; // 🆕 ADD
import '../../presentation/features/auth/controllers/auth_controller.dart';
import '../../presentation/features/package_download/controllers/audio_package_controller.dart';
import '../../presentation/features/customization/controllers/customization_controller.dart';
import '../utils/category_mapper.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Core dependencies - available globally
    Get.put<LocalStorage>(LocalStorage(), permanent: true);
    Get.put<MediaApiDatasource>(MediaApiDatasourceImpl(), permanent: true);
    Get.put<LocalAssetStorage>(LocalAssetStorage(), permanent: true);
    Get.put<CustomizationController>(
      CustomizationController(
        mediaApiDatasource: Get.find<MediaApiDatasource>(),
        localAssetStorage: Get.find<LocalAssetStorage>(),
        localStorage: Get.find<LocalStorage>(),
      ),
      permanent: true,
    );
    // 🆕 Initialize CategoryMapper
    final categoryMapper = CategoryMapper();
    await categoryMapper.initialize();
    print('✅ CategoryMapper ready');
    // Firebase Auth datasource
    Get.put<ApiAuthDatasource>(
      ApiAuthDatasourceImpl(),
      permanent: true,
    );

    Get.put<TutorLinkApiDatasource>(
      TutorLinkApiDatasourceImpl(),
      permanent: true,
    );

    Get.put<MarketplaceApiDatasource>(
      MarketplaceApiDatasource(),
      permanent: true,
    );

    // Firebase Storage datasource
    Get.put<FirebaseStorageDatasource>(
      FirebaseStorageDatasourceImpl(),
      permanent: true,
    );

    // 🆕 Firestore datasource
    Get.put<FirestoreDatasource>(
      FirestoreDatasourceImpl(),
      permanent: true,
    );

    // Audio Package Manager
    Get.put<AudioPackageManager>(
      AudioPackageManager(
        firebaseStorage: Get.find<FirebaseStorageDatasource>(),
        localStorage: Get.find<LocalStorage>(),
      ),
      permanent: true,
    );

    // Audio Package Controller
    Get.put<AudioPackageController>(
      AudioPackageController(
        packageManager: Get.find<AudioPackageManager>(),
      ),
      permanent: true,
    );

    // Auth Repository
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        apiAuthDatasource: Get.find<ApiAuthDatasource>(),
        localStorage: Get.find<LocalStorage>(),
      ),
      permanent: true,
    );

    // 🆕 Phrase Repository
    Get.put<PhraseRepository>(
      PhraseRepositoryImpl(
        firestoreDatasource: Get.find<FirestoreDatasource>(),
        firebaseStorageDatasource: Get.find<FirebaseStorageDatasource>(),
      ),
      permanent: true,
    );

    Get.put<TutorLinkRepository>(
      TutorLinkRepositoryImpl(
        datasource: Get.find<TutorLinkApiDatasource>(),
      ),
      permanent: true,
    );

    // Auth Use Cases
    Get.put<LoginUseCase>(
      LoginUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<RegisterUseCase>(
      RegisterUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<LogoutUseCase>(
      LogoutUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<GetPatientQrUseCase>(
      GetPatientQrUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<LinkTutorWithPatientUseCase>(
      LinkTutorWithPatientUseCase(
        repository: Get.find<TutorLinkRepository>(),
      ),
      permanent: true,
    );

    // 🆕 Phrase Use Cases
    Get.put<SavePhraseUseCase>(
      SavePhraseUseCase(repository: Get.find<PhraseRepository>()),
      permanent: true,
    );

    Get.put<GetUserPhrasesUseCase>(
      GetUserPhrasesUseCase(repository: Get.find<PhraseRepository>()),
      permanent: true,
    );

    // AuthController - available globally across all screens
    Get.put<AuthController>(
      AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
      permanent: true,
    );
  }
}