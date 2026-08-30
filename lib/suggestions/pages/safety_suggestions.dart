import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sleepy_driver/breaks/viewmodels/bloc/break_bloc.dart';
import 'package:sleepy_driver/breaks/viewmodels/bloc/break_event.dart';
import 'package:sleepy_driver/breaks/viewmodels/bloc/break_state.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_bloc.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/safety_tips/models/safety_tip.dart';
import 'package:sleepy_driver/safety_tips/viewmodels/bloc/safety_tip_bloc.dart';
import 'package:sleepy_driver/safety_tips/viewmodels/bloc/safety_tip_event.dart';
import 'package:sleepy_driver/safety_tips/viewmodels/bloc/safety_tip_state.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/suggestions/custom_widgets/alert_card.dart';
import 'package:sleepy_driver/suggestions/custom_widgets/custom_snack_bar.dart';
import 'package:sleepy_driver/suggestions/custom_widgets/status_dot.dart';
import 'package:sleepy_driver/suggestions/helpers/navigation_helper.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/suggestions/models/rest_stop.dart';
import 'package:sleepy_driver/suggestions/viewmodels/bloc/recommendations_bloc.dart';
import 'package:sleepy_driver/suggestions/viewmodels/bloc/recommendations_state.dart';

class SafetySuggestionsPage extends StatefulWidget {
  final FatigueSeverity severity;
  SafetySuggestionsPage({super.key, required this.severity});

  @override
  State<SafetySuggestionsPage> createState() => _SafetySuggestionsPageState();
}

// the page is split into recommendations and nearby locations
enum SafetySuggestionMode { recommendations, destinations }

class _SafetySuggestionsPageState extends State<SafetySuggestionsPage> {
  final NavigationHelper navigationHelper = NavigationHelper();
  SafetySuggestionMode _selectedMode = SafetySuggestionMode.recommendations;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // rec bloc
      context.read<RecommendationBloc>().add(
        LoadRecommendationsEvent(severity: widget.severity),
      );
      // safety tip bloc
      context.read<SafetyTipBloc>().add(const LoadSafetyTips());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationBloc, RecommendationState>(
      builder: (context, state) {
        return BlocListener<BreakBloc, BreakState>(
        listenWhen: (previous, current) {
          return previous.status != current.status;
        },
        listener: (context, state) {
            if (state.status == BreakStatus.active) {
            context.read<DrowsinessBloc>().add(
              const DrowsinessBreakStarted(),
            );
            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
              CustomSnackBar(message: 'Your break has started. Take some time to rest before continuing.',
              icon: Icons.free_breakfast_rounded,
              backgroundColor:AppColours.primary,
    ),
  );
          }
          if (state.status == BreakStatus.completed) {
            context.read<DrowsinessBloc>().add(
              const DrowsinessBreakEnded(),
            );
            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
    CustomSnackBar(
      message:
          'Break ended. Monitoring has resumed.',
      icon:
          Icons.play_circle_fill_rounded,
      backgroundColor:
          AppColours.success
    ),
  );
          }
           if (state.status == BreakStatus.error) {
            ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    CustomSnackBar(
      message:
          'Unable to update break.',
      icon:
          Icons.error_outline_rounded,
      backgroundColor:
          AppColours.error,
    ),
  );
          }
        },
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    AlertCard(severity: widget.severity),
                    const SizedBox(height: 10),
                    _buildActionButtons(state),
                    const SizedBox(height: 10),
                    // checks what the selected mode is
                    if (_selectedMode == SafetySuggestionMode.recommendations)
                      _buildFatigueRecommendations(),
                    if (_selectedMode == SafetySuggestionMode.destinations)
                      _buildDestinationContent(state),
                    const SizedBox(height: 30),
                    _buildRestButton(),
                    const SizedBox(height: 30)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Safety Suggestions',
                style: TextStyle(
                  fontSize: 23.5,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDestinationContent(RecommendationState state) {
    return Column(
      children: [
        _buildMap(state),
        _buildRecommendedStop(state),
        _buildDestinationButtons(state),
        _buildNearbyHeader(),
        _buildNearbyStops(state),
      ],
    );
  }

  Widget _buildRestButton() {
    return BlocBuilder<BreakBloc, BreakState>(
      builder: (context, state) {
        final isOnBreak = state.status == BreakStatus.active;

        return ElevatedButton(
          onPressed: () {
            if (isOnBreak) {
              context.read<BreakBloc>().add(const EndBreak());
            } else {
              _takeBreakAtStop();
            }
          },
          child: Text(
            isOnBreak ? 'End Break' : 'Take a Break Now',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold
            ),),
        );
      },
    );
  }

  // map
  Widget _buildMap(RecommendationState state) {
    final latitude = state.currentLatitude;

    final longitude = state.currentLongitude;

    if (latitude == null || longitude == null) {
      return _buildMapLoading();
    }

    final currentPosition = LatLng(latitude, longitude);

    final stops = state.recommendations;

    final recommended = stops.isNotEmpty ? stops.first : null;

    final destination = recommended == null
        ? null
        : LatLng(recommended.latitude, recommended.longitude);

    final routePoints = state.routePoints;

    final center = routePoints.isNotEmpty
        ? routePoints[routePoints.length ~/ 2]
        : currentPosition;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      child: Container(
        height: 245,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        clipBehavior: Clip.antiAlias,

        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12,
            minZoom: 3,
            maxZoom: 19,
          ),

          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.sleepy_driver',
            ),

            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: const Color(0xFF2A74E8),
                  ),
                ],
              ),

            MarkerLayer(
              markers: [
                Marker(
                  point: currentPosition,
                  width: 52,
                  height: 52,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF1D6FE8),
                      size: 30,
                    ),
                  ),
                ),

                if (destination != null)
                  Marker(
                    point: destination,
                    width: 55,
                    height: 55,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFD20004),
                      size: 48,
                    ),
                  ),
              ],
            ),

            if (state.routeDistanceKm != null &&
                state.routeDurationMinutes != null &&
                routePoints.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: routePoints[routePoints.length ~/ 2],
                    width: 120,
                    height: 70,
                    child: _buildDistanceBadge(state),
                  ),
                ],
              ),

            const SimpleAttributionWidget(
              source: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge(RecommendationState state) {
    final distance = state.routeDistanceKm;

    final duration = state.routeDurationMinutes;

    if (distance == null || duration == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${duration.round()} min',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF12499B),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            '${distance.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLoading() {
    return Container(
      height: 245,
      decoration: BoxDecoration(
        color: AppColours.fill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildRecommendedStop(RecommendationState state) {
    if (state.status == RecommendationStatus.loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(22, 22, 22, 0),
        child: LinearProgressIndicator(),
      );
    }
    final stops = state.recommendations;
    if (stops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        child: _emptyStopCard(),
      );
    }

    final stop = stops.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Stop',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 12),
          _buildStopCard(stop, isRecommended: true),
        ],
      ),
    );
  }

  Widget _emptyStopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Text(
        'No nearby recommended stop found.',
        style: TextStyle(color: Color(0xFF667085)),
      ),
    );
  }

  Widget _buildStopCard(RestStop stop, {bool isRecommended = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColours.fill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStopIcon(stop.type),
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _formatType(stop.type),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF667085),
                  ),
                ),

                if (stop.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    stop.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],

                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColours.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Nearby',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stop.distanceKm.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RecommendationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.health_and_safety_rounded,
              title: 'Recommendations',
              subtitle: 'Battle Fatigue',
              filled: _selectedMode == SafetySuggestionMode.recommendations,
              onPressed: () {
                setState(() {
                  _selectedMode = SafetySuggestionMode.recommendations;
                });
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _buildActionButton(
              icon: Icons.navigation_rounded,
              title: 'Destinations',
              subtitle: 'Find a Rest Stop',
              filled: _selectedMode == SafetySuggestionMode.destinations,
              onPressed: () {
                setState(() {
                  _selectedMode = SafetySuggestionMode.destinations;
                });

                // load rest stops when destination mode
                // is selected
                context.read<RecommendationBloc>().add(
                  LoadRecommendationsEvent(severity: widget.severity),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationButtons(RecommendationState state) {
    final hasStop = state.recommendations.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: SizedBox(
        width: double.infinity,
        height: 74,
        child: ElevatedButton(
          onPressed: hasStop
              ? () {
                  _openDirections(state.recommendations.first);
                }
              : null,

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF123C82),

            foregroundColor: Colors.white,

            disabledBackgroundColor: const Color(0xFFE5E7EB),

            disabledForegroundColor: const Color(0xFF98A2B3),

            elevation: 3,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),

              side: const BorderSide(color: Color(0xFF123C82), width: 1.5),
            ),

            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),

          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.directions_rounded,
                  size: 21,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: const [
                    Text(
                      'Directions',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Navigate to recommended stop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFatigueRecommendations() {
    return BlocBuilder<SafetyTipBloc, SafetyTipState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ways to Reduce Fatigue',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColours.primary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Try one of these actions before continuing your journey.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColours.primary.withValues(alpha: 0.65),
                ),
              ),

              const SizedBox(height: 20),

              if (state.status == SafetyTipStatus.loading)
                const Center(child: CircularProgressIndicator()),

              if (state.status == SafetyTipStatus.error)
                Text(
                  state.errorMessage ?? 'Unable to load safety tips.',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),

              if (state.status == SafetyTipStatus.loaded && state.tips.isEmpty)
                const Text(
                  'No safety tips available.',
                  style: TextStyle(color: Colors.grey),
                ),

              if (state.status == SafetyTipStatus.loaded &&
                  state.tips.isNotEmpty)
                ..._buildTipCards(state.tips),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTipCards(List<SafetyTip> tips) {
    final widgets = <Widget>[];

    for (int i = 0; i < tips.length; i++) {
      widgets.add(
        _buildFatigueCard(
          icon: _getTipIcon(tips[i].icon),
          title: tips[i].title,
          description: tips[i].description,
        ),
      );

      if (i != tips.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }

  IconData _getTipIcon(String icon) {
    switch (icon) {
      case 'water':
        return Icons.water_drop_rounded;

      case 'walk':
        return Icons.directions_walk_rounded;

      case 'rest_eyes':
        return Icons.airline_seat_recline_normal_rounded;

      case 'fresh_air':
        return Icons.air_rounded;

      case 'break':
        return Icons.storefront_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildFatigueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.fill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.primary, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColours.secondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColours.primary, width: 1.2),
            ),
            child: Icon(icon, color: AppColours.primary, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColours.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: AppColours.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool filled,
    required VoidCallback? onPressed,
  }) {
    final primary = Theme.of(context).primaryColor;
    return SizedBox(
      height: 74,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              elevation: filled ? 3 : 0,
              // normal background
              backgroundColor: filled ? primary : AppColours.fill,
              foregroundColor: filled ? AppColours.fill : primary,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              disabledForegroundColor: const Color(0xFF98A2B3),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: primary, width: 1.5),
              ),

              padding: const EdgeInsets.symmetric(horizontal: 5),
            ).copyWith(
              // ONLY background changes when pressed
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return filled ? AppColours.fill : primary;
                }
                return filled ? primary : AppColours.fill;
              }),
            ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: filled
                    ? AppColours.fill.withValues(alpha: 0.18)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 17,
                color: filled ? Colors.white54 : primary,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: filled
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: filled
                          ? Colors.white
                          : const Color.fromARGB(255, 53, 59, 72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // nearby stops
  Widget _buildNearbyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nearby Rest Stops',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          // TextButton(
          //   onPressed: () {},
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text(
          //         'See All',
          //         style: TextStyle(
          //           color: Theme.of(context).primaryColor,
          //          // fontWeight: FontWeight.w700,
          //         ),
          //       ),
          //        Icon(Icons.chevron_right_rounded, color: Theme.of(context).primaryColor),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNearbyStops(RecommendationState state) {
    if (state.status == RecommendationStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == RecommendationStatus.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Text(
          state.errorMessage ?? 'Unable to load nearby stops.',
          style: TextStyle(color: AppColours.error),
        ),
      );
    }

    if (state.recommendations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Text(
          'No nearby rest stops found.',
          style: TextStyle(color: AppColours.accent),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: state.recommendations
            .take(5)
            .map(
              (stop) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildNearbyStop(stop),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNearbyStop(
  RestStop stop,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),

    decoration: _cardDecoration(),

    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,

      children: [
        Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: AppColours.fill,
            borderRadius:
                BorderRadius.circular(16),
          ),

          child: Icon(
            _getStopIcon(stop.type),
            color: AppColours.primary,
            size: 30,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                stop.name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColours.primary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                _formatType(stop.type),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              _buildOpenStatus(stop),
            ],
          ),
        ),

        const SizedBox(width: 6),

        Column(
          mainAxisSize:
              MainAxisSize.min,

          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            Text(
              '${stop.distanceKm.toStringAsFixed(1)} km',

              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
                color:
                    AppColours.primary,
              ),
            ),

            const SizedBox(height: 2),

            IconButton(
              onPressed: () {
                _openDirections(stop);
              },

              icon: const Icon(
                Icons.chevron_right_rounded,
                color:
                    AppColours.primary,
              ),

              tooltip:
                  'Navigate to this stop',

              padding: EdgeInsets.zero,

              constraints:
                  const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildOpenStatus(
  RestStop stop,
) {
  debugPrint(
    'STOP: ${stop.name} | '
    'openNow=${stop.openNow} | '
    'openingHours=${stop.openingHours}',
  );


  if (stop.openNow == true) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        const StatusDot(
          color: AppColours.success,
        ),

        const SizedBox(width: 5),

        const Text(
          'Open',
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w700,
            color:
                AppColours.success,
          ),
        ),
      ],
    );
  }

  if (stop.openNow == false) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        const StatusDot(
          color: AppColours.error,
        ),

        const SizedBox(width: 5),

        const Text(
          'Closed',
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w700,
            color:
                AppColours.error,
          ),
        ),
      ],
    );
  }

 return const Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    StatusDot(
      color: Color.fromARGB(255, 56, 61, 71),
    ),
    SizedBox(width: 5),
    Text(
      'Hours unavailable',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF667085),
      ),
    ),
  ],
);
}

 Future<void> _takeBreakAtStop() async {
    final tripId = context.read<DrowsinessBloc>().state.tripId;

    if (tripId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No active trip found.')));
      return;
    }

    context.read<BreakBloc>().add(StartBreak(tripId: tripId));
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColours.fill,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColours.primary, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  IconData _getStopIcon(String type) {
    switch (type) {
      case 'fuel':
        return Icons.local_gas_station_rounded;

      case 'cafe':
        return Icons.local_cafe_rounded;

      case 'restaurant':
        return Icons.restaurant_rounded;

      case 'fast_food':
        return Icons.fastfood_rounded;

      case 'rest_area':
      case 'services':
        return Icons.hotel_rounded;

      case 'parking_space':
        return Icons.local_parking_rounded;

      default:
        return Icons.location_on_rounded;
    }
  }

  String _formatType(String type) {
    switch (type) {
      case 'fuel':
        return 'Fuel Station';

      case 'cafe':
        return 'Cafe';

      case 'restaurant':
        return 'Restaurant';

      case 'fast_food':
        return 'Fast Food';

      case 'rest_area':
        return 'Rest Area';

      case 'services':
        return 'Service Area';

      case 'parking_space':
        return 'Parking Space';

      default:
        return 'Nearby Break Location';
    }
  }

  Future<void> _openDirections(RestStop stop) async {
    final opened = await navigationHelper.navigateTo(
      latitude: stop.latitude,
      longitude: stop.longitude,
      label: stop.name,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open a navigation app.')),
      );
    }
  }
}
