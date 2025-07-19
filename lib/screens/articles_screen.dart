import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ArticleProvider>();
      if (!provider.isLoading && provider.hasMorePages) {
        provider.loadArticles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: ChangeNotifierProvider<ArticleProvider>(
        create: (_) => ArticleProvider()..loadArticles(),
        child: Consumer<ArticleProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.articles.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                DialogHelper.showLoadingDialog(context,
                    message: 'Memuat data...');
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) Navigator.pop(context);
              });
            }

            if (provider.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                DialogHelper.showErrorDialog(
                  context,
                  message: provider.error!,
                  onRetry: provider.loadArticles,
                );
              });
            }

            if (provider.articles.isEmpty && !provider.isLoading) {
              return const SizedBox(
                child: Center(
                  child: Text('Tidak ada artikel'),
                ),
              );
            }

            return Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradient1,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 63, bottom: 30),
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
                                  "Daftar Artikel",
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
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh,
                    color: AppColors.color_0FB7A6,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      itemCount: provider.articles.length +
                          (provider.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.articles.length) {
                          return const SizedBox.shrink();
                        }

                        final article = provider.articles[index];
                        return _buildArticleCard(article);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticleCard(dynamic article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(
                    articleId: article.id ?? 0,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Image.network(
                          article.cover ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              decoration: const BoxDecoration(
                                gradient: AppColors.gradient1,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              child: const Icon(
                                Icons.article_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Container(
                              height: 180,
                              decoration: const BoxDecoration(
                                gradient: AppColors.gradient1,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.color_0FB7A6,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          article.category ?? 'Umum',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title ?? 'Judul tidak tersedia',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.color_404040,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.color_0FB7A6.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: AppColors.color_0FB7A6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              article.creator ?? 'Penulis tidak tersedia',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.color_6F6F6F,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.color_0FB7A6.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.color_0FB7A6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDate(article.createdAt),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.color_6F6F6F,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient1,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            'Baca Artikel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) {
        return 'Tanggal tidak tersedia';
      }
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }
}
