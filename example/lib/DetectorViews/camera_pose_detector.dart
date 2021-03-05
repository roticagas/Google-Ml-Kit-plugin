part of 'pose_detector_view.dart';

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  bool streaming = false;
  int z = 3;
  PoseDetector _poseDetector;
  List<PoseLandmark> poseLandMarks = [];
  Map<int, PoseLandmark> _poseLandmarks;
  ui.Image image;

  @override
  void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _poseDetector = GoogleMlKit.instance.poseDetector(poseDetectorOptions: PoseDetectorOptions(poseDetectionModel: PoseDetectionModel.AccuratePoseDetector));
    availableCameras().then((avlCameras) {
      cameras = avlCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });
        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else
        print("\nNo available cameras");
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> getPoseLandMarks(CameraImage image) async{
    var poses = await _poseDetector
        .fromByteBuffer(
        bytes: await compute(_concatenatePlanes,image.planes),
    rotation : 90,
    height: image.height,
    width: image.width);

    setState(() {
    poseLandMarks = poses;
    });

  }

  @override
  Widget build(BuildContext context) {
    return _cameraPreviewWidget();
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.medium);
    // controller.value.previewSize =
    controller.addListener(() {
      if (mounted) setState(() => null);
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return SizedBox(
      height: controller.value.previewSize.height,
      width: controller.value.previewSize.width,
      child: Stack(
        children: [
          CameraPreview(controller),
          // image == null
          //     ? Container()
          //     : CustomPaint(
          //         painter: PosePainter(image, _poseLandmarks),
          //       ),
          CustomPaint(
            painter: LivePosePainter(poseLandMarks),
          ),
          Positioned(
              bottom: 20,
              child:
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                        RaisedButton(
                          child: const Text('Start streaming'),
                          onPressed: () async {
                              if (!controller.value.isStreamingImages)
                                controller.startImageStream((CameraImage image) {
                                    getPoseLandMarks(image);
                                    print("\n\n ${image.format} ");
                                    print("\nCamera rotation ${controller.description.sensorOrientation}");
                                });
                              setState(() => streaming != streaming);
                            }
                        ),
                        SizedBox(width: 40,),
                        RaisedButton(
                          child: const Text('Stop streaming'),
                          onPressed: () async {
                            if (controller != null) {
                              if (controller.value.isStreamingImages)
                                controller.stopImageStream();
                              setState(() => streaming != streaming);
                            }
                            print(streaming);
                          },
                        ),
                      SizedBox(width: 40,),
                      RaisedButton(
                        child: const Text('Take another'),
                        onPressed: () {
                          setState(() => image = null);
                        }
                      ),
              ]),
                  )),
        ],
      ),
    );
  }

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }
}

class LivePosePainter extends CustomPainter {
  final List<PoseLandmark> _poseLandMarks;

  LivePosePainter(this._poseLandMarks);

  @override
  void paint(Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.white;

    if (_poseLandMarks.length > 0) {
      _poseLandMarks.forEach((ele) {
        canvas.drawCircle(Offset(ele.x, ele.y), 1, paint);
      });
    }
  }

  @override
  bool shouldRepaint(covariant LivePosePainter oldDelegate) {
    return _poseLandMarks != oldDelegate._poseLandMarks;
  }
}
