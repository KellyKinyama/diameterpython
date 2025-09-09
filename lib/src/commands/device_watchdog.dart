
import 'dart:typed_data';

/// A Device-Watchdog message (DWR/DWA).
///
/// See RFC 6733 for details.
abstract class DeviceWatchdog extends DefinedMessage {
  static const int CODE = 280;
  static const String NAME = "Device-Watchdog";

  @override
  int get code => CODE;
  @override
  String get name => NAME;

  DeviceWatchdog({super.header, super.avps});

  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return DeviceWatchdogRequest(header: header);
    } else {
      return DeviceWatchdogAnswer(header: header);
    }
  }
}

/// A Device-Watchdog-Answer message.
class DeviceWatchdogAnswer extends DeviceWatchdog {
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  String? errorMessage;
  FailedAvp? failedAvp;
  int? originStateId;

  DeviceWatchdogAnswer({super.header, super.avps}) {
    header.isRequest = false;
    assignAttributesFromAvps(this, avps);
    super.avps = [];
  }

  @override
  AvpGenType get avpDef => const [
        AvpGenDef("result_code", AVP_RESULT_CODE, isRequired: true),
        AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
        AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
        AvpGenDef("error_message", AVP_ERROR_MESSAGE, isMandatory: false),
        AvpGenDef("failed_avp", AVP_FAILED_AVP, typeClass: FailedAvp),
        AvpGenDef("origin_state_id", AVP_ORIGIN_STATE_ID),
      ];
  
  // AVP Generator implementations
  // Note: toMap() and updateFromMap() are omitted for brevity but would be here.
}

/// A Device-Watchdog-Request message.
class DeviceWatchdogRequest extends DeviceWatchdog {
  Uint8List? originHost;
  Uint8List? originRealm;
  int? originStateId;

  DeviceWatchdogRequest({super.header, super.avps}) {
    header.isRequest = true;
    assignAttributesFromAvps(this, avps);
    super.avps = [];
  }

  @override
  AvpGenType get avpDef => const [
        AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
        AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
        AvpGenDef("origin_state_id", AVP_ORIGIN_STATE_ID),
      ];

  // AVP Generator implementations
  // Note: toMap() and updateFromMap() are omitted for brevity but would be here.
}
