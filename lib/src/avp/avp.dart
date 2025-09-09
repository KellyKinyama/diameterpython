/// AVP and AVP type definitions.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:diameter/src/errors.dart';

import '../../diameter.dart';
import '../dictionary.dart';
import '../packer.dart';

/// A generic AVP type.
///
/// Represents a single Diameter AVP. This class is typically not instantiated
/// directly. Instead, subclasses like [AvpInteger64], [AvpTime], etc., are used,
/// or AVPs are created using the [Avp.newAvp] factory.
class Avp {
  static const int flagVendor = 0x80;
  static const int flagMandatory = 0x40;
  static const int flagPrivate = 0x20;

  /// AVP code. Corresponds to `AVP_*` constant values.
  int code;

  /// The name of the AVP, e.g. "Session-Id". Not unique in any way.
  String name = "Unknown";

  /// AVP flags. These should not be set manually; refer to [isMandatory],
  /// [isPrivate], and [vendorId].
  int flags;

  /// The actual AVP payload as encoded bytes.
  Uint8List payload=Uint8List(0);

  int _vendorId;

  Avp({
    this.code = 0,
    int vendorId = 0,
    this.payload = const [],
    this.flags = 0,
  }) : _vendorId = vendorId {
    // Set vendorId through the setter to update flags correctly.
    this.vendorId = vendorId;
  }

  /// The entire length of the AVP in bytes, including header and vendor ID.
  int get length {
    if (payload.isEmpty) {
      return 0;
    }
    var headerLength = 8;
    if (vendorId != 0) {
      headerLength += 4;
    }
    // Account for padding
    var paddedPayloadLength = (payload.length + 3) & ~3;
    return headerLength + paddedPayloadLength;
  }

  /// Indicates if the AVP is vendor-specific.
  bool get isVendor => vendorId != 0;

  /// Indicates if the mandatory (M) flag is set.
  bool get isMandatory => (flags & flagMandatory) != 0;

  /// Sets or unsets the mandatory (M) flag.
  set isMandatory(bool value) {
    if (value) {
      flags |= flagMandatory;
    } else {
      flags &= ~flagMandatory;
    }
  }

  /// Indicates if the private (P) flag is set.
  bool get isPrivate => (flags & flagPrivate) != 0;

  /// Sets or unsets the private (P) flag.
  set isPrivate(bool value) {
    if (value) {
      flags |= flagPrivate;
    } else {
      flags &= ~flagPrivate;
    }
  }

  /// The current vendor ID. When modified, the AVP flags are also updated.
  int get vendorId => _vendorId;

  /// Sets a new vendor ID and updates the vendor flag.
  set vendorId(int value) {
    if (value != 0) {
      flags |= flagVendor;
    } else {
      flags &= ~flagVendor;
    }
    _vendorId = value;
  }

  /// The actual AVP value, decoded to a Dart type.
  dynamic get value => payload;

  /// Sets the AVP value from a Dart type, encoding it to the payload.
  set value(dynamic newValue) {
    if (newValue is Uint8List) {
      payload = newValue;
    } else {
      throw AvpEncodeError(
        "$name value $newValue is not a Uint8List for base Avp type",
      );
    }
  }

  /// Serializes the AVP to its byte representation.
  Uint8List asBytes() {
    final packer = Packer();
    asPacked(packer);
    return packer.buffer;
  }

  /// Appends the AVP's byte representation to a [Packer] instance.
  void asPacked(Packer packer) {
    packer.packUint(code);
    // Length includes header, vendorId (if present) and padded payload
    var paddedPayloadLength = (payload.length + 3) & ~3;
    var headerLength = 8 + (isVendor ? 4 : 0);
    packer.packUint((flags << 24) | (headerLength + paddedPayloadLength));
    if (isVendor) {
      packer.packUint(vendorId);
    }
    packer.packFopaque(payload.length, payload);
  }

  @override
  String toString() {
    final flagsStr = [
      isVendor ? 'V' : '-',
      isMandatory ? 'M' : '-',
      isPrivate ? 'P' : '-',
    ].join();
    final vendorStr = isVendor ? ", Vnd: ${VENDORS[vendorId] ?? vendorId}" : "";

    // Avoid showing long byte arrays
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

  /// Factory method to create an AVP of the correct type from an [Unpacker].
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

  /// Factory method to create a new AVP instance based on its code and vendor.
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

/// A class representing an Address AVP type.
class AvpAddress extends Avp {
  AvpAddress({super.code, super.vendorId, required super.payload, super.flags});

  @override
  (int, String) get value {
    if (payload.length < 2) {
      throw AvpDecodeError("$name payload is too short for Address type");
    }
    final bd = ByteData.view(
      payload.buffer,
      payload.offsetInBytes,
      payload.length,
    );
    final addrType = bd.getUint16(0, Endian.big);
    final addrBytes = payload.sublist(2);

    switch (addrType) {
      case 1: // IPv4
        return (addrType, InternetAddress.fromRawAddress(addrBytes).address);
      case 2: // IPv6
        return (addrType, InternetAddress.fromRawAddress(addrBytes).address);
      case 8: // E.164
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
    if (newValue is! String) {
      throw AvpEncodeError("$name value must be a String");
    }
    try {
      final addr = InternetAddress(newValue);
      if (addr.type == InternetAddressType.IPv4) {
        final builder = BytesBuilder();
        builder.add(
          Uint8List(2)..buffer.asByteData().setUint16(0, 1, Endian.big),
        );
        builder.add(addr.rawAddress);
        payload = builder.toBytes();
        return;
      } else if (addr.type == InternetAddressType.IPv6) {
        final builder = BytesBuilder();
        builder.add(
          Uint8List(2)..buffer.asByteData().setUint16(0, 2, Endian.big),
        );
        builder.add(addr.rawAddress);
        payload = builder.toBytes();
        return;
      }
    } catch (_) {
      // Not an IP address, assume E.164
    }

    // E.164
    final builder = BytesBuilder();
    builder.add(Uint8List(2)..buffer.asByteData().setUint16(0, 8, Endian.big));
    builder.add(utf8.encode(newValue));
    payload = builder.toBytes();
  }
}


/// A class representing an Integer32 AVP type.
class AvpInteger32 extends Avp {
  AvpInteger32({super.code, super.vendorId, required super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 4) throw AvpDecodeError("Invalid length for Integer32");
    return ByteData.view(payload.buffer, payload.offsetInBytes, 4).getInt32(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(4)..buffer.asByteData().setInt32(0, newValue, Endian.big);
  }
}

/// A class representing a Grouped AVP type.
class AvpGrouped extends Avp {
  List<Avp>? _avps;

  AvpGrouped({super.code, super.vendorId, required super.payload, super.flags});

  @override
  List<Avp> get value {
    _avps ??= _decodeGrouped();
    return _avps!;
  }
  
  List<Avp> _decodeGrouped() {
    final unpacker = Unpacker(payload);
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

// Other type definitions (Float32, Float64, Integer64, Unsigned32, Unsigned64, OctetString, UTF8String) follow a similar pattern.
// For brevity, I'm including the more complex 'AvpTime' and the 'AvpEnumerated' typedef.

/// An AVP type that implements the "Time" type.
class AvpTime extends Avp {
  // Seconds between 1900-01-01 and 1970-01-01
  static const int secondsSince1900 = 2208988800;

  AvpTime({super.code, super.vendorId, required super.payload, super.flags});

  @override
  DateTime get value {
    if (payload.length != 4) {
      throw AvpDecodeError("Invalid length for Time AVP");
    }
    final secondsNtp = ByteData.view(payload.buffer, payload.offsetInBytes, 4)
        .getUint32(0, Endian.big);
    final secondsUnix = secondsNtp - secondsSince1900;
    return DateTime.fromMillisecondsSinceEpoch(secondsUnix * 1000, isUtc: true);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! DateTime) {
      throw AvpEncodeError("$name value must be a DateTime");
    }
    final secondsUnix = newValue.toUtc().millisecondsSinceEpoch ~/ 1000;
    final secondsNtp = secondsUnix + secondsSince1900;
    payload = Uint8List(4)
      ..buffer.asByteData().setUint32(0, secondsNtp, Endian.big);
  }
}
// Add these classes to lib/src/avp/avp.dart

/// An AVP type that implements "Float32".
class AvpFloat32 extends Avp {
  AvpFloat32({super.code, super.vendorId, required super.payload, super.flags});

  @override
  double get value {
    if (payload.length != 4) throw AvpDecodeError("Invalid length for Float32");
    return ByteData.view(payload.buffer, payload.offsetInBytes, 4).getFloat32(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! num) throw AvpEncodeError("Value must be a number");
    payload = Uint8List(4)..buffer.asByteData().setFloat32(0, newValue.toDouble(), Endian.big);
  }
}


/// An AVP type that implements "Float64".
class AvpFloat64 extends Avp {
  AvpFloat64({super.code, super.vendorId, required super.payload, super.flags});

  @override
  double get value {
    if (payload.length != 8) throw AvpDecodeError("Invalid length for Float64");
    return ByteData.view(payload.buffer, payload.offsetInBytes, 8).getFloat64(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! num) throw AvpEncodeError("Value must be a number");
    payload = Uint8List(8)..buffer.asByteData().setFloat64(0, newValue.toDouble(), Endian.big);
  }
}


/// An AVP type that implements "Integer64".
class AvpInteger64 extends Avp {
  AvpInteger64({super.code, super.vendorId, required super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 8) throw AvpDecodeError("Invalid length for Integer64");
    return ByteData.view(payload.buffer, payload.offsetInBytes, 8).getInt64(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(8)..buffer.asByteData().setInt64(0, newValue, Endian.big);
  }
}


/// An AVP type that implements "Unsigned32".
class AvpUnsigned32 extends Avp {
  AvpUnsigned32({super.code, super.vendorId, required super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 4) throw AvpDecodeError("Invalid length for Unsigned32");
    return ByteData.view(payload.buffer, payload.offsetInBytes, 4).getUint32(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(4)..buffer.asByteData().setUint32(0, newValue, Endian.big);
  }
}


/// An AVP type that implements "Unsigned64".
class AvpUnsigned64 extends Avp {
  AvpUnsigned64({super.code, super.vendorId, required super.payload, super.flags});

  @override
  int get value {
    if (payload.length != 8) throw AvpDecodeError("Invalid length for Unsigned64");
    return ByteData.view(payload.buffer, payload.offsetInBytes, 8).getUint64(0, Endian.big);
  }

  @override
  set value(dynamic newValue) {
    if (newValue is! int) throw AvpEncodeError("Value must be an int");
    payload = Uint8List(8)..buffer.asByteData().setUint64(0, newValue, Endian.big);
  }
}


/// An AVP type that implements "OctetString".
class AvpOctetString extends Avp {
  AvpOctetString({super.code, super.vendorId,required super.payload, super.flags});

  @override
  Uint8List get value => payload;

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
  AvpUtf8String({super.code, super.vendorId, required super.payload, super.flags});

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
      payload = utf8.encode(newValue);
    } catch (e) {
      throw AvpEncodeError("$name value cannot be encoded as UTF-8: $e");
    }
  }
}

/// An alias for AvpInteger32, as Enumerated is functionally identical.
typedef AvpEnumerated = AvpInteger32;
