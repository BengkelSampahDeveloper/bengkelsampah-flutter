import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../constants/app_colors.dart';
import '../models/notification_model.dart';
import '../helpers/dialog_helper.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<NotificationProvider>();

    // Show loading dialog for initial load
    DialogHelper.showLoadingDialog(context, message: 'Memuat notifikasi...');

    try {
      await provider.refresh();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Hide loading dialog
        DialogHelper.showErrorDialog(
          context,
          message: 'Gagal memuat notifikasi: ${e.toString()}',
          onRetry: () {
            provider.clearError();
            _loadInitialData();
          },
        );
      }
    } finally {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NotificationProvider>();
      if (!provider.isLoadingMore && provider.hasMoreData) {
        provider.loadMoreNotifications();
      }
    }
  }

  Future<void> _refreshNotifications() async {
    final provider = context.read<NotificationProvider>();

    // Show loading dialog for refresh
    DialogHelper.showLoadingDialog(context,
        message: 'Memperbarui notifikasi...');

    try {
      await provider.refresh();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Hide loading dialog
        DialogHelper.showErrorDialog(
          context,
          message: 'Gagal memperbarui notifikasi: ${e.toString()}',
          onRetry: () {
            provider.clearError();
            _refreshNotifications();
          },
        );
      }
    } finally {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_FFFFFF,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.color_212121,
          ),
        ),
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.color_212121),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () => _showMarkAllAsReadDialog(context),
                  child: const Text(
                    'Tandai Semua',
                    style: TextStyle(
                      color: AppColors.color_0FB7A6,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // Show error dialog if there's an error and no notifications
          if (provider.error != null && provider.notifications.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DialogHelper.showErrorDialog(
                context,
                message: provider.error!,
                onRetry: () {
                  provider.clearError();
                  _loadInitialData();
                },
              );
            });
            return const SizedBox.shrink();
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: AppColors.color_6F6F6F,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: AppColors.color_212121,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            color: AppColors.color_0FB7A6,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length +
                  (provider.isLoadingMore ? 1 : 0) +
                  (provider.hasMoreData && !provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when loading more
                if (index == provider.notifications.length &&
                    provider.isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: AppColors.color_0FB7A6,
                      ),
                    ),
                  );
                }

                // Show "no more data" message when reached end
                if (index == provider.notifications.length &&
                    !provider.hasMoreData) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Tidak ada notifikasi lagi',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.color_6F6F6F,
                        ),
                      ),
                    ),
                  );
                }

                final notification = provider.notifications[index];
                return _buildNotificationCard(context, notification, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(notification.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(context, notification, provider),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead
                ? AppColors.color_FFFFFF
                : AppColors.color_0FB7A6.withOpacity(0.1),
            border: notification.isRead
                ? null
                : Border.all(color: AppColors.color_0FB7A6.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead
                      ? Colors.transparent
                      : AppColors.color_0FB7A6,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.color_212121,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.color_6F6F6F,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: AppColors.color_B3B3B3,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _onMenuSelected(context, value, notification, provider),
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Tandai Dibaca'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: AppColors.color_6F6F6F,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) async {
    if (!notification.isRead) {
      // Show loading dialog
      DialogHelper.showLoadingDialog(context,
          message: 'Menandai sebagai dibaca...');

      try {
        await provider.markAsRead(notification.id);
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Hide loading dialog
          DialogHelper.showErrorDialog(
            context,
            message: 'Gagal menandai sebagai dibaca: ${e.toString()}',
          );
        }
      } finally {
        // Hide loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    // Handle navigation based on notification type
    if (notification.data != null) {
      final screen = notification.data!['screen'];
      if (screen != null) {
        // Navigate to specific screen
        // You can add navigation logic here
      }
    }
  }

  void _onMenuSelected(
    BuildContext context,
    String value,
    NotificationModel notification,
    NotificationProvider provider,
  ) async {
    switch (value) {
      case 'mark_read':
        // Show loading dialog
        DialogHelper.showLoadingDialog(context,
            message: 'Menandai sebagai dibaca...');

        try {
          await provider.markAsRead(notification.id);
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Hide loading dialog
            DialogHelper.showErrorDialog(
              context,
              message: 'Gagal menandai sebagai dibaca: ${e.toString()}',
            );
          }
        } finally {
          // Hide loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
        break;
      case 'delete':
        _showDeleteDialog(context, notification, provider);
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) {
    DialogHelper.showDeleteDialog(
      context,
      title: 'Hapus Notifikasi',
      message: 'Apakah Anda yakin ingin menghapus notifikasi ini?',
      onDelete: () async {
        // Show loading dialog
        DialogHelper.showLoadingDialog(context,
            message: 'Menghapus notifikasi...');

        try {
          await provider.deleteNotification(notification.id);
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Hide loading dialog
            DialogHelper.showErrorDialog(
              context,
              message: 'Gagal menghapus notifikasi: ${e.toString()}',
            );
          }
        } finally {
          // Hide loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  void _showMarkAllAsReadDialog(BuildContext context) {
    DialogHelper.showDeleteDialog(
      context,
      title: 'Tandai Semua Dibaca',
      message:
          'Apakah Anda yakin ingin menandai semua notifikasi sebagai dibaca?',
      onDelete: () async {
        // Show loading dialog
        DialogHelper.showLoadingDialog(context,
            message: 'Menandai semua sebagai dibaca...');

        try {
          await context.read<NotificationProvider>().markAllAsRead();
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Hide loading dialog
            DialogHelper.showErrorDialog(
              context,
              message: 'Gagal menandai semua sebagai dibaca: ${e.toString()}',
            );
          }
        } finally {
          // Hide loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}
