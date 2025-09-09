
import 'dart:math';

/// A data class representing a parsed Diameter URI.
class DiameterUri {
  final String scheme;
  final String fqdn;
  final int port;
  final Map<String, String> params;
  final bool isSecure;

  const DiameterUri(this.scheme, this.fqdn, this.port, this.params, this.isSecure);
}

/// Parses a diameter URI string into a [DiameterUri] object.
DiameterUri parseDiameterUri(String uri) {
  if (!uri.contains("://")) {
    throw ArgumentError("URI $uri has no scheme identifier ('aaa://' or 'aaas://')");
  }
  final parts = uri.split("://");
  final scheme = parts[0];
  var remaining = parts[1];

  String fqdnPort;
  String paramStr = "";
  if (remaining.contains(";")) {
    fqdnPort = remaining.substring(0, remaining.indexOf(';'));
    paramStr = remaining.substring(remaining.indexOf(';') + 1);
  } else {
    fqdnPort = remaining;
  }

  String fqdn;
  int port;
  if (fqdnPort.contains(":")) {
    final fqdnParts = fqdnPort.split(":");
    fqdn = fqdnParts[0];
    port = int.parse(fqdnParts[1]);
  } else {
    fqdn = fqdnPort;
    port = (scheme == "aaas") ? 5658 : 3868;
  }

  final params = <String, String>{};
  if (paramStr.isNotEmpty) {
    for (var p in paramStr.split(";")) {
      if (p.contains("=")) {
        final kv = p.split("=");
        params[kv[0]] = kv[1];
      }
    }
  }

  return DiameterUri(scheme, fqdn, port, params, scheme == "aaas");
}

/// A worker class that runs a task in a loop until stopped.
class StoppableWorker {
  bool _isStopped = false;
  Future<void>? _task;

  bool get isStopped => _isStopped;

  void start(Future<void> Function(StoppableWorker worker) target) {
    if (_task != null) return;
    _isStopped = false;
    _task = target(this);
  }

  void stop() {
    _isStopped = true;
  }

  Future<void> join({Duration timeout = const Duration(seconds: 2)}) async {
    await _task?.timeout(timeout);
  }
}

/// A sequence generator for Hop-by-Hop and End-to-End IDs.
class SequenceGenerator {
  static const int MIN_SEQUENCE = 0x00000001;
  static const int MAX_SEQUENCE = 0xffffffff;

  late int _sequence;

  SequenceGenerator({int? includeNow}) {
    final random = Random();
    if (includeNow != null) {
      _sequence = ((includeNow << 20) | random.nextInt(0x000fffff + 1)) & MAX_SEQUENCE;
    } else {
      _sequence = random.nextInt(MAX_SEQUENCE + 1);
      if (_sequence < MIN_SEQUENCE) _sequence = MIN_SEQUENCE;
    }
  }

  int get sequence => _sequence;

  int nextSequence() {
    if (_sequence == MAX_SEQUENCE) {
      _sequence = MIN_SEQUENCE;
    } else {
      _sequence += 1;
    }
    return _sequence;
  }
}

/// A generator for globally and eternally unique Session-IDs.
class SessionGenerator {
  final String diameterIdentity;
  final String _baseValue;
  int _sequence;
  
  SessionGenerator(this.diameterIdentity)
      : _baseValue = ((DateTime.now().millisecondsSinceEpoch ~/ 1000)
                .toRadixString(16).padLeft(8, '0')),
        _sequence = Random().nextInt(0x100000000) << 32 | Random().nextInt(0x100000000);

  String nextId([List<String> optional = const []]) {
    _sequence = (_sequence + 1) & 0xffffffffffffffff;
    final seqHex = _sequence.toRadixString(16).padLeft(16, '0');
    final parts = [
      diameterIdentity,
      _baseValue,
      seqHex.substring(0, 8),
      seqHex.substring(8)
    ];
    parts.addAll(optional);
    return parts.join(';');
  }
}
