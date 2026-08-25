import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/trips/models/trip_record.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_bloc.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_event.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_state.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({
    super.key,
  });

  @override
  State<TripHistoryPage> createState() =>
      _TripHistoryPageState();
}

class _TripHistoryPageState
    extends State<TripHistoryPage> {

  @override
  void initState() {
    super.initState();

    context.read<TripBloc>().add(
      const LoadMyTripsEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColours.lightBackground,
        title: const Text(
          'Trip History',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColours.primary
          ),
        ),
      ),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is TripError) {
            return _buildError(
              state.message,
            );
          }
          if (state is TripsLoaded) {
            if (state.trips.isEmpty) {
              return _buildEmpty();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                30,
              ),
              itemCount: state.trips.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 14,
              ),
              itemBuilder:
                  (context, index) {
                return _buildTripCard(
                  state.trips[index],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

Widget _buildTripCard(
  TripRecord trip,
) {
  final severityColor =
      _severityColor(
    trip.maxDrowsinessLevel,
  );
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: AppColours.fill,
      borderRadius: BorderRadius.circular(24),

      border: Border.all(
        color: AppColours.primary,
        width: 2,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.12,
          ),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatDate(
                  trip.startTime,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColours.primary,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: severityColor.withValues(
                  alpha: 0.14,
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Text(
                _formatSeverity(
                  trip.maxDrowsinessLevel,
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: severityColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Trip Duration',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColours.primary
                .withValues(alpha: 0.65),
          ),
        ),

        const SizedBox(height: 3),
        Text(
          _formatDuration(
            trip.durationSeconds,
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColours.primary,
          ),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStat(
                icon:
                    Icons.warning_amber_rounded,
                label: 'Alerts',
                value:
                    trip.totalAlerts.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStat(
                icon:
                    Icons.visibility_outlined,
                label: 'Drowsiness Events',
                value:
                    trip.totalDrowsinessEvents
                        .toString(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.45,
            ),
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  title: 'Started',
                  value:
                      _formatTime(
                    trip.startTime,
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 30,
                color: AppColours.primary
                    .withValues(alpha: 0.20),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _buildTimeInfo(
                  title: 'Ended',
                  value:
                      trip.endTime == null
                          ? 'Ongoing'
                          : _formatTime(
                              trip.endTime!,
                            ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStat({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),

    decoration: BoxDecoration(
      color: Colors.white.withValues(
        alpha: 0.42,
      ),
      borderRadius:
          BorderRadius.circular(16),

      border: Border.all(
        color: AppColours.primary
            .withValues(alpha: 0.18),
        width: 1,
      ),
    ),

    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColours.primary,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColours.primary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColours.primary
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

 Widget _buildTimeInfo({
  required String title,
  required String value,
}) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColours.primary
              .withValues(alpha: 0.55),
        ),
      ),

      const SizedBox(height: 3),

      Text(
        value,
        maxLines: 1,
        overflow:
            TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColours.primary,
        ),
      ),
    ],
  );
}
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
                  BoxDecoration(
                color:
                    AppColours.fill,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                Icons.route_outlined,
                size: 40,
                color:
                    AppColours.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No trips yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color:
                    AppColours.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your completed trips will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    String message,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TripBloc>().add(
                  const LoadMyTripsEvent(),
                );
              },
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatTime(
    DateTime date,
  ) {
    final hour =
        date.hour % 12 == 0
            ? 12
            : date.hour % 12;

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDuration(
    int seconds,
  ) {
    final duration =
        Duration(
      seconds: seconds,
    );

    final hours =
        duration.inHours;

    final minutes =
        duration.inMinutes
            .remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    }

    return '$minutes min';
  }

  String _formatSeverity(
    String severity,
  ) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return 'Severe';

      case 'moderate':
        return 'Moderate';

      case 'mild':
        return 'Mild';

      default:
        return 'Normal';
    }
  }

  Color _severityColor(
    String severity,
  ) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return const Color.fromARGB(255, 223, 35, 35);

      case 'moderate':
        return const Color.fromARGB(255, 196, 88, 16);

      case 'mild':
        return const Color.fromARGB(255, 223, 173, 6);

      default:
        return const Color.fromARGB(255, 35, 135, 62);
    }
  }
}