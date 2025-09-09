
/// A Session-Termination message (STR/STA).
///
/// See RFC 6733 for details.
abstract class SessionTermination extends DefinedMessage {
  static const int CODE = 275;
  static const String NAME = "Session-Termination";

  @override
  int get code => CODE;
  @override
  String get name => NAME;

  SessionTermination({super.header, super.avps});

  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return SessionTerminationRequest(header: header);
    } else {
      return SessionTerminationAnswer(header: header);
    }
  }
}

/// A Session-Termination-Answer message.
class SessionTerminationAnswer extends SessionTermination {
  String? sessionId;
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  // ... other properties

  SessionTerminationAnswer({super.header, super.avps}) {
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

/// A Session-Termination-Request message.
class SessionTerminationRequest extends SessionTermination {
  String? sessionId;
  Uint8List? originHost;
  Uint8List? originRealm;
  Uint8List? destinationRealm;
  int? authApplicationId;
  int? terminationCause;
  // ... other properties

  SessionTerminationRequest({super.header, super.avps}) {
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
        AvpGenDef("termination_cause", AVP_TERMINATION_CAUSE, isRequired: true),
        // ... Other AVP definitions omitted for brevity
      ];

  // AVP Generator implementations omitted for brevity.
}


void main() {
  // Create a new Session-Termination-Request (STR)
  var str = SessionTerminationRequest();

  // Set header details
  str.header.applicationId = APP_DIAMETER_COMMON_MESSAGES;
  str.header.hopByHopId = 0xcccc3333;
  str.header.endToEndId = 0xdddd4444;

  // Set mandatory STR AVPs
  str.sessionId = "client.example.com;12345;99999";
  str.originHost = utf8.encode("client.example.com") as Uint8List;
  str.originRealm = utf8.encode("example.com") as Uint8List;
  str.destinationRealm = utf8.encode("provider.com") as Uint8List;
  str.destinationHost = utf8.encode("server.provider.com") as Uint8List;
  str.authApplicationId = APP_NASREQ_APPLICATION;
  str.terminationCause = E_TERMINATION_CAUSE_DIAMETER_LOGOUT;
  
  // Set optional AVPs
  str.userName = "user@example.com";
  
  print("--- Original Session Termination Request ---");
  print(str);

  // Encode and Parse
  var strBytes = str.asBytes();
  var parsedMessage = Message.fromBytes(strBytes);
  
  print("\n--- Parsed Message ---");
  print(parsedMessage);

  // Verify and access attributes
  if (parsedMessage is SessionTerminationRequest) {
    print("\n--- Accessing Parsed Attributes ---");
    print("Session-ID: ${parsedMessage.sessionId}");
    print("Termination-Cause: ${parsedMessage.terminationCause}");
    print("User-Name: ${parsedMessage.userName}");
  }
}
