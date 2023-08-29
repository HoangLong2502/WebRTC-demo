import 'dart:convert';
import 'dart:math';

import 'package:app_socket/models/meeting_detail.dart';
import 'package:app_socket/pages/home_screen.dart';
import 'package:app_socket/widgets/control_panel.dart';
import 'package:app_socket/widgets/remote_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:flutter_webrtc_wrapper/webrtc_meeting_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({
    super.key,
    this.meetingId,
    this.name,
    required this.meetingDetail,
  });

  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late WebSocketChannel socket;
  final _localRenderer = RTCVideoRenderer();

  final _remoteRenderer = RTCVideoRenderer();

  MediaStream? _localStream;

  RTCPeerConnection? _rtcPeerConnection;

  List<RTCIceCandidate> rtcIceCandidates = [];

  final Map<String, dynamic> mediaConstrains = {'audio': true, 'video': true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  var username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  Future<void> connectSocket() async {
    final uri = Uri.parse('ws://10.0.2.2:8000/ws/chat/');
    socket = WebSocketChannel.connect(uri);

    socket.stream.listen((event) {
      final parsedData = json.decode(event);
      final peerUsername = parsedData['peer'];
      final action = parsedData['action'];

      if (peerUsername == username) {
        return;
      }

      var receiverChannelName = parsedData['message']['receiver_channel_name'];
      if (action == 'new-peer') {
        // createOfferer(peerUsername, receiverChannelName);

        return;
      }
    });
  }

  void _setupPeerConnection(peerUsername, receiverChannelName) async {
    const Map<String, dynamic> _configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };
    // create peer connection
    _rtcPeerConnection = await createPeerConnection(_configuration);
    _rtcPeerConnection!.onTrack = (event) {
      _remoteRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    // get localStream
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstrains);

    // add mediaTrack to peerConnection
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    // set source for local video renderer
    _localRenderer.srcObject = _localStream;
    setState(() {});
  }

  void sendSignal(String action, Map<String, dynamic> message) {
    socket.sink.add(jsonEncode({
      'peer': 'username',
      'action': action,
      'message': message,
    }));
  }

  String generateRandomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String result = '';

    for (int i = 0; i < length; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }

  void startMeeting() async {
    final userId = generateRandomString(10);
    final name = generateRandomString(5);
    // final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
      url: "http://10.0.2.2:8000/",
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: name,
    );

    MediaStream _localStream =
        await navigator.mediaDevices.getUserMedia(mediaConstrains);
    _localRenderer.srcObject = _localStream;
    meetingHelper!.stream = _localStream;
    // PeerConnection().getListenersCount(event)
    // ignore: use_build_context_synchronously
    meetingHelper!.on(
      "open",
      context,
      (ev, context) {
        print("1==============");
        setState(() {
          isConnectionFailed = false;
        });
        sendSignal('new-peer', {});
      },
    );

    // ignore: use_build_context_synchronously
    meetingHelper!.on(
      "connection",
      context,
      (ev, context) {
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    meetingHelper!.on(
      "user-left",
      context,
      (ev, context) {
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    meetingHelper!.on(
      "video-toggle",
      context,
      (ev, context) {
        setState(() {});
      },
    );

    meetingHelper!.on(
      "audio-toggle",
      context,
      (ev, context) {
        setState(() {});
      },
    );

    meetingHelper!.on(
      "meeting-ended",
      context,
      (ev, context) {
        onMeetingEnd();
      },
    );

    meetingHelper!.on(
      "connection-setting-changed",
      context,
      (ev, context) {
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    meetingHelper!.on(
      "stream-changed",
      context,
      (ev, context) {
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    setState(() {});
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    connectSocket();
    initRenderers();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  void handleReconect() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.reconnect();
      });
    }
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  void goToHomePage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children: List.generate(
                  meetingHelper!.connections.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(1),
                    child: RemoteConnection(
                      renderer: meetingHelper!.connections[index].renderer,
                      connection: meetingHelper!.connections[index],
                    ),
                  ),
                ),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Waiting for joint the meeting',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
        Positioned(
          bottom: 10,
          right: 0,
          child: SizedBox(
            width: 150,
            height: 200,
            child: RTCVideoView(_localRenderer),
          ),
        ),
      ],
    );
  }
}
