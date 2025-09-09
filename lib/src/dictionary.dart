import 'package:diameter/diameter.dart';

/// AVP dictionaries mapping codes to definitions.
// part of diameter.src;

/// Base AVP dictionary with no vendors.
const Map<int, Map<String, dynamic>> AVP_DICTIONARY = {
  AVP_USER_NAME: {
    "name": "User-Name",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_USER_PASSWORD: {
    "name": "User-Password",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_CHAP_PASSWORD: {
    "name": "CHAP-Password",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_NAS_IP_ADDRESS: {
    "name": "NAS-IP-Address",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_NAS_PORT: {"name": "NAS-Port", "type": AvpUnsigned32, "mandatory": true},
  AVP_SERVICE_TYPE: {
    "name": "Service-Type",
    "type": AvpEnumerated,
    "mandatory": true,
  },
  AVP_FRAMED_PROTOCOL: {
    "name": "Framed-Protocol",
    "type": AvpEnumerated,
    "mandatory": true,
  },
  AVP_FRAMED_IP_ADDRESS: {
    "name": "Framed-IP-Address",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_FRAMED_IP_NETMASK: {
    "name": "Framed-IP-Netmask",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_FRAMED_ROUTING: {
    "name": "Framed-Routing",
    "type": AvpEnumerated,
    "mandatory": true,
  },
  AVP_FILTER_ID: {
    "name": "Filter-Id",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_FRAMED_MTU: {
    "name": "Framed-MTU",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_FRAMED_COMPRESSION: {
    "name": "Framed-Compression",
    "type": AvpEnumerated,
    "mandatory": true,
  },
  AVP_LOGIN_IP_HOST: {
    "name": "Login-IP-Host",
    "type": AvpAddress,
    "mandatory": true,
  },
  AVP_LOGIN_SERVICE: {
    "name": "Login-Service",
    "type": AvpEnumerated,
    "mandatory": true,
  },
  AVP_LOGIN_TCP_PORT: {
    "name": "Login-TCP-Port",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_REPLY_MESSAGE: {
    "name": "Reply-Message",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_CALLBACK_NUMBER: {
    "name": "Callback-Number",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_CALLBACK_ID: {
    "name": "Callback-Id",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_FRAMED_ROUTE: {
    "name": "Framed-Route",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_FRAMED_IPX_NETWORK: {
    "name": "Framed-IPX-Network",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_STATE: {"name": "State", "type": AvpOctetString, "mandatory": true},
  AVP_CLASS: {"name": "Class", "type": AvpOctetString, "mandatory": true},
  AVP_VENDOR_SPECIFIC: {
    "name": "Vendor-Specific",
    "type": AvpGrouped,
    "mandatory": true,
  },
  AVP_SESSION_TIMEOUT: {
    "name": "Session-Timeout",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_IDLE_TIMEOUT: {
    "name": "Idle-Timeout",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_TERMINATION_ACTION: {
    "name": "Termination-Action",
    "type": AvpEnumerated,
    "mandatory": true,
  },
  AVP_CALLED_STATION_ID: {
    "name": "Called-Station-Id",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_CALLING_STATION_ID: {
    "name": "Calling-Station-Id",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_NAS_IDENTIFIER: {
    "name": "NAS-Identifier",
    "type": AvpUtf8String,
    "mandatory": true,
  },
  AVP_PROXY_STATE: {
    "name": "Proxy-State",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_LOGIN_LAT_SERVICE: {
    "name": "Login-LAT-Service",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_LOGIN_LAT_NODE: {
    "name": "Login-LAT-Node",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_LOGIN_LAT_GROUP: {
    "name": "Login-LAT-Group",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_FRAMED_APPLETALK_LINK: {
    "name": "Framed-AppleTalk-Link",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_FRAMED_APPLETALK_NETWORK: {
    "name": "Framed-AppleTalk-Network",
    "type": AvpUnsigned32,
    "mandatory": true,
  },
  AVP_FRAMED_APPLETALK_ZONE: {
    "name": "Framed-AppleTalk-Zone",
    "type": AvpOctetString,
    "mandatory": true,
  },
  AVP_ACCT_STATUS_TYPE: {"name": "Acct-Status-Type", "type": AvpEnumerated},
  // ... (and so on for all base AVPs)
  AVP_NONE_SIP_SERVER_NAME: {
    "name": "SIP-Server-Name",
    "type": AvpOctetString,
    "mandatory": true,
  },
};

/// Vendor-specific AVP dictionaries.
const Map<int, Map<int, Map<String, dynamic>>> AVP_VENDOR_DICTIONARY = {
  VENDOR_TGPP: {
    AVP_TGPP_GBA_USERSECSETTINGS: {
      "name": "GBA-UserSecSettings",
      "type": AvpOctetString,
      "vendor": VENDOR_TGPP,
    },
    AVP_TGPP_TRANSACTION_IDENTIFIER: {
      "name": "Transaction-Identifier",
      "type": AvpOctetString,
      "vendor": VENDOR_TGPP,
    },
    AVP_TGPP_NAF_HOSTNAME: {
      "name": "NAF-Hostname",
      "type": AvpOctetString,
      "vendor": VENDOR_TGPP,
    },
    // ... (and so on for all 3GPP AVPs)
    AVP_TGPP_REACHABILITY_CAUSE: {
      "name": "Reachability-Cause",
      "type": AvpUnsigned32,
      "mandatory": true,
      "vendor": VENDOR_TGPP,
    },
  },
  VENDOR_ETSI: {
    AVP_ETSI_ETSI_EXPERIMENTAL_RESULT_CODE: {
      "name": "ETSI-Experimental-Result-Code",
      "type": AvpEnumerated,
      "mandatory": true,
      "vendor": VENDOR_ETSI,
    },
    AVP_ETSI_GLOBALLY_UNIQUE_ADDRESS: {
      "name": "Globally-Unique-Address",
      "type": AvpGrouped,
      "mandatory": true,
      "vendor": VENDOR_ETSI,
    },
    // ... (and so on for all ETSI AVPs)
    AVP_ETSI_ETSI_DIGEST_RESPONSE_AUTH: {
      "name": "ETSI-Digest-Response-Auth",
      "type": AvpUtf8String,
      "mandatory": true,
      "vendor": VENDOR_ETSI,
    },
  },
  VENDOR_SUN: {
    AVP_SUN_PING_TIMESTAMP_SECS: {
      "name": "Ping-Timestamp-Secs",
      "type": AvpUnsigned32,
      "mandatory": true,
      "vendor": VENDOR_SUN,
    },
    AVP_SUN_PING_TIMESTAMP_USECS: {
      "name": "Ping-Timestamp-Usecs",
      "type": AvpUnsigned32,
      "mandatory": true,
      "vendor": VENDOR_SUN,
    },
    AVP_SUN_PING_TIMESTAMP: {
      "name": "Ping-Timestamp",
      "type": AvpGrouped,
      "mandatory": true,
      "vendor": VENDOR_SUN,
    },
  },
  // ... (and so on for all other vendors)
  VENDOR_ONEM2M: {
    AVP_ONEM2M_ACCESS_NETWORK_IDENTIFIER: {
      "name": "Access-Network-Identifier",
      "type": AvpUnsigned32,
      "mandatory": true,
      "vendor": VENDOR_ONEM2M,
    },
    // ... (and so on for all oneM2M AVPs)
    AVP_ONEM2M_TARGET_ID: {
      "name": "Target-ID",
      "type": AvpUtf8String,
      "mandatory": true,
      "vendor": VENDOR_ONEM2M,
    },
  },
};
