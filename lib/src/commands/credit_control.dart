import '../../diameter.dart';

/// A Credit-Control message (CCR/CCA).
///
/// See RFC 8506 for details.
abstract class CreditControl extends DefinedMessage {
  static const int CODE = 272;
  static const String NAME = "Credit-Control";

  @override
  int get code => CODE;
  @override
  String get name => NAME;

  CreditControl({super.header, super.avps});

  /// Factory to create the correct message type (Request or Answer) from a header.
  static Message? typeFactory(MessageHeader header) {
    if (header.isRequest) {
      return CreditControlRequest(header: header);
    } else {
      return CreditControlAnswer(header: header);
    }
  }
}

/// A Credit-Control-Answer message.
class CreditControlAnswer extends CreditControl {
  String? sessionId;
  int? resultCode;
  Uint8List? originHost;
  Uint8List? originRealm;
  int? authApplicationId;
  int? ccRequestType;
  int? ccRequestNumber;
  String? userName;
  int? ccSessionFailover;
  int? ccSubSessionId;
  Uint8List? acctMultiSessionId;
  int? originStateId;
  DateTime? eventTimestamp;
  GrantedServiceUnit? grantedServiceUnit;
  List<MultipleServicesCreditControl> multipleServicesCreditControl = [];
  CostInformation? costInformation;
  FinalUnitIndication? finalUnitIndication;
  QosFinalUnitIndication? qosFinalUnitIndication;
  int? checkBalanceResult;
  int? creditControlFailureHandling;
  int? directDebitingFailureHandling;
  int? validityTime;
  List<String> redirectHost = [];
  int? redirectHostUsage;
  int? redirectMaxCacheTime;
  List<ProxyInfo> proxyInfo = [];
  List<Uint8List> routeRecord = [];
  List<FailedAvp> failedAvp = [];

  // 3GPP extensions
  int? lowBalanceIndication;
  RemainingBalance? remainingBalance;
  OcSupportedFeatures? ocSupportedFeatures;
  OcOlr? ocOlr;
  ServiceInformation? serviceInformation;

  CreditControlAnswer({super.header, super.avps}) {
    header.isRequest = false;
    header.isProxyable = true;
    authApplicationId = APP_DIAMETER_CREDIT_CONTROL_APPLICATION;

    assignAttributesFromAvps(this, avps);
    super.avps = []; // Clear the raw AVP list
  }
  
  @override
  final AvpGenType avpDef = const [
      AvpGenDef("session_id", AVP_SESSION_ID, isRequired: true),
      AvpGenDef("result_code", AVP_RESULT_CODE, isRequired: true),
      AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true, isMandatory: false),
      AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true, isMandatory: false),
      AvpGenDef("auth_application_id", AVP_AUTH_APPLICATION_ID, isRequired: true),
      AvpGenDef("cc_request_type", AVP_CC_REQUEST_TYPE, isRequired: true),
      AvpGenDef("cc_request_number", AVP_CC_REQUEST_NUMBER, isRequired: true),
      AvpGenDef("user_name", AVP_USER_NAME),
      AvpGenDef("cc_session_failover", AVP_CC_SESSION_FAILOVER),
      AvpGenDef("cc_sub_session_id", AVP_CC_SUB_SESSION_ID),
      AvpGenDef("acct_multi_session_id", AVP_ACCOUNTING_MULTI_SESSION_ID),
      AvpGenDef("origin_state_id", AVP_ORIGIN_STATE_ID),
      AvpGenDef("event_timestamp", AVP_EVENT_TIMESTAMP),
      AvpGenDef("granted_service_unit", AVP_GRANTED_SERVICE_UNIT, typeClass: GrantedServiceUnit),
      AvpGenDef("multiple_services_credit_control", AVP_MULTIPLE_SERVICES_CREDIT_CONTROL, typeClass: MultipleServicesCreditControl),
      AvpGenDef("cost_information", AVP_COST_INFORMATION, typeClass: CostInformation),
      AvpGenDef("final_unit_indication", AVP_FINAL_UNIT_INDICATION, typeClass: FinalUnitIndication),
      AvpGenDef("qos_final_unit_indication", AVP_QOS_FINAL_UNIT_INDICATION, typeClass: QosFinalUnitIndication),
      AvpGenDef("check_balance_result", AVP_CHECK_BALANCE_RESULT),
      AvpGenDef("credit_control_failure_handling", AVP_CREDIT_CONTROL_FAILURE_HANDLING),
      AvpGenDef("direct_debiting_failure_handling", AVP_DIRECT_DEBITING_FAILURE_HANDLING),
      AvpGenDef("validity_time", AVP_VALIDITY_TIME),
      AvpGenDef("redirect_host", AVP_REDIRECT_HOST),
      AvpGenDef("redirect_host_usage", AVP_REDIRECT_HOST_USAGE),
      AvpGenDef("redirect_max_cache_time", AVP_REDIRECT_MAX_CACHE_TIME),
      AvpGenDef("proxy_info", AVP_PROXY_INFO, typeClass: ProxyInfo),
      AvpGenDef("route_record", AVP_ROUTE_RECORD),
      AvpGenDef("failed_avp", AVP_FAILED_AVP, typeClass: FailedAvp),
      AvpGenDef("low_balance_indication", AVP_TGPP_LOW_BALANCE_INDICATION, vendorId: VENDOR_TGPP),
      AvpGenDef("remaining_balance", AVP_TGPP_REMAINING_BALANCE, vendorId: VENDOR_TGPP, typeClass: RemainingBalance),
      AvpGenDef("oc_supported_features", AVP_OC_SUPPORTED_FEATURES, typeClass: OcSupportedFeatures),
      AvpGenDef("oc_olr", AVP_OC_OLR, vendorId: VENDOR_TGPP, typeClass: OcOlr),
      AvpGenDef("service_information", AVP_TGPP_SERVICE_INFORMATION, vendorId: VENDOR_TGPP, typeClass: ServiceInformation),
  ];

  @override
  Map<String, dynamic> toMap() => {
    "session_id": sessionId,
    "result_code": resultCode,
    "origin_host": originHost,
    "origin_realm": originRealm,
    "auth_application_id": authApplicationId,
    "cc_request_type": ccRequestType,
    "cc_request_number": ccRequestNumber,
    "user_name": userName,
    "cc_session_failover": ccSessionFailover,
    "cc_sub_session_id": ccSubSessionId,
    "acct_multi_session_id": acctMultiSessionId,
    "origin_state_id": originStateId,
    "event_timestamp": eventTimestamp,
    "granted_service_unit": grantedServiceUnit,
    "multiple_services_credit_control": multipleServicesCreditControl,
    "cost_information": costInformation,
    "final_unit_indication": finalUnitIndication,
    "qos_final_unit_indication": qosFinalUnitIndication,
    "check_balance_result": checkBalanceResult,
    "credit_control_failure_handling": creditControlFailureHandling,
    "direct_debiting_failure_handling": directDebitingFailureHandling,
    "validity_time": validityTime,
    "redirect_host": redirectHost,
    "redirect_host_usage": redirectHostUsage,
    "redirect_max_cache_time": redirectMaxCacheTime,
    "proxy_info": proxyInfo,
    "route_record": routeRecord,
    "failed_avp": failedAvp,
    "low_balance_indication": lowBalanceIndication,
    "remaining_balance": remainingBalance,
    "oc_supported_features": ocSupportedFeatures,
    "oc_olr": ocOlr,
    "service_information": serviceInformation,
    "additional_avps": additionalAvps
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    sessionId = map["session_id"];
    resultCode = map["result_code"];
    originHost = map["origin_host"];
    originRealm = map["origin_realm"];
    authApplicationId = map["auth_application_id"];
    ccRequestType = map["cc_request_type"];
    ccRequestNumber = map["cc_request_number"];
    userName = map["user_name"];
    ccSessionFailover = map["cc_session_failover"];
    ccSubSessionId = map["cc_sub_session_id"];
    acctMultiSessionId = map["acct_multi_session_id"];
    originStateId = map["origin_state_id"];
    eventTimestamp = map["event_timestamp"];
    grantedServiceUnit = map["granted_service_unit"];
    multipleServicesCreditControl = map["multiple_services_credit_control"];
    costInformation = map["cost_information"];
    finalUnitIndication = map["final_unit_indication"];
    qosFinalUnitIndication = map["qos_final_unit_indication"];
    checkBalanceResult = map["check_balance_result"];
    creditControlFailureHandling = map["credit_control_failure_handling"];
    directDebitingFailureHandling = map["direct_debiting_failure_handling"];
    validityTime = map["validity_time"];
    redirectHost = map["redirect_host"];
    redirectHostUsage = map["redirect_host_usage"];
    redirectMaxCacheTime = map["redirect_max_cache_time"];
    proxyInfo = map["proxy_info"];
    routeRecord = map["route_record"];
    failedAvp = map["failed_avp"];
    lowBalanceIndication = map["low_balance_indication"];
    remainingBalance = map["remaining_balance"];
    ocSupportedFeatures = map["oc_supported_features"];
    ocOlr = map["oc_olr"];
    serviceInformation = map["service_information"];
  }
}

/// A Credit-Control-Request message.
class CreditControlRequest extends CreditControl {
  String? sessionId;
  Uint8List? originHost;
  Uint8List? originRealm;
  Uint8List? destinationRealm;
  int? authApplicationId;
  String? serviceContextId;
  int? ccRequestType;
  int? ccRequestNumber;
  Uint8List? destinationHost;
  String? userName;
  int? ccSubSessionId;
  Uint8List? acctMultiSessionId;
  int? originStateId;
  DateTime? eventTimestamp;
  List<SubscriptionId> subscriptionId = [];
  int? serviceIdentifier;
  int? terminationCause;
  RequestedServiceUnit? requestedServiceUnit;
  int? requestedAction;
  List<UsedServiceUnit> usedServiceUnit = [];
  int? multipleServicesIndicator;
  List<MultipleServicesCreditControl> multipleServicesCreditControl = [];
  List<ServiceParameterInfo> serviceParameterInfo = [];
  Uint8List? ccCorrelationId;
  UserEquipmentInfo? userEquipmentInfo;
  List<ProxyInfo> proxyInfo = [];
  List<Uint8List> routeRecord = [];

  // 3GPP extensions
  ServiceInformation? serviceInformation;

  CreditControlRequest({super.header, super.avps}) {
    header.isRequest = true;
    header.isProxyable = true;
    authApplicationId = APP_DIAMETER_CREDIT_CONTROL_APPLICATION;

    assignAttributesFromAvps(this, avps);
    super.avps = []; // Clear the raw AVP list
  }

  @override
  final AvpGenType avpDef = const [
      AvpGenDef("session_id", AVP_SESSION_ID, isRequired: true),
      AvpGenDef("origin_host", AVP_ORIGIN_HOST, isRequired: true, isMandatory: false),
      AvpGenDef("origin_realm", AVP_ORIGIN_REALM, isRequired: true, isMandatory: false),
      AvpGenDef("destination_realm", AVP_DESTINATION_REALM, isRequired: true),
      AvpGenDef("auth_application_id", AVP_AUTH_APPLICATION_ID, isRequired: true),
      AvpGenDef("service_context_id", AVP_SERVICE_CONTEXT_ID, isRequired: true),
      AvpGenDef("cc_request_type", AVP_CC_REQUEST_TYPE, isRequired: true),
      AvpGenDef("cc_request_number", AVP_CC_REQUEST_NUMBER, isRequired: true),
      AvpGenDef("destination_host", AVP_DESTINATION_HOST, isMandatory: false),
      AvpGenDef("user_name", AVP_USER_NAME),
      AvpGenDef("cc_sub_session_id", AVP_CC_SUB_SESSION_ID),
      AvpGenDef("acct_multi_session_id", AVP_ACCOUNTING_MULTI_SESSION_ID),
      AvpGenDef("origin_state_id", AVP_ORIGIN_STATE_ID),
      AvpGenDef("event_timestamp", AVP_EVENT_TIMESTAMP),
      AvpGenDef("subscription_id", AVP_SUBSCRIPTION_ID, typeClass: SubscriptionId),
      AvpGenDef("service_identifier", AVP_SERVICE_IDENTIFIER),
      AvpGenDef("termination_cause", AVP_TERMINATION_CAUSE),
      AvpGenDef("requested_service_unit", AVP_REQUESTED_SERVICE_UNIT, typeClass: RequestedServiceUnit),
      AvpGenDef("requested_action", AVP_REQUESTED_ACTION),
      AvpGenDef("used_service_unit", AVP_USED_SERVICE_UNIT, typeClass: UsedServiceUnit),
      AvpGenDef("multiple_services_indicator", AVP_MULTIPLE_SERVICES_INDICATOR),
      AvpGenDef("multiple_services_credit_control", AVP_MULTIPLE_SERVICES_CREDIT_CONTROL, typeClass: MultipleServicesCreditControl),
      AvpGenDef("service_parameter_info", AVP_SERVICE_PARAMETER_INFO, typeClass: ServiceParameterInfo),
      AvpGenDef("cc_correlation_id", AVP_CC_CORRELATION_ID),
      AvpGenDef("user_equipment_info", AVP_USER_EQUIPMENT_INFO, typeClass: UserEquipmentInfo),
      AvpGenDef("proxy_info", AVP_PROXY_INFO, typeClass: ProxyInfo),
      AvpGenDef("route_record", AVP_ROUTE_RECORD),
      AvpGenDef("service_information", AVP_TGPP_SERVICE_INFORMATION, vendorId: VENDOR_TGPP, typeClass: ServiceInformation),
  ];

  @override
  Map<String, dynamic> toMap() => {
    "session_id": sessionId,
    "origin_host": originHost,
    "origin_realm": originRealm,
    "destination_realm": destinationRealm,
    "auth_application_id": authApplicationId,
    "service_context_id": serviceContextId,
    "cc_request_type": ccRequestType,
    "cc_request_number": ccRequestNumber,
    "destination_host": destinationHost,
    "user_name": userName,
    "cc_sub_session_id": ccSubSessionId,
    "acct_multi_session_id": acctMultiSessionId,
    "origin_state_id": originStateId,
    "event_timestamp": eventTimestamp,
    "subscription_id": subscriptionId,
    "service_identifier": serviceIdentifier,
    "termination_cause": terminationCause,
    "requested_service_unit": requestedServiceUnit,
    "requested_action": requestedAction,
    "used_service_unit": usedServiceUnit,
    "multiple_services_indicator": multipleServicesIndicator,
    "multiple_services_credit_control": multipleServicesCreditControl,
    "service_parameter_info": serviceParameterInfo,
    "cc_correlation_id": ccCorrelationId,
    "user_equipment_info": userEquipmentInfo,
    "proxy_info": proxyInfo,
    "route_record": routeRecord,
    "service_information": serviceInformation,
    "additional_avps": additionalAvps
  };

  @override
  void updateFromMap(Map<String, dynamic> map) {
    sessionId = map["session_id"];
    originHost = map["origin_host"];
    originRealm = map["origin_realm"];
    destinationRealm = map["destination_realm"];
    authApplicationId = map["auth_application_id"];
    serviceContextId = map["service_context_id"];
    ccRequestType = map["cc_request_type"];
    ccRequestNumber = map["cc_request_number"];
    destinationHost = map["destination_host"];
    userName = map["user_name"];
    ccSubSessionId = map["cc_sub_session_id"];
    acctMultiSessionId = map["acct_multi_session_id"];
    originStateId = map["origin_state_id"];
    eventTimestamp = map["event_timestamp"];
    subscriptionId = map["subscription_id"];
    serviceIdentifier = map["service_identifier"];
    terminationCause = map["termination_cause"];
    requestedServiceUnit = map["requested_service_unit"];
    requestedAction = map["requested_action"];
    usedServiceUnit = map["used_service_unit"];
    multipleServicesIndicator = map["multiple_services_indicator"];
    multipleServicesCreditControl = map["multiple_services_credit_control"];
    serviceParameterInfo = map["service_parameter_info"];
    ccCorrelationId = map["cc_correlation_id"];
    userEquipmentInfo = map["user_equipment_info"];
    proxyInfo = map["proxy_info"];
    routeRecord = map["route_record"];
    serviceInformation = map["service_information"];
  }
}
