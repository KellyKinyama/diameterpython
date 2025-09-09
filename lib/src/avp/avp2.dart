import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:diameter_app/src/errors.dart';
import '../../diameter.dart';
import '../dictionary.dart';
import '../packer.dart';

/// A generic AVP type.
class Avp {
  static const int flagVendor = 0x80;
  static const int flagMandatory = 0x40;
  static const int flagPrivate = 0x20;

  int code;
  String name = "Unknown";
  int flags;
  List<int> payload;
  int _vendorId;

  Avp({
    this.code = 0,
    int vendorId = 0,
    this.payload = const [],
    this.flags = 0,
  }) : _vendorId = vendorId {
    this.vendorId = vendorId;
  }

  int get length {
    var headerLength = 8;
    if (vendorId != 0) {
      headerLength += 4;
    }
    var paddedPayloadLength = (payload.length + 3) & ~3;
    return headerLength + paddedPayloadLength;
  }

  bool get isVendor => vendorId != 0;
  bool get isMandatory => (flags & flagMandatory) != 0;
  set isMandatory(bool value) {
    if (value) {
      flags |= flagMandatory;
    } else {
      flags &= ~flagMandatory;
    }
  }

  bool get isPrivate => (flags & flagPrivate) != 0;
  set isPrivate(bool value) {
    if (value) {
      flags |= flagPrivate;
    } else {
      flags &= ~flagPrivate;
    }
  }

  int get vendorId => _vendorId;
  set vendorId(int value) {
    if (value != 0) {
      flags |= flagVendor;
    } else {
      flags &= ~flagVendor;
    }
    _vendorId = value;
  }

  dynamic get value => payload;
  set value(dynamic newValue) {
    if (newValue is Uint8List) {
      payload = newValue;
    } else {
      throw AvpEncodeError(
        "$name value $newValue is not a Uint8List for base Avp type",
      );
    }
  }

  Uint8List asBytes() {
    final packer = Packer();
    asPacked(packer);
    return packer.buffer;
  }

  void asPacked(Packer packer) {
    packer.packUint(code);
    var paddedPayloadLength = (payload.length + 3) & ~3;
    var headerLength = 8 + (isVendor ? 4 : 0);
    packer.packUint((flags << 24) | (headerLength + paddedPayloadLength));
    if (isVendor) {
      packer.packUint(vendorId);
    }
    packer.packFopaque(payload.length, Uint8List.fromList(payload));
  }

  @override
  String toString() {
    final flagsStr = [
      isVendor ? 'V' : '-',
      isMandatory ? 'M' : '-',
      isPrivate ? 'P' : '-',
    ].join();
    final vendorStr = isVendor ? ", Vnd: ${VENDORS[vendorId] ?? vendorId}" : "";
    dynamic displayValue;
    try {
      displayValue = value;
      if (displayValue is List &&
          displayValue.isNotEmpty &&
          displayValue.first is Avp) {
        displayValue =
            "\n  " + displayValue.map((avp) => avp.toString()).join("\n  ");
      } else if (displayValue is Uint8List) {
        displayValue =
            "0x${displayValue.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}";
      }
    } catch (e) {
      displayValue = "Error decoding value";
    }
    return "$name <Code: 0x${code.toRadixString(16)}, Flags: 0x${flags.toRadixString(16).padLeft(2, '0')} ($flagsStr), Length: $length$vendorStr, Val: $displayValue>";
  }

  static Avp fromBytes(Uint8List data) {
    try {
      return Avp.fromUnpacker(Unpacker(data));
    } catch (e) {
      throw AvpDecodeError("Not possible to create AVP from byte input: $e");
    }
  }

  static Avp fromUnpacker(Unpacker unpacker) {
    final avpCode = unpacker.unpackUint();
    final flagsAndLength = unpacker.unpackUint();
    final avpFlags = flagsAndLength >> 24;
    final avpLength = flagsAndLength & 0x00ffffff;

    var headerSize = 8;
    var avpVendorId = 0;
    if ((avpFlags & Avp.flagVendor) != 0) {
      avpVendorId = unpacker.unpackUint();
      headerSize = 12;
    }

    final payloadLength = avpLength - headerSize;
    Uint8List avpPayload = Uint8List(0);
    if (payloadLength > 0) {
      avpPayload = unpacker.unpackFopaque(payloadLength);
    }

    Map<String, dynamic>? def =
        AVP_VENDOR_DICTIONARY[avpVendorId]?[avpCode] ?? AVP_DICTIONARY[avpCode];
    Type avpType = def?['type'] ?? Avp;
    String avpName = def?['name'] ?? "Unknown";

    Avp avp;
    // This part correctly passes the payload during parsing
    if (avpType == AvpAddress) {
      avp = AvpAddress(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpFloat32) {
      avp = AvpFloat32(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpFloat64) {
      avp = AvpFloat64(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpGrouped) {
      avp = AvpGrouped(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpInteger32) {
      avp = AvpInteger32(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpInteger64) {
      avp = AvpInteger64(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpOctetString) {
      avp = AvpOctetString(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpUnsigned32) {
      avp = AvpUnsigned32(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpUnsigned64) {
      avp = AvpUnsigned64(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpUtf8String) {
      avp = AvpUtf8String(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else if (avpType == AvpTime) {
      avp = AvpTime(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    } else {
      avp = Avp(
        code: avpCode,
        vendorId: avpVendorId,
        payload: avpPayload,
        flags: avpFlags,
      );
    }

    avp.name = avpName;
    return avp;
  }

  static Avp newAvp(
    int avpCode, {
    int vendorId = 0,
    dynamic value,
    bool? isMandatory,
    bool? isPrivate,
  }) {
    Map<String, dynamic>? def =
        AVP_VENDOR_DICTIONARY[vendorId]?[avpCode] ?? AVP_DICTIONARY[avpCode];

    if (def == null) {
      throw ArgumentError("AVP code $avpCode with vendor $vendorId is unknown");
    }

    Type avpType = def['type'];
    Avp avp;

    // This part correctly creates empty AVPs without a payload
    if (avpType == AvpAddress) {
      avp = AvpAddress(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpFloat32) {
      avp = AvpFloat32(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpFloat64) {
      avp = AvpFloat64(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpGrouped) {
      avp = AvpGrouped(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpInteger32) {
      avp = AvpInteger32(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpInteger64) {
      avp = AvpInteger64(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpOctetString) {
      avp = AvpOctetString(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpUnsigned32) {
      avp = AvpUnsigned32(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpUnsigned64) {
      avp = AvpUnsigned64(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpUtf8String) {
      avp = AvpUtf8String(code: avpCode, vendorId: vendorId);
    } else if (avpType == AvpTime) {
      avp = AvpTime(code: avpCode, vendorId: vendorId);
    } else {
      avp = Avp(code: avpCode, vendorId: vendorId);
    }

    avp.name = def['name'];
    avp.isMandatory = isMandatory ?? def['mandatory'] ?? false;
    if (isPrivate != null) {
      avp.isPrivate = isPrivate;
    }

    if (value != null) {
      avp.value = value;
    }

    return avp;
  }
}

// --- Corrected Constructors for AVP Subclasses ---

/// A class representing an Address AVP type.
class AvpAddress extends Avp {
  AvpAddress({super.code, super.vendorId, super.payload, super.flags});

  @override
  (int, String) get value {
    if (payload.length < 2) {
      throw AvpDecodeError("$name payload is too short for Address type");
    }
    final payloadBytes = Uint8List.fromList(payload);
    final bd = ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      payload.length,
    );
    final addrType = bd.getUint16(0, Endian.big);
    final addrBytes = payload.sublist(2);

    switch (addrType) {
      case 1:
        return (
          addrType,
          InternetAddress.fromRawAddress(Uint8List.fromList(addrBytes)).address,
        );
      case 2:
        return (
          addrType,
          InternetAddress.fromRawAddress(Uint8List.fromList(addrBytes)).address,
        );
      case 8:
        return (addrType, utf8.decode(addrBytes));
      default:
        return (
          addrType,
          addrBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        );
    }
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! String)
      throw AvpEncodeError("$name value must be a String");
    try {
      final addr = InternetAddress(newValue);
      if (addr.type == InternetAddressType.IPv4) {
        final builder = BytesBuilder()
          ..add(Uint8List(2)..buffer.asByteData().setUint16(0, 1, Endian.big))
          ..add(addr.rawAddress);
        payload = builder.toBytes();
        return;
      } else if (addr.type == InternetAddressType.IPv6) {
        final builder = BytesBuilder()
          ..add(Uint8List(2)..buffer.asByteData().setUint16(0, 2, Endian.big))
          ..add(addr.rawAddress);
        payload = builder.toBytes();
        return;
      }
    } catch (_) {
      /* Not an IP, assume E.164 */
    }

    final builder = BytesBuilder()
      ..add(Uint8List(2)..buffer.asByteData().setUint16(0, 8, Endian.big))
      ..add(utf8.encode(newValue));
    payload = builder.toBytes();
  }
}

/// An AVP type that implements "Float32".
class AvpFloat32 extends Avp {
  AvpFloat32({super.code, super.vendorId, super.payload, super.flags});

  @override
  double get value {
    if (payload.length != 4) throw AvpDecodeError("Invalid length for Float32");
    final payloadBytes = Uint8List.fromList(payload);
    return ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      4,
    ).getFloat32(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! num) throw AvpEncodeError("Value must be a number");
    payload = Uint8List(4)
      ..buffer.asByteData().setFloat32(0, newValue.toDouble(), Endian.big);
  }
}

/// An AVP type that implements "Float64".
class AvpFloat64 extends Avp {
  AvpFloat64({super.code, super.vendorId, super.payload, super.flags});

  @override
  double get value {
    if (payload.length != 8) throw AvpDecodeError("Invalid length for Float64");
    final payloadBytes = Uint8List.fromList(payload);
    return ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      8,
    ).getFloat64(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! num) throw AvpEncodeError("Value must be a number");
    payload = Uint8List(8)
      ..buffer.asByteData().setFloat64(0, newValue.toDouble(), Endian.big);
  }
}

/// A class representing an Integer32 AVP type.
class AvpInteger32 extends Avp {
  AvpInteger32({super.code, super.vendorId, super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 4)
      throw AvpDecodeError("Invalid length for Integer32");
    final payloadBytes = Uint8List.fromList(payload);
    return ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      4,
    ).getInt32(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(4)
      ..buffer.asByteData().setInt32(0, newValue, Endian.big);
  }
}

/// An AVP type that implements "Integer64".
class AvpInteger64 extends Avp {
  AvpInteger64({super.code, super.vendorId, super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 8)
      throw AvpDecodeError("Invalid length for Integer64");
    final payloadBytes = Uint8List.fromList(payload);
    return ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      8,
    ).getInt64(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(8)
      ..buffer.asByteData().setInt64(0, newValue, Endian.big);
  }
}

/// An AVP type that implements "Unsigned32".
class AvpUnsigned32 extends Avp {
  AvpUnsigned32({super.code, super.vendorId, super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 4)
      throw AvpDecodeError("Invalid length for Unsigned32");
    final payloadBytes = Uint8List.fromList(payload);
    return ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      4,
    ).getUint32(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(4)
      ..buffer.asByteData().setUint32(0, newValue, Endian.big);
  }
}

/// An AVP type that implements "Unsigned64".
class AvpUnsigned64 extends Avp {
  AvpUnsigned64({super.code, super.vendorId, super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 8)
      throw AvpDecodeError("Invalid length for Unsigned64");
    final payloadBytes = Uint8List.fromList(payload);
    return ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      8,
    ).getUint64(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(8)
      ..buffer.asByteData().setUint64(0, newValue, Endian.big);
  }
}

/// An AVP type that implements "OctetString".
class AvpOctetString extends Avp {
  AvpOctetString({super.code, super.vendorId, super.payload, super.flags});

  @override
  Uint8List get value => Uint8List.fromList(payload);

  @override
  set value(dynamic newValue) {
    if (newValue is! Uint8List) {
      throw AvpEncodeError("$name value must be a Uint8List");
    }
    payload = newValue;
  }
}

/// An AVP type that implements "UTF8String".
class AvpUtf8String extends Avp {
  AvpUtf8String({super.code, super.vendorId, super.payload, super.flags});

  @override
  String get value {
    try {
      return utf8.decode(payload);
    } catch (e) {
      throw AvpDecodeError("$name value cannot be decoded as UTF-8: $e");
    }
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! String) {
      throw AvpEncodeError("$name value must be a String");
    }
    try {
      payload = utf8.encode(newValue) as Uint8List;
    } catch (e) {
      throw AvpEncodeError("$name value cannot be encoded as UTF-8: $e");
    }
  }
}

/// A class representing a Grouped AVP type.
class AvpGrouped extends Avp {
  List<Avp>? _avps;

  AvpGrouped({super.code, super.vendorId, super.payload, super.flags});

  @override
  List<Avp> get value {
    _avps ??= _decodeGrouped();
    return _avps!;
  }

  List<Avp> _decodeGrouped() {
    final unpacker = Unpacker(Uint8List.fromList(payload));
    final avps = <Avp>[];
    while (!unpacker.isDone()) {
      try {
        avps.add(Avp.fromUnpacker(unpacker));
      } catch (e) {
        throw AvpDecodeError("$name grouped value contains invalid AVPs: $e");
      }
    }
    return avps;
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! List<Avp>) {
      throw AvpEncodeError("Grouped AVP value must be a List<Avp>");
    }
    _avps = newValue;
    final packer = Packer();
    for (var avp in _avps!) {
      avp.asPacked(packer);
    }
    payload = packer.buffer;
  }
}

/// An AVP type that implements the "Time" type.
class AvpTime extends Avp {
  static const int secondsSince1900 = 2208988800;

  AvpTime({super.code, super.vendorId, super.payload, super.flags});

  @override
  DateTime get value {
    if (payload.length != 4) {
      throw AvpDecodeError("Invalid length for Time AVP");
    }
    final payloadBytes = Uint8List.fromList(payload);
    final secondsNtp = ByteData.view(
      payloadBytes.buffer,
      payloadBytes.offsetInBytes,
      4,
    ).getUint32(0, Endian.big);
    final secondsUnix = secondsNtp - secondsSince1900;
    return DateTime.fromMillisecondsSinceEpoch(secondsUnix * 1000, isUtc: true);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! DateTime)
      throw AvpEncodeError("$name value must be a DateTime");
    final secondsUnix = newValue.toUtc().millisecondsSinceEpoch ~/ 1000;
    final secondsNtp = secondsUnix + secondsSince1900;
    payload = Uint8List(4)
      ..buffer.asByteData().setUint32(0, secondsNtp, Endian.big);
  }
}

/// An alias for AvpInteger32, as Enumerated is functionally identical.
typedef AvpEnumerated = AvpInteger32;
