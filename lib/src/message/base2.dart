import 'dart:typed_data';
import '../../diameter.dart';

// --- Helper function for attribute assignment ---

/// Populates the properties of a [DefinedMessage] from a list of raw AVPs.
void assignAttributesFromAvps(DefinedMessage message, List<Avp> avps) {
  final map = message.toMap();
  final definedAvpCodes = <String>{};

  for (var def in message.avpDef) {
    var avpIdentifier = '${def.avpCode}:${def.vendorId}';
    var foundAvps = avps
        .where((avp) => avp.code == def.avpCode && avp.vendorId == def.vendorId)
        .toList();

    if (foundAvps.isEmpty) {
      continue;
    }
    definedAvpCodes.add(avpIdentifier);

    final isListProperty = map[def.attrName] is List;

    if (isListProperty) {
      final list = map[def.attrName] as List;
      for (var avp in foundAvps) {
        if (def.typeClass != null && avp is AvpGrouped) {
          var groupedInstance = _createGroupedInstance(
            def.typeClass!,
            avp.value,
          );
          list.add(groupedInstance);
        } else {
          list.add(avp.value);
        }
      }
    } else {
      var avp = foundAvps.first;
      if (def.typeClass != null && avp is AvpGrouped) {
        map[def.attrName] = _createGroupedInstance(def.typeClass!, avp.value);
      } else {
        map[def.attrName] = avp.value;
      }
    }
  }

  // Assign any remaining AVPs to additionalAvps
  message.additionalAvps.addAll(
    avps.where(
      (avp) => !definedAvpCodes.contains('${avp.code}:${avp.vendorId}'),
    ),
  );

  // Update the message instance with the populated map
  message.updateFromMap(map);
}

/// A simplified factory to instantiate grouped AVP classes.
dynamic _createGroupedInstance(Type type, List<Avp> avps) {
  final Map<Type, Function> factories = {
    VendorSpecificApplicationId: (a) => VendorSpecificApplicationId.fromAvps(a),
    FailedAvp: (a) => FailedAvp.fromAvps(a),
    // Add all other grouped AVP factories here...
  };

  if (factories.containsKey(type)) {
    return factories[type]!(avps);
  }
  return null; // Or handle as an undefined grouped AVP
}

// --- Base Message Classes ---

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

    // Simplified logic, a full implementation would use a map for lookup
    // if (this is CapabilitiesExchangeRequest)
    //   return CapabilitiesExchangeAnswer(header: newHeader);
    // if (this is CreditControlRequest)
    //   return CreditControlAnswer(header: newHeader);

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
      // if (cmdType == CapabilitiesExchange) {
      //   constructor = header.isRequest
      //       ? (h, a) => CapabilitiesExchangeRequest(header: h, avps: a)
      //       : (h, a) => CapabilitiesExchangeAnswer(header: h, avps: a);
      // } else if (cmdType == CreditControl) {
      //    constructor = header.isRequest
      //       ? (h, a) => CreditControlRequest(header: h, avps: a)
      //       : (h, a) => CreditControlAnswer(header: h, avps: a);
      // }
      // ... add other command types here
    }

    final unpacker = Unpacker(data);
    unpacker.position = 20;

    final avps = <Avp>[];
    while (!unpacker.isDone()) {
      try {
        avps.add(Avp.fromUnpacker(unpacker));
      } catch (e) {
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
  set isRequest(bool value) =>
      value ? commandFlags |= flagRequestBit : commandFlags &= ~flagRequestBit;

  bool get isProxyable => (commandFlags & flagProxiableBit) != 0;
  set isProxyable(bool value) => value
      ? commandFlags |= flagProxiableBit
      : commandFlags &= ~flagProxiableBit;

  bool get isError => (commandFlags & flagErrorBit) != 0;
  set isError(bool value) =>
      value ? commandFlags |= flagErrorBit : commandFlags &= ~flagErrorBit;

  bool get isRetransmit => (commandFlags & flagRetransmitBit) != 0;
  set isRetransmit(bool value) => value
      ? commandFlags |= flagRetransmitBit
      : commandFlags &= ~flagRetransmitBit;

  factory MessageHeader.fromBytes(Uint8List data) {
    if (data.length < 20) throw "Invalid header length";
    var bd = ByteData.view(data.buffer, data.offsetInBytes, 20);
    var vLen = bd.getUint32(0);
    var fCode = bd.getUint32(4);
    return MessageHeader(
      version: vLen >> 24,
      length: vLen & 0x00ffffff,
      commandFlags: fCode >> 24,
      commandCode: fCode & 0x00ffffff,
      applicationId: bd.getUint32(8),
      hopByHopId: bd.getUint32(12),
      endToEndId: bd.getUint32(16),
    );
  }

  Uint8List asBytes() {
    var bd = ByteData(20);
    bd.setUint32(0, (version << 24) | length);
    bd.setUint32(4, (commandFlags << 24) | commandCode);
    bd.setUint32(8, applicationId);
    bd.setUint32(12, hopByHopId);
    bd.setUint32(16, endToEndId);
    return bd.buffer.asUint8List();
  }
}

/// A base class for every diameter message that is defined with strong types.
abstract class DefinedMessage extends Message implements AvpGenerator {
  @override
  List<Avp> additionalAvps = [];

  DefinedMessage({super.header, super.avps}) {
    if (avps.isNotEmpty) {
      assignAttributesFromAvps(this, avps);
    }
  }

  @override
  List<Avp> get avps {
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
