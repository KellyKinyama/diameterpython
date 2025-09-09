
/// A Disconnect-Peer message (DPR/DPA).
///
/// See RFC 6733 for details.
abstract class DisconnectPeer extends DefinedMessage {
  static const int CODE = 282;
  static const String NAME = "Disconnect-Peer";

  @override
  int get code => CODE;
  @override
  String get name => NAME;

  DisconnectPeer({super.header, super.avps});

  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return DisconnectPeerRequest(header: header);
    } else {
      return DisconnectPeerAnswer(header: header);
    }
  }
}

/// A Disconnect-Peer-Answer message.
class DisconnectPeerAnswer extends DisconnectPeer {
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  String? errorMessage;
  FailedAvp? failedAvp;

  DisconnectPeerAnswer({super.header, super.avps}) {
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
      ];

  // AVP Generator implementations omitted for brevity.
}

/// A Disconnect-Peer-Request message.
class DisconnectPeerRequest extends DisconnectPeer {
  Uint8List? originHost;
  Uint8List? originRealm;
  int? disconnectCause;

  DisconnectPeerRequest({super.header, super.avps}) {
    header.isRequest = true;
    assignAttributesFromAvps(this, avps);
    super.avps = [];
  }

  @override
  AvpGenType get avpDef => const [
        AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
        AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
        AvpGenDef("disconnect_cause", AVP_DISCONNECT_CAUSE, isRequired: true),
      ];

  // AVP Generator implementations omitted for brevity.
}
