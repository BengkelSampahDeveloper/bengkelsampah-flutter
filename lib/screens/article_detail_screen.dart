import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: ChangeNotifierProvider<ArticleProvider>(
        create: (_) => ArticleProvider()..loadArticleDetail(widget.articleId),
        child: Consumer<ArticleProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
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
                  onRetry: () => provider.loadArticleDetail(widget.articleId),
                );
              });
            }

            var article = ArticleModel(
              id: 0,
              title: '',
              content: '',
              cover: '',
              category: '',
              creator: '',
              createdAt: '',
            );

            if (provider.selectedArticle != null) {
              article = provider.selectedArticle!;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadArticleDetail(widget.articleId);
              },
              color: AppColors.color_0FB7A6,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Hero Image with Parallax Effect
                  SliverAppBar(
                    expandedHeight: 230,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.color_0FB7A6,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            article.cover,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.gradient1,
                                ),
                                child: const Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.gradient1,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          // Article info overlay
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.color_0FB7A6,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    article.category,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        article.creator,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Article Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Info Cards
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  icon: Icons.person_outline,
                                  title: 'Penulis',
                                  content: article.creator,
                                  color: AppColors.color_0FB7A6,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  icon: Icons.access_time,
                                  title: 'Tanggal Publikasi',
                                  content: _formatDate(article.createdAt),
                                  color: AppColors.color_0FB7A6,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Content Section
                          const Text(
                            'Konten Artikel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.color_404040,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              article.content,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: AppColors.color_404040,
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.color_6F6F6F,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.color_404040,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) {
        return 'Tanggal tidak tersedia';
      }
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }
}
