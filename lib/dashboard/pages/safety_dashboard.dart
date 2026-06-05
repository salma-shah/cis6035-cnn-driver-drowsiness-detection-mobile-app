import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sleepy_driver/dashboard/custom_widgets/fatigue_lvl_label.dart';
import 'package:sleepy_driver/dashboard/fatigue_severity.dart';
import 'package:sleepy_driver/shared/custom_widgets/button.dart';

class SafetyDashboardPage extends StatefulWidget
{
  const SafetyDashboardPage({super.key});

  @override
  State<SafetyDashboardPage> createState() => _SafetyDashboardPageState();
}

class _SafetyDashboardPageState extends State<SafetyDashboardPage> 
{
  List<CameraDescription> cameras = [];
  CameraController? cameraController ;

  // init state
  @override
  void initState()
  {
    super.initState();
    _setUpCameraController();
  }

  @override
  Widget build(BuildContext context) {
    // if (SafetyDashboardMonitoringStarted)
    // {
    // capturing the image
    //   XFile picture = await cameraController!.takePicture();
    // }

   return SafeArea( 
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 25), 
                      _buildHeader(context), 
                      SizedBox(height: 30),
                     _buildBody()       
                  ],
                ),
              ),
        
    );
  }

   // checking if camera has access
   Future<void> _setUpCameraController() async 
   {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty)
    {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(_cameras.last, ResolutionPreset.high);
      });
    }
    // initialize
    cameraController?.initialize().then(
      (_) {
        setState(() {});
      }
    );

   }

  // header widget with btn
   Widget _buildHeader(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: CustomGeneralButton(
        text: 'End Trip', 
        onPressed: () {},
        bgColor: Theme.of(context).colorScheme.secondary,
        txtColor: Theme.of(context).colorScheme.primary,)
    );
  }

  // camera  view
  Widget _buildBody()
  {
    if (cameraController == null || cameraController?.value.isInitialized == false)
    {
      // if no camera, we just load
      return const Center(child: CircularProgressIndicator());
    }

    // otherwise
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 9/16,
            child: SizedBox(
              // height: MediaQuery.sizeOf(context).height * 0.30,
              // width: MediaQuery.sizeOf(context).width * 0.80,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect
                (
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack
                  (children: [ CameraPreview(cameraController!),
                  Positioned(
                    bottom: 24,
                    left: 24, right: 24,
                    child: FatigueLevelLabel(fatigueSeverity: FatigueSeverity.moderate),
                  )
                  ]),                 // lbl for fatigue levels
              
                  ),
                ),
            ),
      ),
    ]));
  }

}
  
