import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/dashboard/custom_widgets/fatigue_lvl_label.dart';
import 'package:sleepy_driver/dashboard/custom_widgets/toast_dashboard.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_bloc.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_state.dart';
import 'package:sleepy_driver/routing/route_constants.dart';
import 'package:sleepy_driver/shared/custom_widgets/button.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_bloc.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_event.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_state.dart';


class SafetyDashboardPage extends StatefulWidget {
  const SafetyDashboardPage({
    super.key,
  });

  @override
  State<SafetyDashboardPage> createState() =>
      _SafetyDashboardPageState();
}

class _SafetyDashboardPageState
    extends State<SafetyDashboardPage> {

  @override
  void initState() {
    super.initState();

    final drowsinessBloc =
        context.read<DrowsinessBloc>();

    if (drowsinessBloc.state.status ==
        DrowsinessStatus.initial) {
      drowsinessBloc.add(
        const DrowsinessInitialize(),
      );
    }
  }

// collecting data for starting and ending trip
  void _startTrip() {
    final startTime =
        DateTime.now();

    context.read<TripBloc>().add(
      StartTripEvent(
        startTime: startTime,
      ),
    );
  }

  void _endTrip(DrowsinessState drowsinessState,TripStarted tripState) {
    context.read<DrowsinessBloc>().add(
      const DrowsinessStopMonitoring(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
     BlocListener<
    DrowsinessBloc,
    DrowsinessState>(
  listenWhen: (
    previous,
    current,
  ) {
    // error
    if (previous.status != DrowsinessStatus.error &&
        current.status == DrowsinessStatus.error) {
      return true;
    }

    // monitoring stopped → complete trip
    if (previous.status != DrowsinessStatus.stopped &&
        current.status == DrowsinessStatus.stopped) {
      return true;
    }

    // new alarm
    if (!previous.alarmActive &&
        current.alarmActive) {
      return true;
    }

    return false;
  },

  listener: (
    context,
    state,
  ) {
    if (state.status ==
        DrowsinessStatus.stopped) {

      final tripState =
          context.read<TripBloc>().state;

      if (tripState is TripStarted) {

        log(
          'FINAL TRIP DATA'
        );

        log(
          'Trip ID: ${tripState.tripId}',
        );

        log(
          'Total drowsiness events: '
          '${state.totalDrowsinessEvents}',
        );

        log(
          'Total alerts: '
          '${state.totalAlerts}',
        );

        log(
          'Max severity: '
          '${state.maxSeverity.name}',
        );

        context.read<TripBloc>().add(
          CompleteTripEvent(
            tripId: tripState.tripId,
            startTime: tripState.startTime,
            totalDrowsinessEvents:state.totalDrowsinessEvents,
            totalAlerts:state.totalAlerts,
            maxDrowsinessLevel:state.maxSeverity.name,
          ),
        );
      }

      return;
    }

    if (state.status ==
        DrowsinessStatus.error) {

     CustomToastDashboard.show(
  context: context,
  message: state.errorMessage ??
      'Something went wrong.',
  icon: Icons.error_outline_rounded,
  bgColor: AppColours.error,
  txtColor: Colors.white,
);
      return;
    }
    if (!state.alarmActive) {
      return;
    }

    final severity =
        state.severity;

    if (severity == null) {
      return;
    }

    switch (severity) {
      case FatigueSeverity.mild:
        context.pushNamed(
          RouteConstants.mildFatigue,
        );
        break;

      case FatigueSeverity.moderate:
        context.pushNamed(
          RouteConstants.modFatigue,
        );
        break;

      case FatigueSeverity.severe:
        context.pushNamed(
          RouteConstants.severeFatigue,
        );
        break;

      case FatigueSeverity.normal:
        break;
    }
  },
), BlocListener<
            TripBloc,
            TripState>(
          listener: (context,state) {

            if (state is TripStarted) {
              debugPrint(
                'Trip started: ${state.tripId}',
              );

              // start drowsinss monitoring
              context.read<DrowsinessBloc>().add(
                DrowsinessStartMonitoring(
                  startTime:
                      state.startTime, tripId: state.tripId
                ),
              );
            }

           if (state is TripCompleted) {
  CustomToastDashboard.show(
    context: context,
    message: 'Trip saved successfully.',
    icon: Icons.check_circle_outline_rounded,
    bgColor: AppColours.primary,
    txtColor: Colors.white,
  );
}
if (state is TripError) {
  CustomToastDashboard.show(
    context: context,
    message: state.message,
    icon: Icons.error_outline_rounded,
    bgColor: AppColours.error,
    txtColor: Colors.white,
  );
}
          },
        ),
      ],

      child: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              const SizedBox(
                height: 25,
              ),

              _buildHeader(context),

              const SizedBox(
                height: 16,
              ),

              _buildTripTimer(),

              const SizedBox(
                height: 30,
              ),

              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(
    BuildContext context,
  ) {
    return BlocBuilder<
        DrowsinessBloc,
        DrowsinessState>(
      buildWhen: (
        previous,
        current,
      ) {
        return previous.status !=
            current.status;
      },

      builder: (
        context,
        drowsinessState,
      ) {
        final isMonitoring =
            drowsinessState.status ==
                DrowsinessStatus.monitoring;

        final isInitializing =
            drowsinessState.status ==
                DrowsinessStatus.initializing;

        return BlocBuilder<
            TripBloc,
            TripState>(
          builder: (
            context,
            tripState,
          ) {
            return Container(
              alignment:
                  Alignment.center,

              child: CustomGeneralButton(
                text: isMonitoring
                    ? 'End Trip'
                    : 'Start Trip',

                onPressed: () {

                  if (isInitializing) {
                    return;
                  }

                  if (isMonitoring) {
                    if (tripState
                        is! TripStarted) {
                   CustomToastDashboard.show(
  context: context,
  message: 'No active trip found.',
  icon: Icons.info_outline_rounded,
  bgColor: AppColours.accent,
  txtColor: Colors.white,
);
                      return;
                    }

                    _endTrip(
                      drowsinessState,
                      tripState,
                    );

                    return;
                  }
                  _startTrip();
                },

                bgColor:
                    Theme.of(context)
                        .colorScheme
                        .secondary,

                txtColor:
                    Theme.of(context)
                        .colorScheme
                        .primary,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    return BlocBuilder<
        DrowsinessBloc,
        DrowsinessState>(
      builder: (
        context,
        state,
      ) {
        if (state.status ==
            DrowsinessStatus.initializing) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (state.status ==
            DrowsinessStatus.error) {
          return Center(
            child: Text(
              state.errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
            ),
          );
        }

        final controller =
            state.cameraController;

        if (controller == null) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        return Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            _buildCameraPreview(
              context,
              controller,
              state,
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  // camera view

  Widget _buildCameraPreview(
    BuildContext context,
    CameraController controller,
    DrowsinessState state,
  ) {
    return AspectRatio(
      aspectRatio: 9 / 16,

      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                Theme.of(context)
                    .colorScheme
                    .primary,
            width: 2,
          ),

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(8),

          child: Stack(
            fit: StackFit.expand,

            children: [
              CameraPreview(
                controller,
              ),

              Positioned(
                bottom: 24,
                left: 24,
                right: 24,

                child:
                    _buildFatigueLabel(
                  state,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // timer

  Widget _buildTripTimer() {
    return BlocBuilder<
        DrowsinessBloc,
        DrowsinessState>(
      buildWhen: (
        previous,
        current,
      ) {
        return previous.tripDuration !=
            current.tripDuration;
      },

      builder: (
        context,
        state,
      ) {
        final isMonitoring =
            state.status ==
                DrowsinessStatus.monitoring;

        return Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              20,
            ),

            border: Border.all(
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
              width: 1.5,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 10,
                offset:
                    const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                Icons.timer_outlined,
                color:
                    Theme.of(context)
                        .colorScheme
                        .primary,
              ),

              const SizedBox(
                width: 10,
              ),

              Text(
                isMonitoring
                    ? _formatDuration(
                        state.tripDuration,
                      )
                    : '00:00:00',

                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(
    Duration duration,
  ) {
    final hours =
        duration.inHours;

    final minutes =
        duration.inMinutes
            .remainder(60);

    final seconds =
        duration.inSeconds
            .remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }


  Widget _buildFatigueLabel(
    DrowsinessState state,
  ) {
    if (state.status !=
        DrowsinessStatus.monitoring) {
      return const FatigueLevelLabel(
        fatigueSeverity:
            FatigueSeverity.normal,
      );
    }

    return FatigueLevelLabel(
      fatigueSeverity:
          state.severity ??
              FatigueSeverity.normal,
    );
  }
}
