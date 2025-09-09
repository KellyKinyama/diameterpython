import 'package:diameter/src/node/peer.dart';

import '../../diameter.dart';

/// A data class for passing messages between the Node and an Application.
class AppRequest {
  final PeerConnection peer;
  final Message message;
  AppRequest(this.peer, this.message);
}

/// A base class for a Diameter application.
abstract class Application {
  final int applicationId;
  final bool isAuthApplication;
  final bool isAcctApplication;

  late final Node _node;
  Node get node => _node;

  Application({
    required this.applicationId,
    this.isAuthApplication = false,
    this.isAcctApplication = false,
  });

  void attachNode(Node node) {
    _node = node;
  }

  /// Handles an incoming request for this application.
  Future<void> handleRequest(AppRequest request);

  /// Handles an incoming answer that was not solicited by a sent request.
  void handleAnswer(AppRequest answer) {
    // Default implementation does nothing.
  }

  /// Sends a request and waits for the corresponding answer.
  Future<Message> sendRequest(
    Message message, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Logic to send request via node and wait for answer using a Completer.
    throw UnimplementedError();
  }

  /// Generates a standard answer for a given request.
  Message generateAnswer(
    Message request, {
    int? resultCode,
    String? errorMessage,
  }) {
    // ... logic to create and populate an answer message.
    throw UnimplementedError();
  }

  void start() {}
  void stop() {}
}

/// A simple application that processes each request in a `Future`.
class SimpleThreadingApplication extends Application {
  final Future<Message?> Function(Application app, Message request)
  requestHandler;

  SimpleThreadingApplication({
    required super.applicationId,
    super.isAuthApplication,
    super.isAcctApplication,
    required this.requestHandler,
  });

  @override
  Future<void> handleRequest(AppRequest request) async {
    final answer = await requestHandler(this, request.message);
    if (answer != null) {
      request.peer.sendMessage(answer);
    }
  }
}
