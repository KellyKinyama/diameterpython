import '../../diameter.dart';

/// Populates the properties of a [DefinedMessage] from a list of raw AVPs.
void assignAttributesFromAvps(DefinedMessage message, List<Avp> avps) {
  final map = message.toMap();

  for (var def in message.avpDef) {
    var foundAvps = avps
        .where((avp) => avp.code == def.avpCode && avp.vendorId == def.vendorId)
        .toList();
    if (foundAvps.isEmpty) {
      continue;
    }

    // Check if the target property is a List
    final isListProperty = map[def.attrName] is List;

    if (isListProperty) {
      final list = map[def.attrName] as List;
      for (var avp in foundAvps) {
        if (def.typeClass != null) {
          // It's a list of grouped AVPs
          var groupedInstance = _createGroupedInstance(
            def.typeClass!,
            (avp as AvpGrouped).value,
          );
          list.add(groupedInstance);
        } else {
          // It's a list of simple AVPs
          list.add(avp.value);
        }
      }
    } else {
      // It's a single property
      var avp = foundAvps.first;
      if (def.typeClass != null) {
        // It's a single grouped AVP
        var groupedInstance = _createGroupedInstance(
          def.typeClass!,
          (avp as AvpGrouped).value,
        );
        map[def.attrName] = groupedInstance;
      } else {
        // It's a single simple AVP
        map[def.attrName] = avp.value;
      }
    }
  }

  // Assign any remaining AVPs to additionalAvps
  final definedAvps = message.avpDef
      .map((def) => '${def.avpCode}:${def.vendorId}')
      .toSet();
  message.additionalAvps.addAll(
    avps.where((avp) => !definedAvps.contains('${avp.code}:${avp.vendorId}')),
  );

  // Update the message instance with the populated map
  message.updateFromMap(map);
}

// A helper to instantiate grouped AVP classes. In a real application, you might
// use a factory or reflection/code generation for this.
// dynamic _createGroupedInstance(Type type, List<Avp> avps) {
//     // This is a simplified factory. A full implementation might use reflection
//     // or a map of constructors for better scalability.
//     if (type == VendorSpecificApplicationId) return VendorSpecificApplicationId.fromAvps(avps);
//     if (type == FailedAvp) return FailedAvp.fromAvps(avps);
//     // Add other grouped types here...

//     // Fallback for unhandled types
//     final instance = UndefinedGroupedAvp();
//     (instance as dynamic)._assignAttrValues(instance, avps);
//     return instance;
// }

dynamic _createGroupedInstance(Type type, List<Avp> avps) {
  if (type == VendorSpecificApplicationId) {
    return VendorSpecificApplicationId.fromAvps(avps);
  }
  // if (type == FailedAvp) return FailedAvp.fromAvps(avps);
  // if (type == SipAuthDataItem) return SipAuthDataItem.fromAvps(avps);
  // if (type == ServerCapabilities) return ServerCapabilities.fromAvps(avps);
  // if (type == MipMnAaaAuth) return MipMnAaaAuth.fromAvps(avps);
  // // ... add an entry for every grouped AVP data class

  // final instance = UndefinedGroupedAvp();
  // (instance as dynamic)._assignAttrValues(instance, avps);
  throw UnimplementedError('Factory for type $type is not implemented.');
  // return instance;
}
