
/// A Re-Auth message (RAR/RAA).
///
/// See RFC 6733 for details.
abstract class ReAuth extends DefinedMessage {
  static const int CODE = 258;
  static const String NAME = "Re-Auth";

  @override
  int get code => CODE;
  @override
  String get name => NAME;

  ReAuth({super.header, super.avps});

  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return ReAuthRequest(header: header);
    } else {
      return ReAuthAnswer(header: header);
    }
  }
}

/// A Re-Auth-Answer message.
class ReAuthAnswer extends ReAuth {
  String? sessionId;
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  String? userName;
  // ... other properties

  ReAuthAnswer({super.header, super.avps}) {
    header.isRequest = false;
    header.isProxyable = true;
    assignAttributesFromAvps(this, avps);
    super.avps = [];
  }

  @override
  AvpGenType get avpDef => const [
        AvpGenDef("session_id", AVP_SESSION_ID, isRequired: true),
        AvpGenDef("result_code", AVP_RESULT_CODE, isRequired: true),
        AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
        AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
        // ... Other AVP definitions omitted for brevity
      ];
  
  // AVP Generator implementations omitted for brevity.
}

/// A Re-Auth-Request message.
class ReAuthRequest extends ReAuth {
  String? sessionId;
  Uint8List? originHost;
  Uint8List? originRealm;
  Uint8List? destinationRealm;
  Uint8List? destinationHost;
  int? authApplicationId;
  int? reAuthRequestType;
  // ... other properties

  ReAuthRequest({super.header, super.avps}) {
    header.isRequest = true;
    header.isProxyable = true;
    authApplicationId = 0; // Per RFC 6733
    assignAttributesFromAvps(this, avps);
    super.avps = [];
  }

  @override
  AvpGenType get avpDef => const [
        AvpGenDef("session_id", AVP_SESSION_ID, isRequired: true),
        AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
        AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
        AvpGenDef("destination_realm", AVP_DESTINATION_REALM, isRequired: true),
        AvpGenDef("auth_application_id", AVP_AUTH_APPLICATION_ID, isRequired: true),
        AvpGenDef("re_auth_request_type", AVP_RE_AUTH_REQUEST_TYPE, isRequired: true),
        // ... Other AVP definitions omitted for brevity
      ];

  // AVP Generator implementations omitted for brevity.
}
