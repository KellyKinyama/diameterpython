import 'dart:typed_data';
// import 'package:diameter/src/commands/credit_control.dart';

import '../../diameter.dart';
import 'attributes.dart';

/// A base class for every diameter message.
class Message {
  int get code => header.commandCode;
  String get name => "Unknown";

  MessageHeader header;
  List<Avp> _avps;

  Message({MessageHeader? header, List<Avp> avps = const []})
    : header = header ?? MessageHeader(),
      _avps = List.from(avps);

  List<Avp> get avps => _avps;
  set avps(List<Avp> newAvps) => _avps = newAvps;

  void appendAvp(Avp avp) {
    _avps.add(avp);
  }

  Message toAnswer() {
    var newHeader = MessageHeader(
      version: header.version,
      commandCode: header.commandCode,
      applicationId: header.applicationId,
      hopByHopId: header.hopByHopId,
      endToEndId: header.endToEndId,
    )..isProxyable = header.isProxyable;

    Type type = runtimeType;
    // This is a simplified way to find the Answer type. A real library might use a map.
    // if (type == CapabilitiesExchangeRequest) return CapabilitiesExchangeAnswer(header: newHeader);
    // if (type == CreditControlRequest) return CreditControlAnswer(header: newHeader);
    // if (type == UpdateLocationRequest) return UpdateLocationAnswer(header: newHeader);
    // Add other request/answer pairs here...

    // Fallback
    return Message(header: newHeader);
  }

  Uint8List asBytes() {
    final builder = BytesBuilder();
    final avpPacker = Packer();
    for (var avp in avps) {
      avp.asPacked(avpPacker);
    }
    final avpBytes = avpPacker.buffer;
    header.length = 20 + avpBytes.length;

    builder.add(header.asBytes());
    builder.add(avpBytes);
    return builder.toBytes();
  }

  static Message fromBytes(Uint8List data) {
    final header = MessageHeader.fromBytes(data);

    Type? cmdType = allCommands[header.commandCode];

    Message Function(MessageHeader, List<Avp>) constructor = (h, a) =>
        UndefinedMessage(header: h, avps: a);

    if (cmdType != null) {
      // This logic dynamically selects the correct Request/Answer constructor
      if (cmdType == CapabilitiesExchange) {
        constructor = header.isRequest
            ? (h, a) => CapabilitiesExchangeRequest(header: h, avps: a)
            : (h, a) => CapabilitiesExchangeAnswer(header: h, avps: a);
      } //else if (cmdType == CreditControl) {
      // constructor = header.isRequest
      //     ? (h, a) => CreditControlRequest(header: h, avps: a)
      //       : (h, a) => CreditControlAnswer(header: h, avps: a);
      // } else if (cmdType == UpdateLocation) {
      //   constructor = header.isRequest
      //       ? (h, a) => UpdateLocationRequest(header: h, avps: a)
      //       : (h, a) => UpdateLocationAnswer(header: h, avps: a);
      //}
      // Add other command types here...
    }

    final unpacker = Unpacker(data);
    unpacker.position = 20; // Skip header

    final avps = <Avp>[];
    while (!unpacker.isDone()) {
      try {
        avps.add(Avp.fromUnpacker(unpacker));
      } catch (e) {
        // Handle potential parsing errors gracefully
        break;
      }
    }

    return constructor(header, avps);
  }
}

/// A Diameter message header.
class MessageHeader {
  static const int flagRequestBit = 0x80;
  static const int flagProxiableBit = 0x40;
  static const int flagErrorBit = 0x20;
  static const int flagRetransmitBit = 0x10;

  int version;
  int length;
  int commandFlags;
  int commandCode;
  int applicationId;
  int hopByHopId;
  int endToEndId;

  MessageHeader({
    this.version = 1,
    this.length = 0,
    this.commandFlags = 0,
    this.commandCode = 0,
    this.applicationId = 0,
    this.hopByHopId = 0,
    this.endToEndId = 0,
  });

  bool get isRequest => (commandFlags & flagRequestBit) != 0;
  set isRequest(bool value) {
    if (value) {
      commandFlags |= flagRequestBit;
    } else {
      commandFlags &= ~flagRequestBit;
    }
  }

  bool get isProxyable => (commandFlags & flagProxiableBit) != 0;
  set isProxyable(bool value) {
    if (value) {
      commandFlags |= flagProxiableBit;
    } else {
      commandFlags &= ~flagProxiableBit;
    }
  }

  bool get isError => (commandFlags & flagErrorBit) != 0;
  set isError(bool value) {
    if (value) {
      commandFlags |= flagErrorBit;
    } else {
      commandFlags &= ~flagErrorBit;
    }
  }

  bool get isRetransmit => (commandFlags & flagRetransmitBit) != 0;
  set isRetransmit(bool value) {
    if (value) {
      commandFlags |= flagRetransmitBit;
    } else {
      commandFlags &= ~flagRetransmitBit;
    }
  }

  factory MessageHeader.fromBytes(Uint8List data) {
    if (data.length < 20) throw "Invalid header length";
    var bd = ByteData.view(data.buffer, data.offsetInBytes, 20);
    var versionAndLength = bd.getUint32(0, Endian.big);
    var flagsAndCode = bd.getUint32(4, Endian.big);

    return MessageHeader(
      version: versionAndLength >> 24,
      length: versionAndLength & 0x00ffffff,
      commandFlags: flagsAndCode >> 24,
      commandCode: flagsAndCode & 0x00ffffff,
      applicationId: bd.getUint32(8, Endian.big),
      hopByHopId: bd.getUint32(12, Endian.big),
      endToEndId: bd.getUint32(16, Endian.big),
    );
  }

  Uint8List asBytes() {
    var bd = ByteData(20);
    bd.setUint32(0, (version << 24) | length, Endian.big);
    bd.setUint32(4, (commandFlags << 24) | commandCode, Endian.big);
    bd.setUint32(8, applicationId, Endian.big);
    bd.setUint32(12, hopByHopId, Endian.big);
    bd.setUint32(16, endToEndId, Endian.big);
    return bd.buffer.asUint8List();
  }
}

/// A base class for every diameter message that is defined with strong types.
abstract class DefinedMessage extends Message implements AvpGenerator {
  @override
  List<Avp> additionalAvps = [];

  DefinedMessage({super.header, super.avps}) {
    // When a defined message is created from bytes, the AVPs are passed in.
    // We need to parse them into the strongly-typed properties.
    if (avps.isNotEmpty) {
      assignAttributesFromAvps(this, avps);
    }
  }

  @override
  List<Avp> get avps {
    // When serializing, generate AVPs from the strongly-typed properties.
    return generateAvpsFromDefs(this);
  }

  @override
  set avps(List<Avp> newAvps) {
    additionalAvps = newAvps;
  }
}

/// A message class for commands that are not explicitly defined in the library.
class UndefinedMessage extends Message {
  UndefinedMessage({super.header, super.avps});
}
