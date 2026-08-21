import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sleepy_driver/dashboard/custom_widgets/fatigue_lvl_label.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_bloc.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_state.dart';

import 'package:sleepy_driver/shared/custom_widgets/button.dart';

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

    // initialize drowsiness detection
    // when the page is created
    context.read<DrowsinessBloc>().add(
          const DrowsinessInitialize(),
        );
  }

  // start and end detection when the btn is clicked
  void startDriverMonitoring() {
    context.read<DrowsinessBloc>().add(
          const DrowsinessStartMonitoring(),
        );
  }

  void endDriverMonitoring() {
    context.read<DrowsinessBloc>().add(
          const DrowsinessStopMonitoring(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DrowsinessBloc, DrowsinessState>(
      listener: (context, state) {
        if (state.status == DrowsinessStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'Drowsiness detection error',
              ),
            ),
          );
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),

              _buildHeader(context),

              const SizedBox(height: 30),

              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<DrowsinessBloc, DrowsinessState>(
      buildWhen: (previous, current) {
        return previous.status != current.status;
      },
      builder: (context, state) {
        final isMonitoring =
            state.status == DrowsinessStatus.monitoring;

        final isInitializing =
            state.status ==
                DrowsinessStatus.initializing;

// btn to toggle between starting and ending trip aka detection
        return Container(
          alignment: Alignment.center,
          child: CustomGeneralButton(
            text: isMonitoring
                ? 'End Trip'
                : 'Start Trip',

            onPressed: () {
              if (isInitializing) {
                return;
              }

              if (isMonitoring) {
                endDriverMonitoring();
              } else {
                startDriverMonitoring();
              }
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
  }

Widget _buildBody(BuildContext context) {
  return BlocBuilder<DrowsinessBloc, DrowsinessState>(
    builder: (context, state) {

      if (state.status == DrowsinessStatus.initializing) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (state.status == DrowsinessStatus.error) {
        return Center(
          child: Text(
            state.errorMessage ??
                'Something went wrong',
            textAlign: TextAlign.center,
          ),
        );
      }

      final controller = state.cameraController;
      if (controller == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCameraPreview(
            context,
            controller,
            state,
          ),

          const SizedBox(height: 20),
        ],
      );
    },
  );
}

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
          color: Theme.of(context)
              .colorScheme
              .primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // CAMERA
            CameraPreview(
              controller,
            ),

            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _buildFatigueLabel(
                state,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFatigueLabel(
  DrowsinessState state,
) {
  if (state.status != DrowsinessStatus.monitoring) {
    return const FatigueLevelLabel(
      fatigueSeverity: FatigueSeverity.normal,
    );
  }

  return FatigueLevelLabel(
    fatigueSeverity:
        state.severity ?? FatigueSeverity.normal,
  );
}
}