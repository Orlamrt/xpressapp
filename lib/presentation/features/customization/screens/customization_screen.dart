import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/core/constants/app_constants.dart';
import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../settings/widgets/settings_detail_layout.dart';

class CustomizationScreen extends GetView<CustomizationController> {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsDetailLayout(
      title: 'Personalización',
      subtitle: 'Gestiona tus pictogramas locales y categorías.',
      expandChild: true,
      child: Container(
        width: double.infinity,
        decoration: SettingsDetailLayout.cardDecoration(colorScheme),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final refreshKey = controller.treeRefreshToken.value;
          return FutureBuilder<TreeNode<CategoryData>>(
            key: ValueKey(refreshKey),
            future: _loadCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.children.isEmpty) {
                return const Center(
                  child: Text('No hay categorías disponibles'),
                );
              }

              return _buildTreeView(context, snapshot.data!);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTreeView(BuildContext context, TreeNode<CategoryData> tree) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return TreeView.simpleTyped<CategoryData, TreeNode<CategoryData>>(
      tree: tree,
      showRootNode: false,
      expansionIndicatorBuilder: (context, node) {
        if (node.data?.isDirectory == true) {
          return ChevronIndicator.rightDown(
            tree: node,
            color: Colors.teal[700]!,
            padding: EdgeInsets.all(_getResponsiveValue(
              mobile: 6.0,
              tablet: 8.0,
              desktop: 10.0,
              screenWidth: screenWidth,
            )),
          );
        } else {
          return NoExpansionIndicator(tree: node);
        }
      },
      indentation: Indentation(
        style: IndentStyle.squareJoint,
        width: _getResponsiveValue(
          mobile: 30.0,
          tablet: 35.0,
          desktop: 40.0,
          screenWidth: screenWidth,
        ),
      ),
      onItemTap: (item) => _handleItemTap(item),
      builder: (context, node) => _buildCategoryTile(
        context,
        node,
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
    );
  }

  Widget _buildCategoryTile(
      BuildContext context,
      TreeNode<CategoryData> node, {
        required bool isTablet,
        required bool isDesktop,
      }) {
    final categoryData = node.data;
    if (categoryData == null) return const SizedBox.shrink();

    final color = AppColors.getColor(categoryData.colorName);
    final screenWidth = MediaQuery.of(context).size.width;

    final cardMargin = EdgeInsets.symmetric(
      horizontal: _getResponsiveValue(
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        screenWidth: screenWidth,
      ),
      vertical: _getResponsiveValue(
        mobile: 4.0,
        tablet: 6.0,
        desktop: 8.0,
        screenWidth: screenWidth,
      ),
    );

    final iconSize = _getResponsiveValue(
      mobile: 50.0,
      tablet: 60.0,
      desktop: 70.0,
      screenWidth: screenWidth,
    );

    final fontSize = _getResponsiveValue(
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
      screenWidth: screenWidth,
    );

    final tileHeight = _getResponsiveValue(
      mobile: 72.0,
      tablet: 85.0,
      desktop: 95.0,
      screenWidth: screenWidth,
    );

    final bool isDir = categoryData.isDirectory;
    final IconData iconToShow = categoryData.icon;

    // --- Custom Rendering: Folder or Image Asset ---
    Widget iconWidget;
    if (isDir) {
      // Folder (directory) nodes
      iconWidget = Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          iconToShow,
          color: Colors.white,
          size: iconSize * 0.55,
        ),
      );
    } else {
      // File (image asset) nodes
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<ImageProvider>(
          future: controller.getImageProvider(categoryData.path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: iconSize,
                height: iconSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: iconSize * 0.4,
                  height: iconSize * 0.4,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                width: iconSize,
                height: iconSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                  size: iconSize * 0.5,
                ),
              );
            }
            return Image(
              image: snapshot.data!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
            );
          },
        ),
      );
    }

    return Card(
      color: Colors.white,
      margin: cardMargin,
      elevation: isDir ? 2 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: tileHeight,
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveValue(
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
            screenWidth: screenWidth,
          ),
          vertical: 8.0,
        ),
        child: Row(
          children: [
            iconWidget,
            SizedBox(
              width: _getResponsiveValue(
                mobile: 12.0,
                tablet: 16.0,
                desktop: 20.0,
                screenWidth: screenWidth,
              ),
            ),
            Expanded(
              child: Text(
                categoryData.name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isDir ? FontWeight.w600 : FontWeight.w500,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isDir)
              IconButton(
                onPressed: () => controller.addCustomPictogram(categoryData.path),
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.teal[700],
                ),
                tooltip: 'Agregar pictograma',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleItemTap(TreeNode<CategoryData> item) async {
    final categoryData = item.data;
    if (categoryData == null) return;

    if (!categoryData.isDirectory) {
      await controller.replaceImage(categoryData.path);
    }
  }

  Future<TreeNode<CategoryData>> _loadCategories() async {
    final categoryMapper = CategoryMapper();
    await categoryMapper.initialize();
    return _buildCategoryTree(categoryMapper);
  }

  TreeNode<CategoryData> _buildCategoryTree(CategoryMapper categoryMapper) {
    final root = TreeNode<CategoryData>.root();
    final categories = AppConstants.mainCategories;
    final icons = AppConstants.categoryIcons;

    for (int i = 0; i < categories.length; i++) {
      final categoryModel = categories[i];
      final categoryName = categoryModel.name;
      final colorName =
          categoryMapper.getColorForCategory(categoryName) ?? 'gris';
      final icon = i < icons.length ? icons[i] : Icons.category;

      final mainCategoryNode = TreeNode<CategoryData>(
        key: categoryName,
        data: CategoryData(
          name: categoryName,
          colorName: colorName,
          icon: icon,
          path: categoryModel.contentPath,
          isDirectory: true,
        ),
      );

      final List<AssetNode> assetTree =
          categoryMapper.getAssetTreeForCategory(categoryName);

      mainCategoryNode.addAll(
        _convertAssetNodes(
          categoryModel.contentPath,
          assetTree,
          colorName,
        ),
      );
      root.add(mainCategoryNode);
    }

    return root;
  }

  List<TreeNode<CategoryData>> _convertAssetNodes(
    String parentPath,
    List<AssetNode> assetNodes,
    String inheritedColorName,
  ) {
    final List<TreeNode<CategoryData>> children = [];

    for (final assetNode in assetNodes) {
      final bool isDir = assetNode.isDirectory;

      final nodeData = CategoryData(
        name: assetNode.displayName,
        colorName: inheritedColorName,
        icon: isDir ? Icons.folder_outlined : Icons.image_outlined,
        path: assetNode.path,
        isDirectory: isDir,
      );

      final String nodeKey = assetNode.name.replaceAll('.', '_');

      final treeNode = TreeNode<CategoryData>(
        key: nodeKey,
        data: nodeData,
      );

      if (isDir) {
        treeNode.addAll(
          _convertAssetNodes(
            assetNode.path,
            assetNode.children,
            inheritedColorName,
          ),
        );
      }

      children.add(treeNode);
    }

    children.addAll(
      _buildCustomNodes(parentPath, inheritedColorName),
    );

    return children;
  }

  List<TreeNode<CategoryData>> _buildCustomNodes(
    String parentPath,
    String inheritedColorName,
  ) {
    final customItems = controller.getCustomPictogramsForParent(parentPath);
    if (customItems.isEmpty) {
      return const [];
    }

    return customItems
        .map(
          (item) => TreeNode<CategoryData>(
            key: 'custom_${item.id}',
            data: CategoryData(
              name: item.name,
              colorName: inheritedColorName,
              icon: Icons.image_outlined,
              path: item.relativePath,
              isDirectory: false,
            ),
          ),
        )
        .toList();
  }

  double _getResponsiveValue({
    required double mobile,
    required double tablet,
    required double desktop,
    required double screenWidth,
  }) {
    if (screenWidth > 1200) return desktop;
    if (screenWidth > 600) return tablet;
    return mobile;
  }
}

class CategoryData {
  final String name;
  final String colorName;
  final IconData icon;
  final String path;
  final bool isDirectory;

  CategoryData({
    required this.name,
    required this.colorName,
    required this.icon,
    required this.path,
    this.isDirectory = true,
  });
}
