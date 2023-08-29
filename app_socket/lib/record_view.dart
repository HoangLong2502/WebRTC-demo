import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as lib_img;

import 'main.dart';

class RecordView extends StatefulWidget {
  const RecordView({super.key});

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late WebSocketChannel channel;
  final shift = (0xFF << 24);
  bool isLoading = false;

  Uint8List? dataImage;
  String? base64String;
  Image? imagePreview;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late MediaStream _localStream;
  late RTCPeerConnection _peerConnection;

  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  Convert? conv;

  @override
  void initState() {
    super.initState();
    // Load the convertImage() function from the library
    conv = convertImageLib
        .lookup<NativeFunction<convert_func>>('convertImage')
        .asFunction<Convert>();

    handShakeProductWs();
    _localRenderer.initialize();
    _initWebRTC();
  }

  void _initWebRTC() async {
    // Khởi tạo MediaStream cho camera
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': true,
    };
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    // Khởi tạo RTCPeerConnection
    // final configuration = RTCConfiguration(
    //   iceServers: [
    //     RTCIceServer(
    //       urls: ['stun:stun.l.google.com:19302'],
    //     ),
    //   ],
    // );
    _peerConnection = await createPeerConnection({
      "iceServers": [
        {
          "credential": "",
          "urls": ["https://demo.cloudwebrtc.com:8086/"],
          "username": ""
        }
      ],
    });
    

    // Thêm local stream vào peer connection
    _peerConnection.addStream(_localStream);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[0],
      ResolutionPreset.max,
    );
    await _controller.initialize();

    _controller.startImageStream((image) async {
      print('=====${image.format.group.name}');
      // final data = await convertCameraImageToBase64(image);
      channel.sink.add(jsonEncode(
          {'message': 'image base 64', 'data': image.planes[0].bytes}));
      // final data = await convertCameraImageToBase64(image);
      // if (base64String == null) {
      // final imagepreviewData = await convertYUV420toImageColor(image);
      //   setState(() {
      //     imagePreview = imagepreviewData;
      //     // base64String = data;
      //   });
      // }
//       // Allocate memory for the 3 planes of the image
//       Pointer<Uint8> p = calloc(image.planes[0].bytes.length);
//       // Allocator.allocate(image.planes[0].bytes.length);
//       Pointer<Uint8> p1 = calloc(image.planes[1].bytes.length);
//       // allocate(count: image.planes[1].bytes.length);
//       Pointer<Uint8> p2 = calloc(image.planes[2].bytes.length);
//       // allocate(count: image.planes[2].bytes.length);

//       // Assign the planes data to the pointers of the image
//       Uint8List pointerList = p.asTypedList(image.planes[0].bytes.length);
//       Uint8List pointerList1 = p1.asTypedList(image.planes[1].bytes.length);
//       Uint8List pointerList2 = p2.asTypedList(image.planes[2].bytes.length);
//       pointerList.setRange(
//           0, image.planes[0].bytes.length, image.planes[0].bytes);
//       pointerList1.setRange(
//           0, image.planes[1].bytes.length, image.planes[1].bytes);
//       pointerList2.setRange(
//           0, image.planes[2].bytes.length, image.planes[2].bytes);

//       // Call the convertImage function and convert the YUV to RGB
//       Pointer<Uint32> imgP = conv!(p, p1, p2, image.planes[1].bytesPerRow,
//           image.planes[1].bytesPerPixel ?? 0, image.width, image.height);
//       // Get the pointer of the data returned from the function to a List
//       final imgData = imgP.asTypedList((image.width * image.height));

//       // Generate image from the converted data
//       lib_img.Image img = lib_img.Image.fromBytes(
//           height: image.height, width: image.width, bytes: imgData.buffer);

// // Convert the bytes to Base64
//       if (base64String == null) {
//         List<int> imageBytes = lib_img.encodeJpg(
//             img); // You can choose other image formats like PNG if needed
//         base64String = base64Encode(imageBytes);
//         channel.sink.add(jsonEncode(
//             {'message': 'image base 64', 'data': 'base64String'}));
            
//       }
//       // Free the memory space allocated
//       // from the planes and the converted data
//       calloc.free(p);
//       calloc.free(p1);
//       calloc.free(p2);
//       calloc.free(imgP);
      // channel.sink.add(jsonEncode(
      //     {'message': 'image base 64', 'data': image.planes[0].bytes}));
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();

    channel.sink.close();
    _controller.stopImageStream();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: isLoading
                ? const LinearProgressIndicator()
                : RTCVideoView(_localRenderer, mirror: false, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,) //_controller.buildPreview(), //CameraPreview(_controller)
          ),
          Positioned(
            top: 100,
            right: 100,
            child: Container(
              color: Colors.red,
              child: Column(
                children: [
                  InkWell(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: base64String!));
                        // copied successfully
                      },
                      child: Text('1231232131231')),
                  SizedBox(
                    height: 100,
                    width: 50,
                    child: imagePreview ?? const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageFromBase64() {
    if (base64String == null) {
      return Center(child: Text('No image data available.'));
    } else {
      Uint8List bytes = base64.decode(base64String!);
      return Image.memory(bytes);
    }
  }

  Future<String> func() async {
    return '/path/to/save/video.mp4';
  }

  Future<String> convertCameraImageToBase64(CameraImage image) async {
    try {
      // Trích xuất dữ liệu từ CameraImage
      // final planeBytes = image.planes.map((e) => e.bytes).toList();
      final planeBytes = image.planes[0].bytes;
      // Mã hóa dữ liệu thành Base64
      String base64Image = base64.encode(planeBytes);
      return base64Image;
    } catch (e) {
      return '';
    }
  }

  Future<Image?> convertYUV420toImageColor(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 0;
      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var img =
          lib_img.Image(width: width, height: height); // Create Image buffer
      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final int uvIndex =
              uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * width + x;
          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          if (img.isBoundsSafe(height - y, x)) {
            img.setPixelRgba(height - y, x, r, g, b, shift);
          }
        }
      }

      lib_img.PngEncoder pngEncoder =
          lib_img.PngEncoder(level: 0, filter: lib_img.PngFilter.none);
      List<int> png = pngEncoder.encode(img);
      // muteYUVProcessing = false;
      base64String = base64.encode(png);
      return Image.memory(Uint8List.fromList(png));
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

  Future<void> handShakeProductWs() async {
    final url = Uri.parse('ws://10.0.2.2:8000/ws/products/');
    channel = WebSocketChannel.connect(url);
  }
}
