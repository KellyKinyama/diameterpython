import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import '../../diameter.dart';

// =====================================================================
// Peer Connection States and Constants
// =====================================================================

const int PEER_RECV = 0x01;
const int PEER_SEND = 0x02;
const int PEER_TRANSPORT_TCP = 0x0a;
const int PEER_TRANSPORT_SCTP = 0x0b;
const int PEER_CONNECTING = 0x10;
const int PEER_CONNECTED = 0x11;
const int PEER_READY = 0x12;
const int PEER_READY_WAITING_DWA = 0x13;
const int PEER_DISCONNECTING = 0x1a;
const int PEER_CLOSING = 0x1b;
const int PEER_CLOSED = 0x1c;

const List<int> PEER_READY_STATES = [PEER_READY, PEER_READY_WAITING_DWA];

// Disconnect Reasons
const int DISCONNECT_REASON_DPR = 0x20;
const int DISCONNECT_REASON_NODE_SHUTDOWN = 0x21;
const int DISCONNECT_REASON_CLEAN_DISCONNECT = 0x22;
const int DISCONNECT_REASON_SOCKET_FAIL = 0x30;
const int DISCONNECT_REASON_GONE_AWAY = 0x31;
const int DISCONNECT_REASON_FAILED_CONNECT = 0x32;
const int DISCONNECT_REASON_FAILED_CONNECT_CE = 0x33;
const int DISCONNECT_REASON_CER_REJECTED = 0x34;
const int DISCONNECT_REASON_DWA_TIMEOUT = 0x35;
const int DISCONNECT_REASON_UNKNOWN = 0x40;

/// Data class holding settings and state for a remote peer configuration.
class Peer {
  String nodeName;
  String realmName;
  List<String> ipAddresses;
  int port;
  int transport;
  bool persistent;
  // ... other properties from the Python Peer class ...
  PeerConnection? connection;

  Peer({
    required this.nodeName,
    required this.realmName,
    this.ipAddresses = const [],
    this.port = 3868,
    this.transport = PEER_TRANSPORT_TCP,
    this.persistent = false,
    this.connection,
  });
}

/// Represents an active connection to a remote Diameter node.
class PeerConnection {
  final String ident;
  final Node _node;
  Socket _socket;

  int state = PEER_CONNECTING;
  String hostIdentity = "";
  String nodeName = "";

  DateTime lastMessageTimestamp;
  DateTime? dwrSentTimestamp;

  final Duration idleTimeout;
  final Duration dwaTimeout;
  final Duration ceaTimeout;

  final StreamController<Message> _incomingMessages =
      StreamController.broadcast();
  Stream<Message> get messages => _incomingMessages.stream;

  final _logger = Logger('diameter.peer');
  final _readBuffer = BytesBuilder();

  PeerConnection(
    this._node,
    this._socket, {
    required this.ident,
    required this.idleTimeout,
    required this.dwaTimeout,
    required this.ceaTimeout,
  }) : lastMessageTimestamp = DateTime.now().toUtc() {
    _socket.listen(
      _handleData,
      onError: (error, stackTrace) => _handleError(error, stackTrace),
      onDone: _handleDone,
      cancelOnError: true,
    );
  }

  void _handleData(Uint8List data) {
    touch();
    _readBuffer.add(data);
    _processBuffer();
  }

  void _processBuffer() {
    var buffer = _readBuffer.toBytes();
    while (buffer.length >= 20) {
      final header = MessageHeader.fromBytes(buffer);
      if (buffer.length < header.length) {
        // Incomplete message, wait for more data
        return;
      }

      final messageBytes = buffer.sublist(0, header.length);
      final message = Message.fromBytes(messageBytes);
      _incomingMessages.add(message);

      // Remove processed message from buffer
      buffer = buffer.sublist(header.length);
    }
    _readBuffer.clear();
    if (buffer.isNotEmpty) {
      _readBuffer.add(buffer);
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _logger.warning("Socket error on peer $ident: $error", error, stackTrace);
    _node.closeConnectionSocket(
      this,
      disconnectReason: DISCONNECT_REASON_SOCKET_FAIL,
    );
  }

  void _handleDone() {
    _logger.info("Peer $ident disconnected gracefully.");
    _node.closeConnectionSocket(
      this,
      disconnectReason: DISCONNECT_REASON_CLEAN_DISCONNECT,
    );
  }

  void sendMessage(Message message) {
    try {
      touch();
      final bytes = message.asBytes();
      _socket.add(bytes);
    } catch (e, st) {
      _logger.severe("Failed to send message on peer $ident", e, st);
    }
  }

  void checkTimers() {
    final now = DateTime.now().toUtc();
    if (state == PEER_CONNECTED &&
        now.difference(lastMessageTimestamp) > ceaTimeout) {
      _logger.warning(
        "Peer $ident timed out waiting for CER/CEA. Disconnecting.",
      );
      _node.closeConnectionSocket(
        this,
        disconnectReason: DISCONNECT_REASON_FAILED_CONNECT_CE,
      );
      return;
    }
    if (state == PEER_READY_WAITING_DWA && dwrSentTimestamp != null) {
      if (now.difference(dwrSentTimestamp!) > dwaTimeout) {
        _logger.warning("Peer $ident did not respond to DWR. Disconnecting.");
        _node.closeConnectionSocket(
          this,
          disconnectReason: DISCONNECT_REASON_DWA_TIMEOUT,
        );
        return;
      }
    }
    if (state == PEER_READY &&
        now.difference(lastMessageTimestamp) > idleTimeout) {
      _logger.info("Peer $ident is idle. Sending DWR.");
      _node.sendDwr(this);
    }
  }

  void touch() => lastMessageTimestamp = DateTime.now().toUtc();
  void sentDwr() {
    state = PEER_READY_WAITING_DWA;
    dwrSentTimestamp = DateTime.now().toUtc();
    touch();
  }

  void receivedDwa() {
    state = PEER_READY;
    dwrSentTimestamp = null;
    touch();
  }

  Future<void> close() async {
    state = PEER_CLOSED;
    await _socket.close();
    await _incomingMessages.close();
  }
}
