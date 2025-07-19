import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/katalog_provider.dart';
import '../models/sampah_model.dart';
import '../helpers/dialog_helper.dart';
import '../screens/katalog_detail_screen.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({Key? key}) : super(key: key);

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKatalogWithLoading();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadKatalogWithLoading() async {
    DialogHelper.showLoadingDialog(context, message: 'Memuat katalog...');
    await context.read<KatalogProvider>().loadKatalog();
    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
    }
  }

  Future<void> _searchWithLoading() async {
    DialogHelper.showLoadingDialog(context, message: 'Mencari...');
    await context.read<KatalogProvider>().searchSampah(_searchController.text);
    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: Consumer<KatalogProvider>(
        builder: (context, katalogProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient4,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 63),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                    height: 29,
                                    width: 29,
                                    decoration: BoxDecoration(
                                      color: AppColors.color_FFFFFF
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.chevron_left,
                                        size: 16,
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    )),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  height: 29,
                                  child: Center(
                                    child: Text(
                                      "Katalog Sampah",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 27, bottom: 20),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Cari sampah?',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: AppColors.color_B3B3B3,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, top: 15, bottom: 15),
                              child: SvgPicture.asset(
                                  'assets/images/ic_search_catalog.svg'),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: AppColors.color_B3B3B3),
                                    onPressed: () {
                                      _searchController.clear();
                                      katalogProvider.searchSampah('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          onSubmitted: (value) {
                            _searchWithLoading();
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      )
                    ],
                  )),

              // Category Filter
              _buildCategoryFilter(katalogProvider),

              // Content
              Expanded(
                child: _buildContent(katalogProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(KatalogProvider provider) {
    var defaultCategories = [
      CategoryModel(id: 1, nama: "", sampahCount: 0),
    ];

    if (provider.categories.isNotEmpty) {
      defaultCategories = provider.categories;
    }

    return Material(
        elevation: 0.8,
        child: Container(
          color: AppColors.color_FFFFFF,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jenis Sampah',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Daftar sampah cuan!',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    controller: _categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: defaultCategories.length,
                    itemBuilder: (context, index) {
                      final category = defaultCategories[index];
                      final isSelected =
                          provider.selectedCategory?.id == category.id;

                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () async {
                            DialogHelper.showLoadingDialog(context,
                                message: 'Memuat kategori...');
                            await provider.selectCategory(category.id);
                            if (mounted) {
                              Navigator.pop(context); // Dismiss loading dialog
                            }
                          },
                          child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppColors.gradient1
                                    : AppColors.gradientWhite,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: AppColors.color_0FB7A6,
                                  width: isSelected ? 0 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category.nama,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.color_FFFFFF
                                        : AppColors.color_0FB7A6,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              )),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _buildContent(KatalogProvider provider) {
    if (provider.isLoading && provider.sampah.isEmpty) {
      return Container(
        color: AppColors.color_FFFFFF,
      );
    }

    if (provider.error != null && provider.sampah.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogHelper.showErrorDialog(
          context,
          message: provider.error!,
          onRetry: () async {
            DialogHelper.showLoadingDialog(context, message: 'Memuat ulang...');
            await provider.refresh();
            if (mounted) {
              Navigator.pop(context); // Dismiss loading dialog
            }
          },
        );
      });
      return const SizedBox.shrink();
    }

    if (provider.sampah.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'Tidak ada sampah yang ditemukan'
                  : 'Belum ada sampah dalam kategori ini',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        DialogHelper.showLoadingDialog(context, message: 'Memuat ulang...');
        await provider.refresh();
        if (mounted) {
          Navigator.pop(context); // Dismiss loading dialog
        }
      },
      color: const Color(0xFF4ECDC4),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: provider.sampah.length,
        itemBuilder: (context, index) {
          final sampah = provider.sampah[index];
          return _buildSampahCard(sampah);
        },
      ),
    );
  }

  Widget _buildSampahCard(SampahModel sampah) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KatalogDetailScreen(sampahId: sampah.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.color_FFFFFF,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.color_E9E9E9,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: AppColors.color_F3F3F3,
                ),
                child: Stack(
                  children: [
                    // Main Image
                    sampah.gambar != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              sampah.gambar!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: AppColors.color_F3F3F3,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: AppColors.color_F3F3F3,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),

                    // Unit Badge - Positioned at top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.color_FFFFFF.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          sampah.satuan,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.color_0FB7A6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Container
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      sampah.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_404040,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Category
                    Text(
                      sampah.deskripsi,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: AppColors.color_B3B3B3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Cek Harga >",
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: AppColors.color_0FB7A6,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
