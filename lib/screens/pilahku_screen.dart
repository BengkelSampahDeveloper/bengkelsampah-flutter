import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../providers/pilahku_provider.dart';
import '../models/pilahku_model.dart';
import '../widgets/custom_buttons.dart';
import '../screens/detail_setoran_screen.dart';
import '../helpers/dialog_helper.dart';

class PilahkuScreen extends StatefulWidget {
  const PilahkuScreen({Key? key}) : super(key: key);

  @override
  State<PilahkuScreen> createState() => _PilahkuScreenState();
}

class _PilahkuScreenState extends State<PilahkuScreen> {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _loadItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isDisposed && mounted) {
        final provider = context.read<PilahkuProvider>();
        await provider.loadItems();
        // Migrate existing items to include service type if needed
        await provider.migrateServiceTypes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: Consumer<PilahkuProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.color_0FB7A6),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(provider),
                  Expanded(
                    child: provider.hasItems
                        ? _buildItemsList(provider)
                        : _buildEmptyState(),
                  ),
                ],
              ),
              if (provider.hasSelectedItems) _buildFloatingButton(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(PilahkuProvider provider) {
    final totals = _calculateTotals(provider.items);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradient1),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilahku',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_FFFFFF,
                      ),
                    ),
                  ),
                ],
              ),
              if (provider.hasItems) ...[
                const SizedBox(height: 16),
                _buildSummaryCard(totals),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateTotals(List<PilahkuItemModel> items) {
    double totalWeight = 0.0;
    double totalPrice = 0.0;

    for (final item in items) {
      totalWeight += item.estimasiBerat;
      totalPrice += item.totalHarga;
    }

    return {
      'weight': totalWeight,
      'price': totalPrice,
      'count': items.length,
    };
  }

  Widget _buildSummaryCard(Map<String, dynamic> totals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSummaryItem('${totals['count']}', 'Total Item'),
          _buildSummaryItem(
              '${totals['weight'].toStringAsFixed(1)} kg', 'Estimasi Berat'),
          _buildSummaryPointItem(totals['price'], 'Estimasi Total'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_FFFFFF,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.color_FFFFFF,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPointItem(dynamic value, String label) {
    return Expanded(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/ic_point.svg',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 4),
            Text(
              '${value.toInt()}',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.color_FFFFFF,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: AppColors.color_FFFFFF,
          ),
        ),
      ],
    ));
  }

  Widget _buildItemsList(PilahkuProvider provider) {
    final groupedItems = _groupItemsByBranch(provider.items);

    if (groupedItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final entry = groupedItems.entries.elementAt(index);
        final branchName = entry.value.first.bankSampahNama;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < groupedItems.length - 1 ? 15 : 0,
          ),
          child: _buildBranchSection(branchName, entry.value, provider),
        );
      },
    );
  }

  Map<String, List<PilahkuItemModel>> _groupItemsByBranch(
      List<PilahkuItemModel> items) {
    final Map<String, List<PilahkuItemModel>> groupedItems = {};

    for (final item in items) {
      if (item.bankSampahId.isNotEmpty && item.bankSampahNama.isNotEmpty) {
        groupedItems.putIfAbsent(item.bankSampahId, () => []).add(item);
      }
    }

    return groupedItems;
  }

  Widget _buildBranchSection(String branchName, List<PilahkuItemModel> items,
      PilahkuProvider provider) {
    final branchItemIds = items.map((item) => item.id).toSet();

    // Filter enabled items for selection logic
    final enabledBranchItemIds = branchItemIds.where((itemId) {
      final item = provider.items.firstWhere((item) => item.id == itemId);
      return !provider.isItemDisabled(item.id);
    }).toSet();

    final selectedBranchItems =
        provider.selectedItemIds.toSet().intersection(enabledBranchItemIds);
    final isAllBranchSelected =
        selectedBranchItems.length == enabledBranchItemIds.length &&
            enabledBranchItemIds.isNotEmpty;

    // Check if any items from other branches are selected
    final otherBranchSelectedItems = provider.selectedItemIds
        .where((id) => !branchItemIds.contains(id))
        .toSet();
    final hasOtherBranchSelected = otherBranchSelectedItems.isNotEmpty;

    // Get service type from the first item (all items in a branch should have the same service type)
    final serviceType =
        items.isNotEmpty ? items.first.bankSampahTipeLayanan : null;

    return SizedBox(
      child: Column(
        children: [
          // Branch Header with Select All and Delete
          Material(
            elevation: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: AppColors.color_FFFFFF,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.color_FFFFFF,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Branch Name and Service Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branchName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_404040,
                          ),
                        ),
                        if (serviceType != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getServiceTypeIcon(serviceType),
                                size: 14,
                                color: _getServiceTypeColor(serviceType),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getServiceTypeDisplay(serviceType),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: _getServiceTypeColor(serviceType),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            elevation: 1,
            child: Container(
              color: AppColors.color_FFFFFF,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 16, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (items.isNotEmpty)
                    GestureDetector(
                      onTap: hasOtherBranchSelected
                          ? null
                          : () => _toggleSelectAllForBranch(
                              branchItemIds, provider),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isAllBranchSelected
                                  ? AppColors.color_0FB7A6
                                  : (hasOtherBranchSelected
                                      ? AppColors.color_E9E9E9
                                      : AppColors.color_FFFFFF),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: isAllBranchSelected
                                    ? AppColors.color_0FB7A6
                                    : (hasOtherBranchSelected
                                        ? AppColors.color_B3B3B3
                                            .withValues(alpha: 0.5)
                                        : AppColors.color_B3B3B3),
                                width: 2,
                              ),
                            ),
                            child: isAllBranchSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.color_FFFFFF,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pilih Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: hasOtherBranchSelected
                                  ? AppColors.color_B3B3B3
                                  : AppColors.color_404040,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => selectedBranchItems.isNotEmpty
                        ? _showDeleteBranchConfirmation(
                            branchName, selectedBranchItems, provider)
                        : null,
                    child: Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: selectedBranchItems.isNotEmpty
                            ? AppColors.color_0FB7A6
                            : AppColors.color_B3B3B3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Branch Items
          ...items.map((item) {
            final isSelected = provider.selectedItemIds.contains(item.id);
            final isDisabled = hasOtherBranchSelected && !isSelected;
            return _buildItemCard(item, isSelected, isDisabled, provider);
          }).toList(),
        ],
      ),
    );
  }

  void _toggleSelectAllForBranch(
      Set<String> branchItemIds, PilahkuProvider provider) {
    // Filter out disabled items from branch
    final enabledBranchItemIds = branchItemIds.where((itemId) {
      final item = provider.items.firstWhere((item) => item.id == itemId);
      return !provider.isItemDisabled(item.id);
    }).toSet();

    final selectedBranchItems =
        provider.selectedItemIds.toSet().intersection(enabledBranchItemIds);
    final isAllSelected =
        selectedBranchItems.length == enabledBranchItemIds.length &&
            enabledBranchItemIds.isNotEmpty;

    if (isAllSelected) {
      // Deselect all enabled items in this branch
      for (final itemId in enabledBranchItemIds) {
        provider.unselectItem(itemId);
      }
    } else {
      // Select all enabled items in this branch
      for (final itemId in enabledBranchItemIds) {
        provider.selectItem(itemId);
      }
    }
  }

  Widget _buildItemCard(PilahkuItemModel item, bool isSelected, bool isDisabled,
      PilahkuProvider provider) {
    if (!_isValidItem(item)) return const SizedBox.shrink();

    // Check if item is disabled due to bank sampah or sampah not found
    final isItemDisabled = provider.isItemDisabled(item.id);
    final isActuallyDisabled = isDisabled || isItemDisabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: isActuallyDisabled
            ? AppColors.color_F8FAFB
            : AppColors.color_FFFFFF,
        border: Border.all(
          color: isSelected
              ? AppColors.color_0FB7A6
              : (isActuallyDisabled
                  ? AppColors.color_E9E9E9.withValues(alpha: 0.5)
                  : AppColors.color_E9E9E9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActuallyDisabled
              ? null
              : () => _toggleItemSelection(item, provider),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectionCheckbox(isSelected, isActuallyDisabled),
                const SizedBox(width: 12),
                _buildItemImage(item),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildItemDetails(
                      item, isActuallyDisabled, isItemDisabled),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidItem(PilahkuItemModel item) {
    return item.id.isNotEmpty && item.sampahNama.isNotEmpty;
  }

  void _toggleItemSelection(PilahkuItemModel item, PilahkuProvider provider) {
    if (provider.selectedItemIds.contains(item.id)) {
      provider.unselectItem(item.id);
    } else {
      provider.selectItem(item.id);
    }
  }

  Widget _buildSelectionCheckbox(bool isSelected, bool isDisabled) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.color_0FB7A6
            : (isDisabled ? AppColors.color_E9E9E9 : AppColors.color_FFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected
              ? AppColors.color_0FB7A6
              : (isDisabled
                  ? AppColors.color_B3B3B3.withValues(alpha: 0.5)
                  : AppColors.color_B3B3B3),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: AppColors.color_FFFFFF)
          : (isDisabled
              ? const Icon(Icons.block, size: 16, color: AppColors.color_B3B3B3)
              : null),
    );
  }

  Widget _buildItemImage(PilahkuItemModel item) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.color_F3F3F3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildImageContent(item),
    );
  }

  Widget _buildImageContent(PilahkuItemModel item) {
    if (item.sampahGambar?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.sampahGambar!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported,
                color: AppColors.color_B3B3B3);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.color_0FB7A6,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    }
    return const Icon(Icons.image_not_supported, color: AppColors.color_B3B3B3);
  }

  Widget _buildItemDetails(
      PilahkuItemModel item, bool isDisabled, bool isItemDisabled) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name with disabled indicator
        Row(
          children: [
            Expanded(
              child: Text(
                item.sampahNama,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? AppColors.color_B3B3B3
                      : AppColors.color_404040,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isItemDisabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.color_F44336.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.color_F44336),
                ),
                child: const Text(
                  'Tidak Tersedia',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.color_F44336,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Price Details
        Flexible(
          child: _buildItemStats(item, isDisabled),
        ),
        const SizedBox(height: 8),

        // Total Points
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/ic_poin_inverse.svg',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${item.totalHarga.toInt()} Poin',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? AppColors.color_B3B3B3
                      : AppColors.color_0FB7A6,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Action Buttons
        if (!isDisabled)
          Flexible(child: _buildActionButtons(item))
        else if (isItemDisabled)
          Flexible(child: _buildDisabledActionButtons(item)),
      ],
    );
  }

  Widget _buildActionButtons(PilahkuItemModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Detail Button
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _showItemDetail(item),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: AppColors.color_0FB7A6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Remove Button
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_F44336.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _showDeleteItemConfirmation(item),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Hapus',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: AppColors.color_F44336,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledActionButtons(PilahkuItemModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Remove Button
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_F44336.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _showDeleteItemConfirmation(item),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Hapus',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: AppColors.color_F44336,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemStats(PilahkuItemModel item, bool isDisabled) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/images/ic_poin_inverse.svg',
          width: 15,
          height: 15,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${item.hargaPerSatuan.toInt()} Poin x ${item.estimasiBerat.toStringAsFixed(1)} ${item.sampahSatuan.isNotEmpty ? item.sampahSatuan : 'Kg'}',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color:
                  isDisabled ? AppColors.color_B3B3B3 : AppColors.color_0FB7A6,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ic_katalog.webp',
            width: 120,
            height: 120,
            color: AppColors.color_B3B3B3,
          ),
          const SizedBox(height: 24),
          const Text(
            'Pilahku Kosong',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Belum ada sampah yang ditambahkan\ndi pilahku',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.color_6F6F6F,
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'Tambah Sampah',
            onPressed: () {
              Navigator.pushNamed(context, '/katalog');
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  void _showDeleteBranchConfirmation(
      String branchName, Set<String> itemIds, PilahkuProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Item',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${itemIds.length} item dari cabang $branchName?',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.color_6F6F6F),
            ),
          ),
          TextButton(
            onPressed: () {
              for (final itemId in itemIds) {
                provider.removeItem(itemId);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.color_F44336),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetorkanConfirmation(PilahkuProvider provider) {
    final selectedItems = provider.items
        .where((item) => provider.selectedItemIds.contains(item.id))
        .toList();

    if (selectedItems.isEmpty) return;

    final totals = _calculateTotals(selectedItems);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Setorkan Sampah',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin setorkan ${selectedItems.length} item sampah?',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            _buildSetorkanSummary(totals),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.color_6F6F6F)),
          ),
          _buildSetorkanButton(provider),
        ],
      ),
    );
  }

  Widget _buildSetorkanSummary(Map<String, dynamic> totals) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.color_F8FAFB,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
              'Estimasi Berat:', '${totals['weight'].toStringAsFixed(1)} kg'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimasi Total:',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_6F6F6F,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_poin_inverse.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${totals['price'].toInt()} Poin',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_0FB7A6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: AppColors.color_6F6F6F,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: label.contains('Total')
                ? AppColors.color_0FB7A6
                : AppColors.color_404040,
          ),
        ),
      ],
    );
  }

  Widget _buildSetorkanButton(PilahkuProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradient1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            Navigator.pop(context);
            final selectedItems = provider.items
                .where((item) => provider.selectedItemIds.contains(item.id))
                .toList();
            if (selectedItems.isEmpty) return;

            // Tampilkan loading dialog
            if (mounted) {
              DialogHelper.showLoadingDialog(
                context,
                message: 'Memeriksa data pilahku...',
              );
            }

            // Panggil pengecekan pilahku
            final checkResult = await provider.checkPilahkuItems(selectedItems);

            // Tutup loading dialog
            if (mounted) {
              Navigator.pop(context);
            }

            if (checkResult['status'] == 'success' &&
                checkResult['results'] != null) {
              final results = checkResult['results'] as List<dynamic>;

              // Auto-disable items yang bank sampah atau sampahnya tidak ada
              provider.autoDisableItems(results);

              // Update items yang memiliki perubahan data
              await provider.updateItemsFromCheckResults(results);

              bool hasBlocking = false;
              String infoMsg = '';
              int disabledCount = 0;
              int updatedCount = 0;

              for (final res in results) {
                switch (res['status']) {
                  case 'bank_sampah_not_found':
                    hasBlocking = true;
                    disabledCount++;
                    infoMsg +=
                        '- Cabang sudah tidak tersedia, item telah dinonaktifkan.\n';
                    break;
                  case 'sampah_not_found':
                    hasBlocking = true;
                    disabledCount++;
                    infoMsg +=
                        '- Sampah sudah tidak tersedia, item telah dinonaktifkan.\n';
                    break;
                  case 'tipe_layanan_changed':
                    updatedCount++;
                    infoMsg += '- Tipe layanan cabang telah diperbarui.\n';
                    break;
                  case 'detail_sampah_changed':
                    updatedCount++;
                    infoMsg += '- Detail sampah telah diperbarui.\n';
                    break;
                  case 'harga_changed':
                    updatedCount++;
                    infoMsg += '- Harga sampah telah diperbarui.\n';
                    break;
                }
              }

              if (hasBlocking || infoMsg.isNotEmpty) {
                // Tampilkan info perubahan dan opsi untuk menghapus item disabled
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Perubahan pada Pilahku'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(infoMsg.isNotEmpty
                              ? infoMsg
                              : 'Ada perubahan pada item yang ingin disetorkan.'),
                          if (disabledCount > 0) ...[
                            const SizedBox(height: 16),
                            Text(
                              '$disabledCount item telah dinonaktifkan karena tidak tersedia lagi.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_F44336,
                              ),
                            ),
                          ],
                          if (updatedCount > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              '$updatedCount item telah diperbarui dengan data terbaru.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_0FB7A6,
                              ),
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        if (disabledCount > 0)
                          TextButton(
                            onPressed: () async {
                              final currentContext = context;
                              Navigator.pop(context);
                              await provider.removeDisabledItems();
                              if (mounted) {
                                ScaffoldMessenger.of(currentContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '$disabledCount item telah dihapus'),
                                    backgroundColor: AppColors.color_0FB7A6,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Hapus Item Nonaktif',
                              style: TextStyle(color: AppColors.color_F44336),
                            ),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                return;
              }
              // Jika tidak ada masalah, lanjutkan setor
              if (mounted) {
                _showSetorkanSuccess(provider);
              }
            } else {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Gagal Cek Pilahku'),
                    content: Text(checkResult['message']?.toString() ??
                        'Terjadi kesalahan.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Setorkan',
              style: TextStyle(
                color: AppColors.color_FFFFFF,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSetorkanSuccess(PilahkuProvider provider) {
    final selectedItems = provider.items
        .where((item) => provider.selectedItemIds.contains(item.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.color_0FB7A6,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pengecekan Berhasil!',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data pilahku sudah diperbarui. Silakan lanjutkan ke detail setoran.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: AppColors.color_6F6F6F,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradient1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailSetoranScreen(
                        selectedItems: selectedItems,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Lanjutkan',
                    style: TextStyle(
                      color: AppColors.color_FFFFFF,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(PilahkuProvider provider) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: AppColors.gradient1,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.color_0FB7A6.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showSetorkanConfirmation(provider),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: AppColors.color_FFFFFF, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Setorkan Sampah',
                    style: TextStyle(
                      color: AppColors.color_FFFFFF,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteItemConfirmation(PilahkuItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Item',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${item.sampahNama} dari pilahku?',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.color_6F6F6F),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<PilahkuProvider>().removeItem(item.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.color_F44336),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetail(PilahkuItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailSheet(item),
    );
  }

  Widget _buildItemDetailSheet(PilahkuItemModel item) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.color_E9E9E9,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Detail Item',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 16),

            // Item Image
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.color_F3F3F3,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.sampahGambar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.sampahGambar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: AppColors.color_B3B3B3,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: AppColors.color_B3B3B3,
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Item Details
            _buildDetailRow('Nama Sampah', item.sampahNama),
            _buildDetailRow('Deskripsi', item.sampahDeskripsi),
            _buildDetailRow('Cabang', item.bankSampahNama),
            if (item.bankSampahTipeLayanan != null)
              _buildDetailRow('Tipe Layanan',
                  _getServiceTypeDisplay(item.bankSampahTipeLayanan!)),
            _buildDetailRow(
                'Estimasi Berat', '${item.estimasiBerat} ${item.sampahSatuan}'),
            _buildDetailRow(
              'Harga per ${item.sampahSatuan}',
              '',
              valueWidget: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_poin_inverse.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.hargaPerSatuan.toInt()} Poin',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  ),
                ],
              ),
            ),
            _buildDetailRow(
              'Estimasi Total',
              '',
              isTotal: true,
              valueWidget: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_poin_inverse.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.totalHarga.toInt()} Poin',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_0FB7A6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Tutup',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isTotal = false, Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.color_6F6F6F,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: AppColors.color_6F6F6F,
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                    color: isTotal
                        ? AppColors.color_0FB7A6
                        : AppColors.color_404040,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceTypeIcon(String serviceType) {
    switch (serviceType) {
      case 'jemput':
        return Icons.delivery_dining; // Delivery icon
      case 'tempat':
        return Icons.location_on; // Location icon
      case 'keduanya':
        return Icons.swap_horiz; // Both icon
      default:
        return Icons.location_on;
    }
  }

  Color _getServiceTypeColor(String serviceType) {
    switch (serviceType) {
      case 'jemput':
        return AppColors.color_0FB7A6; // Green for pickup
      case 'tempat':
        return AppColors.color_FFAB2A; // Orange for drop-off
      case 'keduanya':
        return AppColors.color_6F6F6F; // Gray for both
      default:
        return AppColors.color_FFAB2A;
    }
  }

  String _getServiceTypeDisplay(String serviceType) {
    switch (serviceType) {
      case 'jemput':
        return 'Jemput';
      case 'tempat':
        return 'Tempat';
      case 'keduanya':
        return 'Jemput & Tempat';
      default:
        return 'Tempat';
    }
  }
}
