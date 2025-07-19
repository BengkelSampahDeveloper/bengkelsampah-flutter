import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
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
      final provider = context.read<EventProvider>();
      if (!provider.isLoading && provider.hasMorePages) {
        provider.loadEvents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: ChangeNotifierProvider<EventProvider>(
        create: (_) => EventProvider()..loadEvents(),
        child: Consumer<EventProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.events.isEmpty) {
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
                  onRetry: provider.loadEvents,
                );
              });
            }

            if (provider.events.isEmpty && !provider.isLoading) {
              return const SizedBox(
                child: Center(
                  child: Text('Tidak ada event'),
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
                                  "Daftar Event",
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
                      itemCount: provider.events.length +
                          (provider.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.events.length) {
                          return const SizedBox.shrink();
                        }

                        final event = provider.events[index];
                        return _buildEventCard(event);
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

  Widget _buildEventCard(dynamic event) {
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
                  builder: (context) => EventDetailScreen(
                    eventId: event.id ?? 0,
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
                          event.cover ?? '',
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
                                Icons.event_outlined,
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
                          color: _getStatusColor(event.status ?? 'active'),
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
                          event.statusText ?? 'Tidak Diketahui',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.participantsCount ?? 0}/${event.maxParticipants ?? 0}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
                        event.title ?? 'Judul tidak tersedia',
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
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.color_0FB7A6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.location ?? 'Lokasi tidak tersedia',
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
                              "${_formatDate(event.startDatetime)} - ${_formatDate(event.endDatetime)}",
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
                            'Lihat Detail',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.color_0FB7A6;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.color_6F6F6F;
    }
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
