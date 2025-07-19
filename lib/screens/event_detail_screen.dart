import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: ChangeNotifierProvider<EventProvider>(
        create: (_) => EventProvider()..loadEventDetail(widget.eventId),
        child: Consumer<EventProvider>(
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
                  onRetry: () => provider.loadEventDetail(widget.eventId),
                );
              });
            }

            var event = EventModel(
              id: 0,
              title: '',
              description: '',
              cover: '',
              startDatetime: '',
              endDatetime: '',
              location: '',
              maxParticipants: 0,
              status: '',
              participantsCount: 0,
              hasResult: false,
              createdAt: '',
              updatedAt: '',
              adminName: '',
              isJoined: false,
              resultDescription: null,
              savedWasteAmount: null,
            );

            if (provider.selectedEvent != null) {
              event = provider.selectedEvent!;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadEventDetail(widget.eventId);
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
                            event.cover,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.gradient1,
                                ),
                                child: const Icon(
                                  Icons.event_outlined,
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
                          // Event info overlay
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
                                    color: _getStatusColor(event.status),
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
                                    event.statusText,
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
                                  event.title,
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
                                        Icons.people_outline,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${event.participantsCount}/${event.maxParticipants} Peserta',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
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

                  // Event Content
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
                                  icon: Icons.location_on_outlined,
                                  title: 'Lokasi',
                                  content: event.location,
                                  color: AppColors.color_0FB7A6,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  icon: Icons.access_time,
                                  title: 'Waktu',
                                  content: _formatDateTime(
                                      event.startDatetime, event.endDatetime),
                                  color: AppColors.color_0FB7A6,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Description Section
                          const Text(
                            'Deskripsi Event',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
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
                              event.description,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: AppColors.color_404040,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Join/Leave Button (only for active events)
                          if (event.isActive) ...[
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: event.isJoined
                                    ? const LinearGradient(
                                        colors: [Colors.red, Colors.redAccent],
                                      )
                                    : AppColors.gradient1,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final wasJoined = event.isJoined;
                                    DialogHelper.showLoadingDialog(context,
                                        message: 'Memproses...');
                                    await provider.toggleJoin(event.id);
                                    if (mounted && Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }

                                    if (mounted && provider.error == null) {
                                      final message = wasJoined
                                          ? 'Berhasil meninggalkan event!'
                                          : 'Berhasil bergabung dengan event!';
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                          backgroundColor:
                                              AppColors.color_0FB7A6,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          event.isJoined
                                              ? Icons.person_remove_outlined
                                              : Icons.person_add_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          event.isJoined
                                              ? 'Batal Ikut'
                                              : 'Ikut Event',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Event Results (if completed)
                          if (event.isCompleted && event.hasResult) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Hasil Event',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (event.resultDescription != null) ...[
                                    Text(
                                      event.resultDescription!,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: AppColors.color_404040,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (event.savedWasteAmount != null) ...[
                                    _buildResultCard(
                                      'Sampah Terkumpul',
                                      '${event.savedWasteAmount} kg',
                                      Icons.delete_outline,
                                      AppColors.color_0FB7A6,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (event.actualParticipants != null) ...[
                                    _buildResultCard(
                                      'Peserta Aktual',
                                      '${event.actualParticipants} orang',
                                      Icons.people_outline,
                                      AppColors.color_0FB7A6,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          // Participants List
                          if (event.participants != null &&
                              event.participants!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Text(
                                  'Daftar Peserta',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.color_404040,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.color_0FB7A6
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${event.participants!.length} orang',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.color_0FB7A6,
                                    ),
                                  ),
                                ),
                              ],
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
                              child: Column(
                                children:
                                    event.participants!.map((participant) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.color_0FB7A6
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: const Icon(
                                            Icons.person_outline,
                                            color: AppColors.color_0FB7A6,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                participant['user_name'] ??
                                                    'Nama tidak tersedia',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.color_404040,
                                                ),
                                              ),
                                              Text(
                                                'Bergabung ${_formatDate(participant['join_datetime'])}',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12,
                                                  color: AppColors.color_6F6F6F,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.color_404040,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  String _formatDateTime(String startDateTime, String endDateTime) {
    try {
      if (startDateTime.isEmpty || endDateTime.isEmpty) {
        return 'Tanggal tidak tersedia';
      }

      final start = DateTime.parse(startDateTime);
      final end = DateTime.parse(endDateTime);

      final startFormatted =
          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(start);
      final endFormatted =
          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(end);

      return '$startFormatted - \n$endFormatted';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  String _formatDate(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) {
        return 'Tanggal tidak tersedia';
      }
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }
}
