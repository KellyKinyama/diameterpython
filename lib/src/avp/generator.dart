import '../../diameter.dart';

/// A class that defines the mapping of a class attribute to an AVP.
class AvpGenDef {
  /// The class attribute name that holds the value for the AVP.
  final String attrName;

  /// An AVP code that the actual AVP will be generated from.
  final int avpCode;

  /// A vendor ID to pass on to AVP generation.
  final int vendorId;

  /// Indicates that the class attribute must be set.
  final bool isRequired;

  /// Overwrites the default mandatory flag provided by AVP dictionary.
  final bool? isMandatory;

  /// For grouped AVPs, indicates the type of another class that holds the
  /// attributes needed for the grouped sub-AVPs.
  final Type? typeClass;

  const AvpGenDef(
    this.attrName,
    this.avpCode, {
    this.vendorId = 0,
    this.isRequired = false,
    this.isMandatory,
    this.typeClass,
  });
}

/// A typedef for a list of AVP generation definitions.
typedef AvpGenType = List<AvpGenDef>;

/// A contract for classes that can generate a list of AVPs from their properties.
abstract class AvpGenerator {
  /// A list containing AVP generation definitions.
  AvpGenType get avpDef;

  /// A list of additional, non-defined AVPs.
  List<Avp> get additionalAvps;

  /// A map representation of the object's properties.
  Map<String, dynamic> toMap();
  void updateFromMap(Map<String, dynamic> map); // ADD THIS LINE
}

/// Traverses an [AvpGenerator] object and returns a complete list of AVPs.
List<Avp> generateAvpsFromDefs(AvpGenerator obj, {bool strict = false}) {
  final avpList = <Avp>[];
  final objMap = obj.toMap();

  for (final genDef in obj.avpDef) {
    final attrValue = objMap[genDef.attrName];

    if (attrValue == null) {
      if (genDef.isRequired) {
        final msg = "Mandatory AVP attribute `${genDef.attrName}` is not set";
        if (strict) {
          throw ArgumentError(msg);
        }
      }
      continue;
    }

    try {
      if (attrValue is List) {
        for (final value in attrValue) {
          if (value == null) continue;
          if (genDef.typeClass != null && value is AvpGenerator) {
            final subAvps = generateAvpsFromDefs(value, strict: strict);
            avpList.add(
              Avp.newAvp(
                genDef.avpCode,
                vendorId: genDef.vendorId,
                isMandatory: genDef.isMandatory,
                value: subAvps,
              ),
            );
          } else {
            avpList.add(
              Avp.newAvp(
                genDef.avpCode,
                vendorId: genDef.vendorId,
                isMandatory: genDef.isMandatory,
                value: value,
              ),
            );
          }
        }
      } else {
        if (genDef.typeClass != null && attrValue is AvpGenerator) {
          final subAvps = generateAvpsFromDefs(attrValue, strict: strict);
          avpList.add(
            Avp.newAvp(
              genDef.avpCode,
              vendorId: genDef.vendorId,
              isMandatory: genDef.isMandatory,
              value: subAvps,
            ),
          );
        } else {
          avpList.add(
            Avp.newAvp(
              genDef.avpCode,
              vendorId: genDef.vendorId,
              isMandatory: genDef.isMandatory,
              value: attrValue,
            ),
          );
        }
      }
    } on AvpEncodeError catch (e) {
      throw AvpEncodeError(
        "Failed to parse value for attribute `${genDef.attrName}`: $e",
      );
    }
  }

  avpList.addAll(obj.additionalAvps);
  return avpList;
}
