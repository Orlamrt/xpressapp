import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/core/constants/app_constants.dart';

import 'package:xpressatec/presentation/features/teacch_board/controllers/teacch_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/widgets/category_detail_sheet.dart';
import '../widgets/board_grid.dart';
import '../widgets/selected_items_bar.dart';
import '../widgets/teacch_card_widget.dart';

class TeacchBoardScreen extends StatelessWidget {
  const TeacchBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacchController>();

    // ✅ Use AppConstants instead of direct variables
    final List<TeacchCardWidget> categoryCards = List.generate(
      AppConstants.mainCategories.length,
      (index) {
        final category = AppConstants.mainCategories[index];
        final icon = AppConstants.categoryIcons[index];

        return TeacchCardWidget.icon(
          color: category.color,
          iconData: icon,
          text: category.name,
          showLabel: true,
          onTap: () async {
            await controller.loadCategoryDetails(category);

            Get.bottomSheet(
              FractionallySizedBox(
                heightFactor: 0.85,
                child: CategoryDetailSheet(categoryColor: category.color),
              ),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
        );
      },
    );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // ✨ Scrollable selected items bar (only visible when items are selected)
          SelectedItemsBar(),
          const SizedBox(height: 16),
          Expanded(
            child: BoardGrid(
              cards: categoryCards,
            ),
          ),
        ],
      ),
    );
  }
}
