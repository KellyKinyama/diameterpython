
import 'dart:convert';
import 'dart:typed_data';



import '../../diameter.dart';

/// A Capabilities-Exchange message (CER/CEA).
///
/// See RFC 6733 for details.
abstract class CapabilitiesExchange extends DefinedMessage {
  static const int CODE = 257;
  static const String NAME = "Capabilities-Exchange";

  @override
  int get code => CODE;
  @override
  String get name => NAME;
  
  CapabilitiesExchange({super.header, super.avps});

  /// Factory to create the correct message type (Request or Answer) from a header.
  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return CapabilitiesExchangeRequest(header: header);
    } else {
      return CapabilitiesExchangeAnswer(header: header);
    }
  }
}

/// A Capabilities-Exchange-Answer message.
class CapabilitiesExchangeAnswer extends CapabilitiesExchange {
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  List<dynamic> hostIpAddress = [];
  int? vendorId;
  String? productName;
  int? originStateId;
  String? errorMessage;
  FailedAvp? failedAvp;
  List<int> supportedVendorId = [];
  List<int> authApplicationId = [];
  List<int> inbandSecurityId = [];
  List<int> acctApplicationId = [];
  List<VendorSpecificApplicationId> vendorSpecificApplicationId = [];
  int? firmwareRevision;

  CapabilitiesExchangeAnswer({super.header, super.avps}) {
    header.isRequest = false;
    header.isProxyable = false;
    assignAttributesFromAvps(this, avps);
    super.avps = []; // Clear the raw AVP list
  }
  
  @override
  final AvpGenType avpDef = const [
      AvpGenDef("result_code", AVP_RESULT_CODE, isRequired: true),
      AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
      AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
      AvpGenDef("host_ip_address", AVP_HOST_IP_ADDRESS, isRequired: true),
      AvpGenDef("vendor_id", AVP_VENDOR_ID, isRequired: true),
      AvpGenDef("product_name", AVP_PRODUCT_NAME, isRequired: true, isMandatory: false),
      AvpGenDef("origin_state_id", AVP_ORIGIN_STATE_ID),
      AvpGenDef("error_message", AVP_ERROR_MESSAGE, isMandatory: false),
      AvpGenDef("failed_avp", AVP_FAILED_AVP, typeClass: FailedAvp),
      AvpGenDef("supported_vendor_id", AVP_SUPPORTED_VENDOR_ID),
      AvpGenDef("auth_application_id", AVP_AUTH_APPLICATION_ID),
      AvpGenDef("inband_security_id", AVP_INBAND_SECURITY_ID),
      AvpGenDef("acct_application_id", AVP_ACCT_APPLICATION_ID),
      AvpGenDef("vendor_specific_application_id", AVP_VENDOR_SPECIFIC_APPLICATION_ID, typeClass: VendorSpecificApplicationId),
      AvpGenDef("firmware_revision", AVP_FIRMWARE_REVISION, isMandatory: false)
  ];
  
  // Implement AvpGenerator methods
  @override
  Map<String, dynamic> toMap() => {
    "result_code": resultCode,
    "origin_host": originHost,
    "origin_realm": originRealm,
    "host_ip_address": hostIpAddress,
    "vendor_id": vendorId,
    "product_name": productName,
    "origin_state_id": originStateId,
    "error_message": errorMessage,
    "failed_avp": failedAvp,
    "supported_vendor_id": supportedVendorId,
    "auth_application_id": authApplicationId,
    "inband_security_id": inbandSecurityId,
    "acct_application_id": acctApplicationId,
    "vendor_specific_application_id": vendorSpecificApplicationId,
    "firmware_revision": firmwareRevision
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
      resultCode = map["result_code"];
      originHost = map["origin_host"];
      originRealm = map["origin_realm"];
      hostIpAddress = map["host_ip_address"];
      vendorId = map["vendor_id"];
      productName = map["product_name"];
      originStateId = map["origin_state_id"];
      errorMessage = map["error_message"];
      failedAvp = map["failed_avp"];
      supportedVendorId = map["supported_vendor_id"];
      authApplicationId = map["auth_application_id"];
      inbandSecurityId = map["inband_security_id"];
      acctApplicationId = map["acct_application_id"];
      vendorSpecificApplicationId = map["vendor_specific_application_id"];
      firmwareRevision = map["firmware_revision"];
  }
}

/// A Capabilities-Exchange-Request message.
class CapabilitiesExchangeRequest extends CapabilitiesExchange {
  Uint8List? originHost;
  Uint8List? originRealm;
  List<dynamic> hostIpAddress = [];
  int? vendorId;
  String? productName;
  int? originStateId;
  List<int> supportedVendorId = [];
  List<int> authApplicationId = [];
  List<int> inbandSecurityId = [];
  List<int> acctApplicationId = [];
  List<VendorSpecificApplicationId> vendorSpecificApplicationId = [];
  int? firmwareRevision;

  CapabilitiesExchangeRequest({super.header, super.avps}) {
    header.isRequest = true;
    header.isProxyable = false;
    assignAttributesFromAvps(this, avps);
    super.avps = []; // Clear the raw AVP list
  }
  
  @override
  final AvpGenType avpDef = const [
      AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true),
      AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true),
      AvpGenDef("host_ip_address", AVP_HOST_IP_ADDRESS, isRequired: true),
      AvpGenDef("vendor_id", AVP_VENDOR_ID, isRequired: true),
      AvpGenDef("product_name", AVP_PRODUCT_NAME, isRequired: true, isMandatory: false),
      AvpGenDef("origin_state_id", AVP_ORIGIN_STATE_ID),
      AvpGenDef("supported_vendor_id", AVP_SUPPORTED_VENDOR_ID),
      AvpGenDef("auth_application_id", AVP_AUTH_APPLICATION_ID),
      AvpGenDef("inband_security_id", AVP_INBAND_SECURITY_ID),
      AvpGenDef("acct_application_id", AVP_ACCT_APPLICATION_ID),
      AvpGenDef("vendor_specific_application_id", AVP_VENDOR_SPECIFIC_APPLICATION_ID, typeClass: VendorSpecificApplicationId),
      AvpGenDef("firmware_revision", AVP_FIRMWARE_REVISION, isMandatory: false)
  ];
  
  // Implement AvpGenerator methods
  @override
  Map<String, dynamic> toMap() => {
    "origin_host": originHost,
    "origin_realm": originRealm,
    "host_ip_address": hostIpAddress,
    "vendor_id": vendorId,
    "product_name": productName,
    "origin_state_id": originStateId,
    "supported_vendor_id": supportedVendorId,
    "auth_application_id": authApplicationId,
    "inband_security_id": inbandSecurityId,
    "acct_application_id": acctApplicationId,
    "vendor_specific_application_id": vendorSpecificApplicationId,
    "firmware_revision": firmwareRevision
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
      originHost = map["origin_host"];
      originRealm = map["origin_realm"];
      hostIpAddress = map["host_ip_address"];
      vendorId = map["vendor_id"];
      productName = map["product_name"];
      originStateId = map["origin_state_id"];
      supportedVendorId = map["supported_vendor_id"];
      authApplicationId = map["auth_application_id"];
      inbandSecurityId = map["inband_security_id"];
      acctApplicationId = map["acct_application_id"];
      vendorSpecificApplicationId = map["vendor_specific_application_id"];
      firmwareRevision = map["firmware_revision"];
  }
}

/// A map of command codes to their corresponding message classes.
final Map<int, Type> allCommands = {
  CapabilitiesExchange.CODE: CapabilitiesExchange,
  // Add other commands here as they are implemented
  // e.g., CreditControl.CODE: CreditControl,
};



void main() {
  // 1. Create a new Capabilities-Exchange-Request
  var cer = CapabilitiesExchangeRequest();

  // 2. Set the message header details
  cer.header.applicationId = APP_DIAMETER_COMMON_MESSAGES;
  cer.header.hopByHopId = 0x12345678;
  cer.header.endToEndId = 0xabcdef01;

  // 3. Set mandatory AVP values as properties
  cer.originHost = utf8.encode("client.example.com") ;
  cer.originRealm = utf8.encode("example.com");
  cer.vendorId = VENDOR_NONE;
  cer.productName = "Dart Diameter Client";
  cer.originStateId = 1668472800; // A timestamp, for example
  
  // Add an IP address (the library will handle the Address AVP format)
  cer.hostIpAddress.add("192.168.1.10");

  // 4. Add some AVPs that can occur multiple times
  cer.supportedVendorId.add(VENDOR_TGPP);
  cer.authApplicationId.add(APP_3GPP_S6A_S6D);
  
  // 5. Add a grouped AVP
  cer.vendorSpecificApplicationId.add(
    VendorSpecificApplicationId(
      vendorId: VENDOR_TGPP,
      authApplicationId: APP_3GPP_GX
    )
  );

  print("--- Original Request ---");
  print(cer);
  for (var avp in cer.avps) {
    print("  ${avp.toString()}");
  }

  // 6. Encode the message to bytes
  var cerBytes = cer.asBytes();
  print("\n--- Encoded Bytes (Hex) ---");
  print(cerBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

  // 7. Parse the bytes back into a message object
  var parsedMessage = Message.fromBytes(cerBytes);

  print("\n--- Parsed Message ---");
  print(parsedMessage);

  // 8. Verify the type and access attributes
  if (parsedMessage is CapabilitiesExchangeRequest) {
    print("\n--- Accessing Parsed Attributes ---");
    print("Origin-Host: ${utf8.decode(parsedMessage.originHost!)}");
    print("Origin-Realm: ${utf8.decode(parsedMessage.originRealm!)}");
    print("Product-Name: ${parsedMessage.productName}");
    print("Supported Vendor ID: ${parsedMessage.supportedVendorId.first}");
    print("Auth Application ID: ${parsedMessage.authApplicationId.first}");
    
    var vsai = parsedMessage.vendorSpecificApplicationId.first;
    print("Vendor-Specific App ID:");
    print("  Vendor-ID: ${vsai.vendorId}");
    print("  Auth-Application-Id: ${vsai.authApplicationId}");

  } else {
    print("Parsed message is not a CER!");
  }
}
