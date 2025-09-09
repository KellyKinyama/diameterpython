/// XDR-style data packing and unpacking.
// part of diameter.src;

import 'dart:math';
import 'dart:typed_data';

/// An exception raised for packing/unpacking errors.
class ConversionError implements Exception {
  final String message;
  ConversionError(this.message);

  @override
  String toString() => 'ConversionError: $message';
}

/// Packs various data representations into a byte buffer.
class Packer {
  final BytesBuilder _builder = BytesBuilder();
  late final ByteData _buffer;

  Packer() {
    _buffer = ByteData(8);
  }

  /// Resets the internal buffer.
  void reset() {
    _builder.clear();
  }

  /// Returns the packed data as a byte list.
  Uint8List get buffer => _builder.toBytes();

  void _pack(void Function() writeValue, int size) {
    try {
      writeValue();
      _builder.add(_buffer.buffer.asUint8List(0, size));
    } catch (e) {
      throw ConversionError('Packing failed: $e');
    }
  }

  /// Packs a 32-bit unsigned integer.
  void packUint(int x) {
    _pack(() => _buffer.setUint32(0, x, Endian.big), 4);
  }

  /// Packs a 32-bit signed integer.
  void packInt(int x) {
    _pack(() => _buffer.setInt32(0, x, Endian.big), 4);
  }

  void packEnum(int x) => packInt(x);

  /// Packs a boolean value.
  void packBool(bool x) {
    packInt(x ? 1 : 0);
  }

  /// Packs a 64-bit unsigned integer.
  void packUhyper(int x) {
    _pack(() => _buffer.setUint64(0, x, Endian.big), 8);
  }

  void packHyper(int x) => packUhyper(x);

  /// Packs a 32-bit float.
  void packFloat(double x) {
    _pack(() => _buffer.setFloat32(0, x, Endian.big), 4);
  }

  /// Packs a 64-bit float (double).
  void packDouble(double x) {
    _pack(() => _buffer.setFloat64(0, x, Endian.big), 8);
  }

  /// Packs a fixed-length string/opaque data, padding with null bytes.
  void packFopaque(int n, Uint8List s) {
    if (n < 0) {
      throw ConversionError('fopaque size must be non-negative');
    }
    var data = Uint8List(n);
    var len = min(n, s.length);
    data.setRange(0, len, s);
    _builder.add(data);

    var padding = (4 - (n % 4)) % 4;
    if (padding > 0) {
      _builder.add(Uint8List(padding));
    }
  }

  /// Packs a variable-length string/opaque data with its length.
  void packString(Uint8List s) {
    packUint(s.length);
    packFopaque(s.length, s);
  }
}

/// Unpacks various data representations from a byte buffer.
class Unpacker {
  late ByteData _byteData;
  int _position = 0;

  Unpacker(Uint8List data) {
    reset(data);
  }

  /// Resets the unpacker with new data.
  void reset(Uint8List data) {
    _byteData = ByteData.view(
      data.buffer,
      data.offsetInBytes,
      data.lengthInBytes,
    );
    _position = 0;
  }

  int get position => _position;

  void set position(int p) {
    if (p < 0 || p > _byteData.lengthInBytes) {
      throw RangeError('Position out of bounds');
    }
    _position = p;
  }

  Uint8List get buffer => _byteData.buffer.asUint8List();

  bool isDone() => _position >= _byteData.lengthInBytes;

  void done() {
    if (!isDone()) {
      throw ConversionError('Unextracted data remains');
    }
  }

  T _unpack<T>(T Function() readValue, int size) {
    if (_position + size > _byteData.lengthInBytes) {
      throw ConversionError('Not enough bytes left to unpack');
    }
    try {
      final value = readValue();
      _position += size;
      return value;
    } catch (e) {
      throw ConversionError('Unpacking failed: $e');
    }
  }

  /// Unpacks a 32-bit unsigned integer.
  int unpackUint() {
    return _unpack(() => _byteData.getUint32(_position, Endian.big), 4);
  }

  /// Unpacks a 32-bit signed integer.
  int unpackInt() {
    return _unpack(() => _byteData.getInt32(_position, Endian.big), 4);
  }

  int unpackEnum() => unpackInt();

  /// Unpacks a boolean value.
  bool unpackBool() => unpackInt() != 0;

  /// Unpacks a 64-bit unsigned integer.
  int unpackUhyper() {
    return _unpack(() => _byteData.getUint64(_position, Endian.big), 8);
  }

  int unpackHyper() => unpackUhyper();

  /// Unpacks a 32-bit float.
  double unpackFloat() {
    return _unpack(() => _byteData.getFloat32(_position, Endian.big), 4);
  }

  /// Unpacks a 64-bit float (double).
  double unpackDouble() {
    return _unpack(() => _byteData.getFloat64(_position, Endian.big), 8);
  }

  /// Unpacks a fixed-length string/opaque data, accounting for padding.
  Uint8List unpackFopaque(int n) {
    if (n < 0) {
      throw ConversionError('fopaque size must be a positive value');
    }
    final paddedLength = (n + 3) & ~3;
    if (_position + paddedLength > _byteData.lengthInBytes) {
      throw ConversionError('Not enough bytes left to unpack');
    }
    final data = _byteData.buffer.asUint8List(
      _byteData.offsetInBytes + _position,
      n,
    );
    _position += paddedLength;
    return data;
  }

  /// Unpacks a variable-length string/opaque data.
  Uint8List unpackString() {
    final n = unpackUint();
    return unpackFopaque(n);
  }
}
