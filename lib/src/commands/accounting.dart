
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../diameter.dart';

/// An Accounting message (ACR/ACA).
///
/// See RFC 6733 for details.
abstract class Accounting extends DefinedMessage {
  static const int CODE = 271;
  static const String NAME = "Accounting";

  @override
  int get code => CODE;
  @override
  String get name => NAME;

  Accounting({super.header, super.avps});

  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return AccountingRequest(header: header);
    } else {
      return AccountingAnswer(header: header);
    }
  }
}

/// An Accounting-Answer message.
class AccountingAnswer extends Accounting {
  String? sessionId;
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  int? accountingRecordType;
  int? accountingRecordNumber;
  int? acctApplicationId;
  // ... other properties
  
  AccountingAnswer({super.header, super.avps}) {
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
        AvpGenDef("accounting_record_type", AVP_ACCOUNTING_RECORD_TYPE, isRequired: true),
        AvpGenDef("accounting_record_number", AVP_ACCOUNTING_RECORD_NUMBER, isRequired: true),
        // ... other AVP definitions
      ];
  
  // AVP Generator implementations omitted for brevity.
}

/// An Accounting-Request message.
class AccountingRequest extends Accounting {
  String? sessionId;
  Uint8List? originHost;
  Uint8List? originRealm;
  Uint8List? destinationRealm;
  int? accountingRecordType;
  int? accountingRecordNumber;
  // ... other properties

  AccountingRequest({super.header, super.avps}) {
    header.isRequest = true;
    header.isProxyable = true;
    assignAttributesFromAvps(this, avps);
    super.avps = [];
  }
  
  @override
  AvpGenType get avpDef => const [
        AvpGenDef("session_id", AVP_SESSION_ID, isRequired: true),
        AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
        AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
        AvpGenDef("destination_realm", AVP_DESTINATION_REALM, isRequired: true),
        AvpGenDef("accounting_record_type", AVP_ACCOUNTING_RECORD_TYPE, isRequired: true),
        AvpGenDef("accounting_record_number", AVP_ACCOUNTING_RECORD_NUMBER, isRequired: true),
        // ... other AVP definitions (this list is very large)
      ];

  // AVP Generator implementations omitted for brevity.
}


void main() {
  // Create a new Accounting-Request (ACR) for the start of a session
  var acr = AccountingRequest();

  // Set header details
  acr.header.applicationId = APP_DIAMETER_BASE_ACCOUNTING;
  acr.header.hopByHopId = 0xaaaa1111;
  acr.header.endToEndId = 0xbbbb2222;

  // Set mandatory ACR AVPs
  acr.sessionId = "client.example.com;12345;67890";
  acr.originHost = utf8.encode("client.example.com");
  acr.originRealm = utf8.encode("example.com") ;
  acr.destinationRealm = utf8.encode("provider.com") ;
  acr.accountingRecordType = E_ACCOUNTING_RECORD_TYPE_START_RECORD;
  acr.accountingRecordNumber = 0;
  
  // Set optional AVPs
  acr.userName = "user@example.com";
  acr.nasPortType = E_NAS_PORT_TYPE_ETHERNET;
  acr.framedIpAddress = InternetAddress("192.0.2.1").rawAddress;
  
  print("--- Original Accounting Request ---");
  print(acr);
  for (var avp in acr.avps) {
    print("  ${avp.toString()}");
  }

  // Encode the message to bytes
  var acrBytes = acr.asBytes();
  print("\n--- Encoded Bytes (Hex) ---");
  print(acrBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

  // Parse the bytes back into a message object
  var parsedMessage = Message.fromBytes(acrBytes);
  
  print("\n--- Parsed Message ---");
  print(parsedMessage);

  // Verify the type and access attributes
  if (parsedMessage is AccountingRequest) {
    print("\n--- Accessing Parsed Attributes ---");
    print("Session-ID: ${parsedMessage.sessionId}");
    print("Record-Type: ${parsedMessage.accountingRecordType}");
    print("User-Name: ${parsedMessage.userName}");
    print("Framed-IP-Address: ${InternetAddress.fromRawAddress(parsedMessage.framedIpAddress!)}");
  }
}
