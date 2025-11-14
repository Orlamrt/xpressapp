import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpressatec/data/datasources/marketplace_api_datasource.dart';
import 'package:xpressatec/data/models/terapeuta_marketplace.dart';

class CommunicationTherapistController extends GetxController {
  CommunicationTherapistController({required this.datasource});

  final MarketplaceApiDatasource datasource;

  final RxList<TerapeutaMarketplace> terapeutas = <TerapeutaMarketplace>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSector = ''.obs;
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController especialidadCtrl = TextEditingController();

  late final Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadTerapeutas(),
      time: const Duration(milliseconds: 400),
    );
    loadTerapeutas();
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    searchCtrl.dispose();
    especialidadCtrl.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void onSectorChanged(String value) {
    selectedSector.value = value;
    loadTerapeutas();
  }

  Future<void> loadTerapeutas({bool resetOffset = true}) async {
    isLoading.value = true;
    try {
      final List<TerapeutaMarketplace> results =
          await datasource.fetchPublicTerapeutas(
        sector: selectedSector.value.isEmpty ? null : selectedSector.value,
        especialidad: especialidadCtrl.text.trim().isEmpty
            ? null
            : especialidadCtrl.text.trim(),
        search:
            searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        limit: 50,
        offset: resetOffset ? 0 : terapeutas.length,
      );

      if (resetOffset) {
        terapeutas.assignAll(results);
      } else {
        terapeutas.addAll(results);
      }
    } catch (error) {
      terapeutas.clear();
      final String message;
      if (error is MarketplaceApiException) {
        message = error.message ?? 'Ocurrió un error inesperado.';
      } else {
        message = 'Ocurrió un error inesperado. Intenta nuevamente.';
      }
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
