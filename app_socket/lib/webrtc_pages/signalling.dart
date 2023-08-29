import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignallingService {
  // instance of Socket
  WebSocketChannel? socket;
  Socket? sockeTest;
  StreamController? streamController;

  SignallingService._();
  static final instance = SignallingService._();

  init({required String websocketUrl, required String selfCallerID}) {
    final uri = Uri.parse('ws://192.168.68.122:8000/socket.io/$selfCallerID/');
    socket = WebSocketChannel.connect(uri);
    // WebSocket.connect(url)
    streamController = StreamController.broadcast();
    streamController?.addStream(socket!.stream);
    // streamController?.addStream(socket!.sink);

    // // init Socket
    // sockeTest = io(
    //   'http://192.168.1.117:8000/',
    //   OptionBuilder().setTransports(['websocket']).setPath('/socket.io/$selfCallerID/').build(),
    // );

    // // listen onConnect event
    // sockeTest!.onConnect((data) {
    //   log("Socket connected !!");
    // });

    // // listen onConnectError event
    // sockeTest!.onConnectError((data) {
    //   log("Connect Error $data");
    // });

    // // connect socket
    // sockeTest!.connect();
  }
}
