import 'dart:typed_data';

import '../../diameter.dart';

/// A data container for the "Failed-AVP" (279) grouped AVP.
class FailedAvp implements AvpGenerator {
  @override
  final List<Avp> additionalAvps;

  FailedAvp({this.additionalAvps = const []});

  @override
  AvpGenType get avpDef => [];

  @override
  Map<String, dynamic> toMap() => {'additional_avps': additionalAvps};
}

/// A data container for the "Vendor-Specific-Application-ID" (260) grouped AVP.
class VendorSpecificApplicationId implements AvpGenerator {
  final int? vendorId;
  final int? authApplicationId;
  final int? acctApplicationId;

  @override
  final List<Avp> additionalAvps;

  VendorSpecificApplicationId({
    this.vendorId,
    this.authApplicationId,
    this.acctApplicationId,
    this.additionalAvps = const [],
  });

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("vendor_id", AVP_VENDOR_ID, isRequired: true),
    AvpGenDef("auth_application_id", AVP_AUTH_APPLICATION_ID),
    AvpGenDef("acct_application_id", AVP_ACCT_APPLICATION_ID),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'vendor_id': vendorId,
    'auth_application_id': authApplicationId,
    'acct_application_id': acctApplicationId,
    'additional_avps': additionalAvps,
  };
}

/// A data container that represents the "Unit-Value" grouped AVP.
class UnitValue implements AvpGenerator {
  final int? valueDigits;
  final int? exponent;

  @override
  final List<Avp> additionalAvps;

  UnitValue({this.valueDigits, this.exponent, this.additionalAvps = const []});

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("value_digits", AVP_VALUE_DIGITS, isRequired: true),
    AvpGenDef("exponent", AVP_EXPONENT),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'value_digits': valueDigits,
    'exponent': exponent,
    'additional_avps': additionalAvps,
  };
}

/// A data container that represents the "CC-Money" grouped AVP.
class CcMoney implements AvpGenerator {
  final UnitValue? unitValue;
  final int? currencyCode;

  @override
  final List<Avp> additionalAvps;

  CcMoney({this.unitValue, this.currencyCode, this.additionalAvps = const []});

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "unit_value",
      AVP_UNIT_VALUE,
      isRequired: true,
      typeClass: UnitValue,
    ),
    AvpGenDef("currency_code", AVP_CURRENCY_CODE),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'unit_value': unitValue,
    'currency_code': currencyCode,
    'additional_avps': additionalAvps,
  };
}

/// A data container that represents the "Used-Service-Unit" (402) grouped AVP.
class UsedServiceUnit implements AvpGenerator {
  final int? tariffChangeUsage;
  final int? ccTime;
  final CcMoney? ccMoney;
  final int? ccTotalOctets;
  final int? ccInputOctets;
  final int? ccOutputOctets;
  final int? ccServiceSpecificUnits;

  // 3GPP extensions: ETSI 132.299
  final int? reportingReason;
  final List<DateTime> eventChargingTimestamp;

  @override
  final List<Avp> additionalAvps;

  UsedServiceUnit({
    this.tariffChangeUsage,
    this.ccTime,
    this.ccMoney,
    this.ccTotalOctets,
    this.ccInputOctets,
    this.ccOutputOctets,
    this.ccServiceSpecificUnits,
    this.reportingReason,
    this.eventChargingTimestamp = const [],
    this.additionalAvps = const [],
  });

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("tariff_change_usage", AVP_TARIFF_CHANGE_USAGE),
    AvpGenDef("cc_time", AVP_CC_TIME),
    AvpGenDef("cc_money", AVP_CC_MONEY, typeClass: CcMoney),
    AvpGenDef("cc_total_octets", AVP_CC_TOTAL_OCTETS),
    AvpGenDef("cc_input_octets", AVP_CC_INPUT_OCTETS),
    AvpGenDef("cc_output_octets", AVP_CC_OUTPUT_OCTETS),
    AvpGenDef("cc_service_specific_units", AVP_CC_SERVICE_SPECIFIC_UNITS),
    AvpGenDef(
      "reporting_reason",
      AVP_TGPP_3GPP_REPORTING_REASON,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "event_charging_timestamp",
      AVP_TGPP_EVENT_CHARGING_TIMESTAMP,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'tariff_change_usage': tariffChangeUsage,
    'cc_time': ccTime,
    'cc_money': ccMoney,
    'cc_total_octets': ccTotalOctets,
    'cc_input_octets': ccInputOctets,
    'cc_output_octets': ccOutputOctets,
    'cc_service_specific_units': ccServiceSpecificUnits,
    'reporting_reason': reportingReason,
    'event_charging_timestamp': eventChargingTimestamp,
    'additional_avps': additionalAvps,
  };

   @override
  void updateFromMap(Map<String, dynamic> map) {
    tariffChangeUsage = map['tariff_change_usage'];
    contentProviderId = map['contentProviderId'];
    additionalAvps = map['additional_avps'];
    contentId = map['contentId'];
    contentProviderId = map['contentProviderId'];
    additionalAvps = map['additional_avps'];
    contentId = map['contentId'];
    contentProviderId = map['contentProviderId'];
    additionalAvps = map['additional_avps'];
  }
}
// Add this code to lib/src/avp/grouped.dart

/// A data container for the "DCD-Information" (2115) grouped AVP.
class DcdInformation implements AvpGenerator {
  String? contentId;
  String? contentProviderId;

  @override
  List<Avp> additionalAvps;

  DcdInformation({
    this.contentId,
    this.contentProviderId,
    this.additionalAvps = const [],
  });

  factory DcdInformation.fromAvps(List<Avp> avps) {
    var dcd = DcdInformation();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_CONTENT_ID:
          dcd.contentId = (avp as AvpUtf8String).value;
          break;
        case AVP_TGPP_CONTENT_PROVIDER_ID:
          dcd.contentProviderId = (avp as AvpUtf8String).value;
          break;
        default:
          dcd.additionalAvps.add(avp);
      }
    }
    return dcd;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("contentId", AVP_TGPP_CONTENT_ID, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "contentProviderId",
      AVP_TGPP_CONTENT_PROVIDER_ID,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'contentId': contentId,
    'contentProviderId': contentProviderId,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    contentId = map['contentId'];
    contentProviderId = map['contentProviderId'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "IM-Information" (2110) grouped AVP.
class ImInformation implements AvpGenerator {
  int? totalNumberOfMessagesSent;
  int? totalNumberOfMessagesExploded;
  int? numberOfMessagesSuccessfullySent;
  int? numberOfMessagesSuccessfullyExploded;

  @override
  List<Avp> additionalAvps;

  ImInformation({
    this.totalNumberOfMessagesSent,
    this.totalNumberOfMessagesExploded,
    this.numberOfMessagesSuccessfullySent,
    this.numberOfMessagesSuccessfullyExploded,
    this.additionalAvps = const [],
  });

  factory ImInformation.fromAvps(List<Avp> avps) {
    var im = ImInformation();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_TOTAL_NUMBER_OF_MESSAGES_SENT:
          im.totalNumberOfMessagesSent = (avp as AvpUnsigned32).value;
          break;
        case AVP_TGPP_TOTAL_NUMBER_OF_MESSAGES_EXPLODED:
          im.totalNumberOfMessagesExploded = (avp as AvpUnsigned32).value;
          break;
        case AVP_TGPP_NUMBER_OF_MESSAGES_SUCCESSFULLY_SENT:
          im.numberOfMessagesSuccessfullySent = (avp as AvpUnsigned32).value;
          break;
        case AVP_TGPP_NUMBER_OF_MESSAGES_SUCCESSFULLY_EXPLODED:
          im.numberOfMessagesSuccessfullyExploded =
              (avp as AvpUnsigned32).value;
          break;
        default:
          im.additionalAvps.add(avp);
      }
    }
    return im;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "totalNumberOfMessagesSent",
      AVP_TGPP_TOTAL_NUMBER_OF_MESSAGES_SENT,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "totalNumberOfMessagesExploded",
      AVP_TGPP_TOTAL_NUMBER_OF_MESSAGES_EXPLODED,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "numberOfMessagesSuccessfullySent",
      AVP_TGPP_NUMBER_OF_MESSAGES_SUCCESSFULLY_SENT,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "numberOfMessagesSuccessfullyExploded",
      AVP_TGPP_NUMBER_OF_MESSAGES_SUCCESSFULLY_EXPLODED,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'totalNumberOfMessagesSent': totalNumberOfMessagesSent,
    'totalNumberOfMessagesExploded': totalNumberOfMessagesExploded,
    'numberOfMessagesSuccessfullySent': numberOfMessagesSuccessfullySent,
    'numberOfMessagesSuccessfullyExploded':
        numberOfMessagesSuccessfullyExploded,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    totalNumberOfMessagesSent = map['totalNumberOfMessagesSent'];
    totalNumberOfMessagesExploded = map['totalNumberOfMessagesExploded'];
    numberOfMessagesSuccessfullySent = map['numberOfMessagesSuccessfullySent'];
    numberOfMessagesSuccessfullyExploded =
        map['numberOfMessagesSuccessfullyExploded'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "MMTel-Information" (2030) grouped AVP.
class MmtelInformation implements AvpGenerator {
  List<SupplementaryService> supplementaryService;

  @override
  List<Avp> additionalAvps;

  MmtelInformation({
    this.supplementaryService = const [],
    this.additionalAvps = const [],
  });

  factory MmtelInformation.fromAvps(List<Avp> avps) {
    var mmtel = MmtelInformation(supplementaryService: []);
    for (var avp in avps) {
      if (avp.code == AVP_TGPP_SUPPLEMENTARY_SERVICE &&
          avp.vendorId == VENDOR_TGPP) {
        mmtel.supplementaryService.add(
          SupplementaryService.fromAvps((avp as AvpGrouped).value),
        );
      } else {
        mmtel.additionalAvps.add(avp);
      }
    }
    return mmtel;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "supplementaryService",
      AVP_TGPP_SUPPLEMENTARY_SERVICE,
      vendorId: VENDOR_TGPP,
      typeClass: SupplementaryService,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'supplementaryService': supplementaryService,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    supplementaryService =
        map['supplementaryService'] as List<SupplementaryService>;
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "MBMS-Information" (880) grouped AVP.
class MbmsInformation implements AvpGenerator {
  Uint8List? tmgi;
  int? mbmsServiceType;
  int? mbmsUserServiceType;
  int? fileRepairSupported;
  String? requiredMbmsBearerCapabilities;
  int? mbms2g3gIndicator;
  String? rai;
  List<Uint8List> mbmsServiceArea;
  Uint8List? mbmsSessionIdentity;
  int? cnIpMulticastDistribution;
  String? mbmsGwAddress;
  int? mbmsChargedParty;
  List<Uint8List> msisdn;
  int? mbmsDataTransferStart;
  int? mbmsDataTransferStop;

  @override
  List<Avp> additionalAvps;

  MbmsInformation({
    this.tmgi,
    this.mbmsServiceType,
    this.mbmsUserServiceType,
    this.fileRepairSupported,
    this.requiredMbmsBearerCapabilities,
    this.mbms2g3gIndicator,
    this.rai,
    this.mbmsServiceArea = const [],
    this.mbmsSessionIdentity,
    this.cnIpMulticastDistribution,
    this.mbmsGwAddress,
    this.mbmsChargedParty,
    this.msisdn = const [],
    this.mbmsDataTransferStart,
    this.mbmsDataTransferStop,
    this.additionalAvps = const [],
  });

  factory MbmsInformation.fromAvps(List<Avp> avps) {
    // Factory implementation is complex and omitted for brevity
    return MbmsInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("tmgi", AVP_TGPP_TMGI, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "mbmsServiceType",
      AVP_TGPP_MBMS_SERVICE_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "mbmsUserServiceType",
      AVP_TGPP_MBMS_USER_SERVICE_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "fileRepairSupported",
      AVP_TGPP_FILE_REPAIR_SUPPORTED,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "requiredMbmsBearerCapabilities",
      AVP_TGPP_REQUIRED_MBMS_BEARER_CAPABILITIES,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "mbms2g3gIndicator",
      AVP_TGPP_MBMS_2G_3G_INDICATOR,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("rai", AVP_TGPP_RAI, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "mbmsServiceArea",
      AVP_TGPP_MBMS_SERVICE_AREA,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "mbmsSessionIdentity",
      AVP_TGPP_MBMS_SESSION_IDENTITY,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "cnIpMulticastDistribution",
      AVP_TGPP_CN_IP_MULTICAST_DISTRIBUTION,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("mbmsGwAddress", AVP_TGPP_MBMS_GW_ADDRESS, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "mbmsChargedParty",
      AVP_TGPP_MBMS_CHARGED_PARTY,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("msisdn", AVP_TGPP_MSISDN, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "mbmsDataTransferStart",
      AVP_TGPP_MBMS_DATA_TRANSFER_START,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "mbmsDataTransferStop",
      AVP_TGPP_MBMS_DATA_TRANSFER_STOP,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'tmgi': tmgi,
    'mbmsServiceType': mbmsServiceType,
    'mbmsUserServiceType': mbmsUserServiceType,
    'fileRepairSupported': fileRepairSupported,
    'requiredMbmsBearerCapabilities': requiredMbmsBearerCapabilities,
    'mbms2g3gIndicator': mbms2g3gIndicator,
    'rai': rai,
    'mbmsServiceArea': mbmsServiceArea,
    'mbmsSessionIdentity': mbmsSessionIdentity,
    'cnIpMulticastDistribution': cnIpMulticastDistribution,
    'mbmsGwAddress': mbmsGwAddress,
    'mbmsChargedParty': mbmsChargedParty,
    'msisdn': msisdn,
    'mbmsDataTransferStart': mbmsDataTransferStart,
    'mbmsDataTransferStop': mbmsDataTransferStop,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    // Update all properties from map
  }
}

/// A data container for the "PoC-Information" (879) grouped AVP.
class PocInformation implements AvpGenerator {
  int? pocServerRole;
  int? pocSessionType;
  PocUserRole? pocUserRole;
  int? pocSessionInitiationType;
  int? pocEventType;
  int? numberOfParticipants;
  List<String> participantsInvolved;
  List<ParticipantGroup> participantGroup;
  List<TalkBurstExchange> talkBurstExchange;
  String? pocControllingAddress;
  String? pocGroupName;
  String? pocSessionId;
  String? chargedParty;

  @override
  List<Avp> additionalAvps;

  PocInformation({
    this.pocServerRole,
    this.pocSessionType,
    this.pocUserRole,
    this.pocSessionInitiationType,
    this.pocEventType,
    this.numberOfParticipants,
    this.participantsInvolved = const [],
    this.participantGroup = const [],
    this.talkBurstExchange = const [],
    this.pocControllingAddress,
    this.pocGroupName,
    this.pocSessionId,
    this.chargedParty,
    this.additionalAvps = const [],
  });

  factory PocInformation.fromAvps(List<Avp> avps) {
    // Factory implementation omitted for brevity
    return PocInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("pocServerRole", AVP_TGPP_POC_SERVER_ROLE, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "pocSessionType",
      AVP_TGPP_POC_SESSION_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    // ... all other AVP definitions ...
  ];

  @override
  Map<String, dynamic> toMap() => {
    'pocServerRole': pocServerRole,
    // ... all other properties ...
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    // ... update all properties from map ...
  }
}

/// A data container for the "LCS-Information" (878) grouped AVP.
class LcsInformation implements AvpGenerator {
  LcsClientId? lcsClientId;
  LocationType? locationType;
  Uint8List? locationEstimate;
  String? positioningData;
  String? tgppImsi;
  Uint8List? msisdn;

  @override
  List<Avp> additionalAvps;

  LcsInformation({
    this.lcsClientId,
    this.locationType,
    this.locationEstimate,
    this.positioningData,
    this.tgppImsi,
    this.msisdn,
    this.additionalAvps = const [],
  });

  factory LcsInformation.fromAvps(List<Avp> avps) {
    // Factory implementation omitted for brevity
    return LcsInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "lcsClientId",
      AVP_TGPP_LCS_CLIENT_ID,
      vendorId: VENDOR_TGPP,
      typeClass: LcsClientId,
    ),
    AvpGenDef(
      "locationType",
      AVP_TGPP_LOCATION_TYPE,
      vendorId: VENDOR_TGPP,
      typeClass: LocationType,
    ),
    AvpGenDef(
      "locationEstimate",
      AVP_TGPP_LOCATION_ESTIMATE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "positioningData",
      AVP_TGPP_POSITIONING_DATA,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("tgppImsi", AVP_TGPP_3GPP_IMSI, vendorId: VENDOR_TGPP),
    AvpGenDef("msisdn", AVP_TGPP_MSISDN, vendorId: VENDOR_TGPP),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'lcsClientId': lcsClientId,
    'locationType': locationType,
    'locationEstimate': locationEstimate,
    'positioningData': positioningData,
    'tgppImsi': tgppImsi,
    'msisdn': msisdn,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    // ... update all properties from map ...
  }
}

/// A data container for the "ProSe-Information" (3447) grouped AVP.
class ProseInformation implements AvpGenerator {
  List<SupportedFeatures> supportedFeatures;
  String? announcingUeHplmnIdentifier;
  // ... many other ProSe properties

  @override
  List<Avp> additionalAvps;

  ProseInformation({
    this.supportedFeatures = const [],
    this.announcingUeHplmnIdentifier,
    this.additionalAvps = const [],
  });

  factory ProseInformation.fromAvps(List<Avp> avps) {
    // Factory implementation omitted for brevity
    return ProseInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "supportedFeatures",
      AVP_TGPP_SUPPORTED_FEATURES,
      vendorId: VENDOR_TGPP,
      typeClass: SupportedFeatures,
    ),
    AvpGenDef(
      "announcingUeHplmnIdentifier",
      AVP_TGPP_ANNOUNCING_UE_HPLMN_IDENTIFIER,
      vendorId: VENDOR_TGPP,
    ),
    // ... and many more AVP definitions ...
  ];

  @override
  Map<String, dynamic> toMap() => {
    'supportedFeatures': supportedFeatures,
    'announcingUeHplmnIdentifier': announcingUeHplmnIdentifier,
    // ...
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    // ... update all properties from map ...
  }
}

// Add this code to lib/src/avp/grouped.dart

/// A data container for the "Aoc-Service" (2311) grouped AVP.
class AocService implements AvpGenerator {
  int? aocServiceObligatoryType;
  int? aocServiceType;

  @override
  List<Avp> additionalAvps;

  AocService({
    this.aocServiceObligatoryType,
    this.aocServiceType,
    this.additionalAvps = const [],
  });

  factory AocService.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return AocService();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "aocServiceObligatoryType",
      AVP_TGPP_AOC_SERVICE_OBLIGATORY_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "aocServiceType",
      AVP_TGPP_AOC_SERVICE_TYPE,
      vendorId: VENDOR_TGPP,
    ),
  ];

  // toMap and updateFromMap omitted for brevity
  @override
  Map<String, dynamic> toMap() => {
    'aocServiceObligatoryType': aocServiceObligatoryType,
    'aocServiceType': aocServiceType,
    'additionalAvps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    aocServiceObligatoryType = map['aocServiceObligatoryType'];
    aocServiceType = map['aocServiceType'];
    additionalAvps = map['additionalAvps'];
  }
}

/// A data container for the "AoC-Subscription-Information" (2314) grouped AVP.
class AocSubscriptionInformation implements AvpGenerator {
  List<AocService> aocService;
  int? aocFormat;
  int? preferredAocCurrency;

  @override
  List<Avp> additionalAvps;

  AocSubscriptionInformation({
    this.aocService = const [],
    this.aocFormat,
    this.preferredAocCurrency,
    this.additionalAvps = const [],
  });

  factory AocSubscriptionInformation.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return AocSubscriptionInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "aocService",
      AVP_TGPP_AOC_SERVICE,
      vendorId: VENDOR_TGPP,
      typeClass: AocService,
    ),
    AvpGenDef("aocFormat", AVP_TGPP_AOC_FORMAT, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "preferredAocCurrency",
      AVP_TGPP_PREFERRED_AOC_CURRENCY,
      vendorId: VENDOR_TGPP,
    ),
  ];

  // toMap and updateFromMap omitted for brevity
  @override
  Map<String, dynamic> toMap() => {
    'aocService': aocService,
    'aocFormat': aocFormat,
    'preferredAocCurrency': preferredAocCurrency,
    'additionalAvps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    preferredAocCurrency = map['preferredAocCurrency'];
    aocFormat = map['aocFormat'];
    preferredAocCurrency = map['preferredAocCurrency'];
    additionalAvps = map['additionalAvps'];
  }
}

/// A data container for the "AoC-Cost-Information" (2053) grouped AVP.
class AocCostInformation implements AvpGenerator {
  AccumulatedCost? accumulatedCost;
  List<IncrementalCost> incrementalCost;
  int? currencyCode;

  @override
  List<Avp> additionalAvps;

  AocCostInformation({
    this.accumulatedCost,
    this.incrementalCost = const [],
    this.currencyCode,
    this.additionalAvps = const [],
  });

  factory AocCostInformation.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return AocCostInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "accumulatedCost",
      AVP_TGPP_ACCUMULATED_COST,
      vendorId: VENDOR_TGPP,
      typeClass: AccumulatedCost,
    ),
    AvpGenDef(
      "incrementalCost",
      AVP_TGPP_INCREMENTAL_COST,
      vendorId: VENDOR_TGPP,
      typeClass: IncrementalCost,
    ),
    AvpGenDef("currencyCode", AVP_CURRENCY_CODE),
  ];

  // toMap and updateFromMap omitted for brevity

  @override
  Map<String, dynamic> toMap() => {
    'accumulatedCost': accumulatedCost,
    'incrementalCost': incrementalCost,
    'currencyCode': currencyCode,
    'additionalAvps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    accumulatedCost = map['accumulatedCost'];
    incrementalCost = map['incrementalCost'];
    currencyCode = map['currencyCode'];
    additionalAvps = map['additionalAvps'];
  }
}

/// A data container for the "Tariff-Information" (2060) grouped AVP.
class TariffInformation implements AvpGenerator {
  CurrentTariff? currentTariff;
  DateTime? tariffTimeChange;
  NextTariff? nextTariff;

  @override
  List<Avp> additionalAvps;

  TariffInformation({
    this.currentTariff,
    this.tariffTimeChange,
    this.nextTariff,
    this.additionalAvps = const [],
  });

  factory TariffInformation.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return TariffInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "currentTariff",
      AVP_TGPP_CURRENT_TARIFF,
      vendorId: VENDOR_TGPP,
      typeClass: CurrentTariff,
    ),
    AvpGenDef("tariffTimeChange", AVP_TARIFF_TIME_CHANGE),
    AvpGenDef(
      "nextTariff",
      AVP_TGPP_NEXT_TARIFF,
      vendorId: VENDOR_TGPP,
      typeClass: NextTariff,
    ),
  ];

  // toMap and updateFromMap omitted for brevity

  @override
  Map<String, dynamic> toMap() => {
    'currentTariff': currentTariff,
    'tariffTimeChange': tariffTimeChange,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    currentTariff = map['currentTariff'];
    tariffTimeChange = map['tariffTimeChange'];
  }
}

/// A data container for the "AoC-Information" (2054) grouped AVP.
class AocInformation implements AvpGenerator {
  AocCostInformation? aocCostInformation;
  TariffInformation? tariffInformation;
  AocSubscriptionInformation? aocSubscriptionInformation;

  @override
  List<Avp> additionalAvps;

  AocInformation({
    this.aocCostInformation,
    this.tariffInformation,
    this.aocSubscriptionInformation,
    this.additionalAvps = const [],
  });

  factory AocInformation.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return AocInformation();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "aocCostInformation",
      AVP_TGPP_AOC_COST_INFORMATION,
      vendorId: VENDOR_TGPP,
      typeClass: AocCostInformation,
    ),
    AvpGenDef(
      "tariffInformation",
      AVP_TGPP_TARIFF_INFORMATION,
      vendorId: VENDOR_TGPP,
      typeClass: TariffInformation,
    ),
    AvpGenDef(
      "aocSubscriptionInformation",
      AVP_TGPP_AOC_SUBSCRIPTION_INFORMATION,
      vendorId: VENDOR_TGPP,
      typeClass: AocSubscriptionInformation,
    ),
  ];

  // toMap and updateFromMap omitted for brevity

  @override
  Map<String, dynamic> toMap() => {
    'aocCostInformation': aocCostInformation,
    'tariffInformation': tariffInformation,
    'aocSubscriptionInformation': aocSubscriptionInformation,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    aocCostInformation = map['aocCostInformation'];
    tariffInformation = map['tariffInformation'];
    aocSubscriptionInformation = map['aocSubscriptionInformation'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Supplementary-Service" (2048) grouped AVP.
class SupplementaryService implements AvpGenerator {
  int? mmtelServiceType;
  int? serviceMode;
  int? numberOfDiversions;
  String? associatedPartyAddress;
  String? serviceId;
  DateTime? changeTime;
  int? numberOfParticipants;
  int? participantActionType;
  Uint8List? cugInformation;
  AocInformation? aocInformation;

  @override
  List<Avp> additionalAvps;

  SupplementaryService({
    this.mmtelServiceType,
    this.serviceMode,
    this.numberOfDiversions,
    this.associatedPartyAddress,
    this.serviceId,
    this.changeTime,
    this.numberOfParticipants,
    this.participantActionType,
    this.cugInformation,
    this.aocInformation,
    this.additionalAvps = const [],
  });

  factory SupplementaryService.fromAvps(List<Avp> avps) {
    // Factory implementation is complex and omitted for brevity
    return SupplementaryService();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "mmtelServiceType",
      AVP_TGPP_MMTEL_SERVICE_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("serviceMode", AVP_TGPP_SERVICE_MODE, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "numberOfDiversions",
      AVP_TGPP_NUMBER_OF_DIVERSIONS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "associatedPartyAddress",
      AVP_TGPP_ASSOCIATED_PARTY_ADDRESS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("serviceId", AVP_TGPP_SERVICE_ID, vendorId: VENDOR_TGPP),
    AvpGenDef("changeTime", AVP_TGPP_CHANGE_TIME, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "numberOfParticipants",
      AVP_TGPP_NUMBER_OF_PARTICIPANTS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "participantActionType",
      AVP_TGPP_PARTICIPANT_ACTION_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "cugInformation",
      AVP_TGPP_CUG_INFORMATION,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "aocInformation",
      AVP_TGPP_AOC_SUBSCRIPTION_INFORMATION,
      vendorId: VENDOR_TGPP,
      typeClass: AocInformation,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'mmtelServiceType': mmtelServiceType,
    'serviceMode': serviceMode,
    'numberOfDiversions': numberOfDiversions,
    'associatedPartyAddress': associatedPartyAddress,
    'serviceId': serviceId,
    'changeTime': changeTime,
    'numberOfParticipants': numberOfParticipants,
    'participantActionType': participantActionType,
    'cugInformation': cugInformation,
    'aocInformation': aocInformation,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    mmtelServiceType = map['mmtelServiceType'];
    serviceMode = map['serviceMode'];
    numberOfDiversions = map['numberOfDiversions'];
    associatedPartyAddress = map['associatedPartyAddress'];
    serviceId = map['serviceId'];
    changeTime = map['changeTime'];
    numberOfParticipants = map['numberOfParticipants'];
    participantActionType = map['participantActionType'];
    cugInformation = map['cugInformation'];
    aocInformation = map['aocInformation'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "PoC-User-Role" (1252) grouped AVP.
class PocUserRole implements AvpGenerator {
  String? pocUserRoleIds;
  int? pocUserRoleInfoUnits;

  @override
  List<Avp> additionalAvps;

  PocUserRole({
    this.pocUserRoleIds,
    this.pocUserRoleInfoUnits,
    this.additionalAvps = const [],
  });

  factory PocUserRole.fromAvps(List<Avp> avps) {
    var pocUserRole = PocUserRole();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_POC_USER_ROLE_IDS:
          pocUserRole.pocUserRoleIds = (avp as AvpUtf8String).value;
          break;
        case AVP_TGPP_POC_USER_ROLE_INFO_UNITS:
          pocUserRole.pocUserRoleInfoUnits = (avp as AvpEnumerated).value;
          break;
        default:
          pocUserRole.additionalAvps.add(avp);
      }
    }
    return pocUserRole;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "pocUserRoleIds",
      AVP_TGPP_POC_USER_ROLE_IDS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "pocUserRoleInfoUnits",
      AVP_TGPP_POC_USER_ROLE_INFO_UNITS,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'pocUserRoleIds': pocUserRoleIds,
    'pocUserRoleInfoUnits': pocUserRoleInfoUnits,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    pocUserRoleIds = map['pocUserRoleIds'];
    pocUserRoleInfoUnits = map['pocUserRoleInfoUnits'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Participant-Group" (1260) grouped AVP.
class ParticipantGroup implements AvpGenerator {
  String? calledPartyAddress;
  int? participantAccessPriority;
  int? userParticipatingType;

  @override
  List<Avp> additionalAvps;

  ParticipantGroup({
    this.calledPartyAddress,
    this.participantAccessPriority,
    this.userParticipatingType,
    this.additionalAvps = const [],
  });

  factory ParticipantGroup.fromAvps(List<Avp> avps) {
    var participantGroup = ParticipantGroup();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_CALLED_PARTY_ADDRESS:
          participantGroup.calledPartyAddress = (avp as AvpUtf8String).value;
          break;
        case AVP_TGPP_PARTICIPANT_ACCESS_PRIORITY:
          participantGroup.participantAccessPriority =
              (avp as AvpEnumerated).value;
          break;
        case AVP_TGPP_USER_PARTICIPATING_TYPE:
          participantGroup.userParticipatingType = (avp as AvpEnumerated).value;
          break;
        default:
          participantGroup.additionalAvps.add(avp);
      }
    }
    return participantGroup;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "calledPartyAddress",
      AVP_TGPP_CALLED_PARTY_ADDRESS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "participantAccessPriority",
      AVP_TGPP_PARTICIPANT_ACCESS_PRIORITY,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "userParticipatingType",
      AVP_TGPP_USER_PARTICIPATING_TYPE,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'calledPartyAddress': calledPartyAddress,
    'participantAccessPriority': participantAccessPriority,
    'userParticipatingType': userParticipatingType,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    calledPartyAddress = map['calledPartyAddress'];
    participantAccessPriority = map['participantAccessPriority'];
    userParticipatingType = map['userParticipatingType'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Talk-Burst-Exchange" (1255) grouped AVP.
class TalkBurstExchange implements AvpGenerator {
  DateTime? pocChangeTime;
  int? numberOfTalkBursts;
  int? talkBurstVolume;
  int? talkBurstTime;
  int? numberOfReceivedTalkBursts;
  int? receivedTalkBurstVolume;
  int? receivedTalkBurstTime;
  int? numberOfParticipants;
  int? pocChangeCondition;

  @override
  List<Avp> additionalAvps;

  TalkBurstExchange({
    this.pocChangeTime,
    this.numberOfTalkBursts,
    this.talkBurstVolume,
    this.talkBurstTime,
    this.numberOfReceivedTalkBursts,
    this.receivedTalkBurstVolume,
    this.receivedTalkBurstTime,
    this.numberOfParticipants,
    this.pocChangeCondition,
    this.additionalAvps = const [],
  });

  factory TalkBurstExchange.fromAvps(List<Avp> avps) {
    // Factory implementation is complex and omitted for brevity
    return TalkBurstExchange();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "pocChangeTime",
      AVP_TGPP_POC_CHANGE_TIME,
      vendorId: VENDOR_TGPP,
      isRequired: true,
    ),
    AvpGenDef(
      "numberOfTalkBursts",
      AVP_TGPP_NUMBER_OF_TALK_BURSTS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "talkBurstVolume",
      AVP_TGPP_TALK_BURST_VOLUME,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("talkBurstTime", AVP_TGPP_TALK_BURST_TIME, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "numberOfReceivedTalkBursts",
      AVP_TGPP_NUMBER_OF_RECEIVED_TALK_BURSTS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "receivedTalkBurstVolume",
      AVP_TGPP_RECEIVED_TALK_BURST_VOLUME,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "receivedTalkBurstTime",
      AVP_TGPP_RECEIVED_TALK_BURST_TIME,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "numberOfParticipants",
      AVP_TGPP_NUMBER_OF_PARTICIPANTS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "pocChangeCondition",
      AVP_TGPP_POC_CHANGE_CONDITION,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'pocChangeTime': pocChangeTime,
    'numberOfTalkBursts': numberOfTalkBursts,
    'talkBurstVolume': talkBurstVolume,
    'talkBurstTime': talkBurstTime,
    'numberOfReceivedTalkBursts': numberOfReceivedTalkBursts,
    'receivedTalkBurstVolume': receivedTalkBurstVolume,
    'receivedTalkBurstTime': receivedTalkBurstTime,
    'numberOfParticipants': numberOfParticipants,
    'pocChangeCondition': pocChangeCondition,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    // ... update all properties from map ...
  }
}

/// A data container for the "LCS-Client-Name" (1235) grouped AVP.
class LcsClientName implements AvpGenerator {
  String? lcsDataCodingScheme;
  String? lcsNameString;
  int? lcsFormatIndicator;

  @override
  List<Avp> additionalAvps;

  LcsClientName({
    this.lcsDataCodingScheme,
    this.lcsNameString,
    this.lcsFormatIndicator,
    this.additionalAvps = const [],
  });

  factory LcsClientName.fromAvps(List<Avp> avps) {
    var lcs = LcsClientName();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_LCS_DATA_CODING_SCHEME:
          lcs.lcsDataCodingScheme = (avp as AvpUtf8String).value;
          break;
        case AVP_TGPP_LCS_NAME_STRING:
          lcs.lcsNameString = (avp as AvpUtf8String).value;
          break;
        case AVP_TGPP_LCS_FORMAT_INDICATOR:
          lcs.lcsFormatIndicator = (avp as AvpEnumerated).value;
          break;
        default:
          lcs.additionalAvps.add(avp);
      }
    }
    return lcs;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "lcsDataCodingScheme",
      AVP_TGPP_LCS_DATA_CODING_SCHEME,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("lcsNameString", AVP_TGPP_LCS_NAME_STRING, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "lcsFormatIndicator",
      AVP_TGPP_LCS_FORMAT_INDICATOR,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'lcsDataCodingScheme': lcsDataCodingScheme,
    'lcsNameString': lcsNameString,
    'lcsFormatIndicator': lcsFormatIndicator,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    lcsDataCodingScheme = map['lcsDataCodingScheme'];
    lcsNameString = map['lcsNameString'];
    lcsFormatIndicator = map['lcsFormatIndicator'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "LCS-Requestor-ID" (1239) grouped AVP.
class LcsRequestorId implements AvpGenerator {
  String? lcsDataCodingScheme;
  String? lcsRequestorIdString;

  @override
  List<Avp> additionalAvps;

  LcsRequestorId({
    this.lcsDataCodingScheme,
    this.lcsRequestorIdString,
    this.additionalAvps = const [],
  });

  factory LcsRequestorId.fromAvps(List<Avp> avps) {
    var lcs = LcsRequestorId();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_LCS_DATA_CODING_SCHEME:
          lcs.lcsDataCodingScheme = (avp as AvpUtf8String).value;
          break;
        case AVP_TGPP_LCS_REQUESTOR_ID_STRING:
          lcs.lcsRequestorIdString = (avp as AvpUtf8String).value;
          break;
        default:
          lcs.additionalAvps.add(avp);
      }
    }
    return lcs;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "lcsDataCodingScheme",
      AVP_TGPP_LCS_DATA_CODING_SCHEME,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "lcsRequestorIdString",
      AVP_TGPP_LCS_REQUESTOR_ID_STRING,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'lcsDataCodingScheme': lcsDataCodingScheme,
    'lcsRequestorIdString': lcsRequestorIdString,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    lcsDataCodingScheme = map['lcsDataCodingScheme'];
    lcsRequestorIdString = map['lcsRequestorIdString'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "LCS-Client-ID" (1232) grouped AVP.
class LcsClientId implements AvpGenerator {
  int? lcsClientType;
  String? lcsClientExternalId;
  String? lcsClientDialedByMs;
  LcsClientName? lcsClientName;
  String? lcsApn;
  LcsRequestorId? lcsRequestorId;

  @override
  List<Avp> additionalAvps;

  LcsClientId({
    this.lcsClientType,
    this.lcsClientExternalId,
    this.lcsClientDialedByMs,
    this.lcsClientName,
    this.lcsApn,
    this.lcsRequestorId,
    this.additionalAvps = const [],
  });

  factory LcsClientId.fromAvps(List<Avp> avps) {
    // Factory implementation is complex and omitted for brevity
    return LcsClientId();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("lcsClientType", AVP_TGPP_LCS_CLIENT_TYPE, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "lcsClientExternalId",
      AVP_TGPP_LCS_CLIENT_EXTERNAL_ID,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "lcsClientDialedByMs",
      AVP_TGPP_LCS_CLIENT_DIALED_BY_MS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "lcsClientName",
      AVP_TGPP_LCS_CLIENT_NAME,
      vendorId: VENDOR_TGPP,
      typeClass: LcsClientName,
    ),
    AvpGenDef("lcsApn", AVP_TGPP_LCS_APN, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "lcsRequestorId",
      AVP_TGPP_LCS_REQUESTOR_ID,
      vendorId: VENDOR_TGPP,
      typeClass: LcsRequestorId,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'lcsClientType': lcsClientType,
    'lcsClientExternalId': lcsClientExternalId,
    'lcsClientDialedByMs': lcsClientDialedByMs,
    'lcsClientName': lcsClientName,
    'lcsApn': lcsApn,
    'lcsRequestorId': lcsRequestorId,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    // ... update all properties from map ...
  }
}

/// A data container for the "Location-Type" (1244) grouped AVP.
class LocationType implements AvpGenerator {
  int? locationEstimateType;
  String? deferredLocationEventType;

  @override
  List<Avp> additionalAvps;

  LocationType({
    this.locationEstimateType,
    this.deferredLocationEventType,
    this.additionalAvps = const [],
  });

  factory LocationType.fromAvps(List<Avp> avps) {
    var locType = LocationType();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_TGPP_LOCATION_ESTIMATE_TYPE:
          locType.locationEstimateType = (avp as AvpEnumerated).value;
          break;
        case AVP_TGPP_DEFERRED_LOCATION_EVENT_TYPE:
          locType.deferredLocationEventType = (avp as AvpUtf8String).value;
          break;
        default:
          locType.additionalAvps.add(avp);
      }
    }
    return locType;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "locationEstimateType",
      AVP_TGPP_LOCATION_ESTIMATE_TYPE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef(
      "deferredLocationEventType",
      AVP_TGPP_DEFERRED_LOCATION_EVENT_TYPE,
      vendorId: VENDOR_TGPP,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'locationEstimateType': locationEstimateType,
    'deferredLocationEventType': deferredLocationEventType,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    locationEstimateType = map['locationEstimateType'];
    deferredLocationEventType = map['deferredLocationEventType'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Supported-Features" (628) grouped AVP.
class SupportedFeatures implements AvpGenerator {
  int? vendorId;
  int? featureListId;
  int? featureList;

  @override
  List<Avp> additionalAvps;

  SupportedFeatures({
    this.vendorId,
    this.featureListId,
    this.featureList,
    this.additionalAvps = const [],
  });

  factory SupportedFeatures.fromAvps(List<Avp> avps) {
    var supportedFeatures = SupportedFeatures();
    for (var avp in avps) {
      switch (avp.code) {
        case AVP_VENDOR_ID:
          supportedFeatures.vendorId = (avp as AvpUnsigned32).value;
          break;
        case AVP_TGPP_FEATURE_LIST_ID:
          supportedFeatures.featureListId = (avp as AvpUnsigned32).value;
          break;
        case AVP_TGPP_FEATURE_LIST:
          supportedFeatures.featureList = (avp as AvpUnsigned32).value;
          break;
        default:
          supportedFeatures.additionalAvps.add(avp);
      }
    }
    return supportedFeatures;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("vendorId", AVP_VENDOR_ID, isRequired: true),
    AvpGenDef(
      "featureListId",
      AVP_TGPP_FEATURE_LIST_ID,
      vendorId: VENDOR_TGPP,
      isRequired: true,
    ),
    AvpGenDef(
      "featureList",
      AVP_TGPP_FEATURE_LIST,
      vendorId: VENDOR_TGPP,
      isRequired: true,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'vendorId': vendorId,
    'featureListId': featureListId,
    'featureList': featureList,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    vendorId = map['vendorId'];
    featureListId = map['featureListId'];
    featureList = map['featureList'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Location-Info" (3460) grouped AVP.
class LocationInfo implements AvpGenerator {
  Uint8List? tgppUserLocationInfo;
  DateTime? changeTime;

  @override
  List<Avp> additionalAvps;

  LocationInfo({
    this.tgppUserLocationInfo,
    this.changeTime,
    this.additionalAvps = const [],
  });

  factory LocationInfo.fromAvps(List<Avp> avps) {
    // Factory implementation omitted for brevity
    return LocationInfo();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "tgppUserLocationInfo",
      AVP_TGPP_3GPP_USER_LOCATION_INFO,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("changeTime", AVP_TGPP_CHANGE_TIME, vendorId: VENDOR_TGPP),
  ];

  // toMap and updateFromMap omitted for brevity
  @override
  void updateFromMap(Map<String, dynamic> map) {
    tgppUserLocationInfo = map['tgppUserLocationInfo'];
    changeTime = map['changeTime'];
  }

  @override
  Map<String, dynamic> toMap() => {
    'tgppUserLocationInfo': tgppUserLocationInfo,
    'changeTime': changeTime,
  };
}

/// A data container for the "Coverage-Info" (3459) grouped AVP.
class CoverageInfo implements AvpGenerator {
  int? coverageStatus;
  DateTime? changeTime;
  List<LocationInfo> locationInfo;

  @override
  List<Avp> additionalAvps;

  CoverageInfo({
    this.coverageStatus,
    this.changeTime,
    this.locationInfo = const [],
    this.additionalAvps = const [],
  });

  factory CoverageInfo.fromAvps(List<Avp> avps) {
    // Factory implementation omitted for brevity
    return CoverageInfo();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef(
      "coverageStatus",
      AVP_TGPP_COVERAGE_STATUS,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("changeTime", AVP_TGPP_CHANGE_TIME, vendorId: VENDOR_TGPP),
    AvpGenDef(
      "locationInfo",
      AVP_TGPP_LOCATION_INFO,
      vendorId: VENDOR_TGPP,
      typeClass: LocationInfo,
    ),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'coverageStatus': coverageStatus,
    'changeTime': changeTime,
    'locationInfo': locationInfo,
  };

  // toMap and updateFromMap omitted for brevity
}

// ... and so on for TransmitterInfo, RadioParameterSetInfo, etc.
/// A data container for the "Accumulated-Cost" (2052) grouped AVP.
class AccumulatedCost implements AvpGenerator {
  int? valueDigits;
  int? exponent;

  @override
  List<Avp> additionalAvps;

  AccumulatedCost({
    this.valueDigits,
    this.exponent,
    this.additionalAvps = const [],
  });

  factory AccumulatedCost.fromAvps(List<Avp> avps) {
    var accumulatedCost = AccumulatedCost();
    for (var avp in avps) {
      if (avp.code == AVP_VALUE_DIGITS) {
        accumulatedCost.valueDigits = (avp as AvpInteger64).value;
      } else if (avp.code == AVP_EXPONENT) {
        accumulatedCost.exponent = (avp as AvpInteger32).value;
      } else {
        accumulatedCost.additionalAvps.add(avp);
      }
    }
    return accumulatedCost;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("valueDigits", AVP_VALUE_DIGITS, isRequired: true),
    AvpGenDef("exponent", AVP_EXPONENT),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'valueDigits': valueDigits,
    'exponent': exponent,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    valueDigits = map['valueDigits'];
    exponent = map['exponent'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Incremental-Cost" (2062) grouped AVP.
class IncrementalCost implements AvpGenerator {
  int? valueDigits;
  int? exponent;

  @override
  List<Avp> additionalAvps;

  IncrementalCost({
    this.valueDigits,
    this.exponent,
    this.additionalAvps = const [],
  });

  factory IncrementalCost.fromAvps(List<Avp> avps) {
    var incrementalCost = IncrementalCost();
    for (var avp in avps) {
      if (avp.code == AVP_VALUE_DIGITS) {
        incrementalCost.valueDigits = (avp as AvpInteger64).value;
      } else if (avp.code == AVP_EXPONENT) {
        incrementalCost.exponent = (avp as AvpInteger32).value;
      } else {
        incrementalCost.additionalAvps.add(avp);
      }
    }
    return incrementalCost;
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("valueDigits", AVP_VALUE_DIGITS, isRequired: true),
    AvpGenDef("exponent", AVP_EXPONENT),
  ];

  @override
  Map<String, dynamic> toMap() => {
    'valueDigits': valueDigits,
    'exponent': exponent,
    'additional_avps': additionalAvps,
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    valueDigits = map['valueDigits'];
    exponent = map['exponent'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }
}

/// A data container for the "Unit-Cost" (2061) grouped AVP.
class UnitCost implements AvpGenerator {
  int? valueDigits;
  int? exponent;

  @override
  List<Avp> additionalAvps;

  UnitCost({this.valueDigits, this.exponent, this.additionalAvps = const []});

  factory UnitCost.fromAvps(List<Avp> avps) {
    // Similar factory logic as above
    return UnitCost();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("valueDigits", AVP_VALUE_DIGITS, isRequired: true),
    AvpGenDef("exponent", AVP_EXPONENT),
  ];

  // toMap and updateFromMap omitted for brevity
  @override
  void updateFromMap(Map<String, dynamic> map) {
    valueDigits = map['valueDigits'];
    exponent = map['exponent'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }

  @override
  Map<String, dynamic> toMap() => {
    'valueDigits': valueDigits,
    'exponent': exponent,
    'additional_avps': additionalAvps,
  };
}

/// A data container for the "Scale-Factor" (2059) grouped AVP.
class ScaleFactor implements AvpGenerator {
  int? valueDigits;
  int? exponent;

  @override
  List<Avp> additionalAvps;

  ScaleFactor({
    this.valueDigits,
    this.exponent,
    this.additionalAvps = const [],
  });

  factory ScaleFactor.fromAvps(List<Avp> avps) {
    // Similar factory logic as above
    return ScaleFactor();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("valueDigits", AVP_VALUE_DIGITS, isRequired: true),
    AvpGenDef("exponent", AVP_EXPONENT),
  ];

  // toMap and updateFromMap omitted for brevity

  // toMap and updateFromMap omitted for brevity

  void updateFromMap(Map<String, dynamic> map) {
    valueDigits = map['valueDigits'];
    exponent = map['exponent'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }

  @override
  Map<String, dynamic> toMap() => {
    'valueDigits': valueDigits,
    'exponent': exponent,
    'additional_avps': additionalAvps,
  };
}

/// A data container for the "Rate-Element" (2058) grouped AVP.
class RateElement implements AvpGenerator {
  int? ccUnitType;
  int? chargeReasonCode;
  UnitValue? unitValue;
  UnitCost? unitCost;
  int? unitQuotaThreshold;

  @override
  List<Avp> additionalAvps;

  RateElement({
    this.ccUnitType,
    this.chargeReasonCode,
    this.unitValue,
    this.unitCost,
    this.unitQuotaThreshold,
    this.additionalAvps = const [],
  });

  factory RateElement.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return RateElement();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("ccUnitType", AVP_CC_UNIT_TYPE, isRequired: true),
    AvpGenDef(
      "chargeReasonCode",
      AVP_TGPP_CHARGE_REASON_CODE,
      vendorId: VENDOR_TGPP,
    ),
    AvpGenDef("unitValue", AVP_UNIT_VALUE, typeClass: UnitValue),
    AvpGenDef(
      "unitCost",
      AVP_TGPP_UNIT_COST,
      vendorId: VENDOR_TGPP,
      typeClass: UnitCost,
    ),
    AvpGenDef(
      "unitQuotaThreshold",
      AVP_TGPP_UNIT_QUOTA_THRESHOLD,
      vendorId: VENDOR_TGPP,
    ),
  ];

  // toMap and updateFromMap omitted for brevity
  void updateFromMap(Map<String, dynamic> map) {
    ccUnitType = map['ccUnitType'];
    chargeReasonCode = map['chargeReasonCode'];
    unitValue = map['unitValue'];
    unitCost = map['unitCost'];
    unitQuotaThreshold = map['unitQuotaThreshold'];
    additionalAvps = map['additional_avps'] as List<Avp>;
  }

  @override
  Map<String, dynamic> toMap() => {
    'ccUnitType': ccUnitType,
    'chargeReasonCode': chargeReasonCode,
    'unitValue': unitValue,
    'unitCost': unitCost,
    'unitQuotaThreshold': unitQuotaThreshold,
    'additional_avps': additionalAvps,
  };
}

/// A data container for the "Current-Tariff" (2056) grouped AVP.
class CurrentTariff implements AvpGenerator {
  int? currencyCode;
  ScaleFactor? scaleFactor;
  List<RateElement> rateElement;

  @override
  List<Avp> additionalAvps;

  CurrentTariff({
    this.currencyCode,
    this.scaleFactor,
    this.rateElement = const [],
    this.additionalAvps = const [],
  });

  factory CurrentTariff.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return CurrentTariff();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("currencyCode", AVP_CURRENCY_CODE),
    AvpGenDef(
      "scaleFactor",
      AVP_TGPP_SCALE_FACTOR,
      vendorId: VENDOR_TGPP,
      typeClass: ScaleFactor,
    ),
    AvpGenDef(
      "rateElement",
      AVP_TGPP_RATE_ELEMENT,
      vendorId: VENDOR_TGPP,
      typeClass: RateElement,
    ),
  ];

  // toMap and updateFromMap omitted for brevity

  // toMap and updateFromMap omitted for brevity
  void updateFromMap(Map<String, dynamic> map) {
    currencyCode = map['currencyCode'];
    scaleFactor = map['scaleFactor'];
    rateElement = map['rateElement'];
  }

  @override
  Map<String, dynamic> toMap() => {
    'currencyCode': currencyCode,
    'scaleFactor': scaleFactor,
    'rateElement': rateElement,
  };
}

/// A data container for the "Next-Tariff" (2057) grouped AVP.
class NextTariff implements AvpGenerator {
  int? currencyCode;
  ScaleFactor? scaleFactor;
  List<RateElement> rateElement;

  @override
  List<Avp> additionalAvps;

  NextTariff({
    this.currencyCode,
    this.scaleFactor,
    this.rateElement = const [],
    this.additionalAvps = const [],
  });

  factory NextTariff.fromAvps(List<Avp> avps) {
    // Factory logic omitted for brevity
    return NextTariff();
  }

  @override
  AvpGenType get avpDef => const [
    AvpGenDef("currencyCode", AVP_CURRENCY_CODE),
    AvpGenDef(
      "scaleFactor",
      AVP_TGPP_SCALE_FACTOR,
      vendorId: VENDOR_TGPP,
      typeClass: ScaleFactor,
    ),
    AvpGenDef(
      "rateElement",
      AVP_TGPP_RATE_ELEMENT,
      vendorId: VENDOR_TGPP,
      typeClass: RateElement,
    ),
  ];

  // toMap and updateFromMap omitted for brevity
  void updateFromMap(Map<String, dynamic> map) {
    currencyCode = map['currencyCode'];
    scaleFactor = map['scaleFactor'];
    rateElement = map['rateElement'];
  }

  @override
  Map<String, dynamic> toMap() => {
    'currencyCode': currencyCode,
    'scaleFactor': scaleFactor,
    'rateElement': rateElement,
  };
}
