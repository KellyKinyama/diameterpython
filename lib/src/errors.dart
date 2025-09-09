/// Common message handling errors.
// part of diameter.src;

/// An exception raised when an AVP value contains data that cannot be
/// decoded into a Dart type.
class AvpDecodeError implements Exception {
  final String message;
  AvpDecodeError(this.message);

  @override
  String toString() => 'AvpDecodeError: $message';
}

/// An exception raised when a value of an AVP has been set to something
/// that the AVP type cannot encode.
class AvpEncodeError implements Exception {
  final String message;
  AvpEncodeError(this.message);

  @override
  String toString() => 'AvpEncodeError: $message';
}
