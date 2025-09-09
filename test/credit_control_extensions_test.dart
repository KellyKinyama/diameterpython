
import 'dart:convert';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('CreditControl 3GPP Extensions', () {
    test('test_ccr_3gpp_aoc_information', () {
      var ccr = CreditControlRequest();
      ccr.sessionId = "sctp-saegwc-poz01.lte.orange.pl;221424325;287370797;65574b0c-2d02";
      ccr.originHost = utf8.encode("dra2.gy.mno.net");
      ccr.originRealm = utf8.encode("mno.net");
      ccr.destinationRealm = utf8.encode("mvno.net");
      ccr.serviceContextId = SERVICE_CONTEXT_PS_CHARGING;
      ccr.ccRequestType = E_CC_REQUEST_TYPE_UPDATE_REQUEST;
      ccr.ccRequestNumber = 952;

      ccr.serviceInformation = ServiceInformation(
          aocInformation: AocInformation(
              aocCostInformation: AocCostInformation(
                  accumulatedCost: AccumulatedCost(valueDigits: 10, exponent: 2),
                  currencyCode: 10),
              aocSubscriptionInformation: AocSubscriptionInformation(
                  aocService: [
                AocService(
                    aocServiceObligatoryType: E_AOC_SERVICE_TYPE_NONE,
                    aocServiceType: E_AOC_REQUEST_TYPE_AOC_TARIFF_ONLY)
              ],
                  aocFormat: E_AOC_FORMAT_MONETARY,
                  preferredAocCurrency: 99)));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(ccr.header.length, equals(msgBytes.length));
      expect(parsedCcr.serviceInformation?.aocInformation?.aocCostInformation?.currencyCode, equals(10));
    });

    test('test_ccr_3gpp_cpdt_information', () {
      var ccr = CreditControlRequest();
      // Set mandatory fields
      ccr.sessionId = "session1";
      ccr.originHost = utf8.encode("host1");
      ccr.originRealm = utf8.encode("realm1");
      ccr.destinationRealm = utf8.encode("realm2");
      ccr.serviceContextId = SERVICE_CONTEXT_CPDT_CHARGING;
      ccr.ccRequestType = E_CC_REQUEST_TYPE_EVENT_REQUEST;
      ccr.ccRequestNumber = 1;

      ccr.serviceInformation = ServiceInformation(
          cpdtInformation: CpdtInformation(
              externalIdentifier: "ext id",
              niddSubmission: NiddSubmission(
                  accountingInputOctets: 5543,
                  accountingOutputOctets: 8758453)));
                  
      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(parsedCcr.serviceInformation?.cpdtInformation?.externalIdentifier, equals("ext id"));
    });

    test('test_ccr_3gpp_service_generic_information', () {
      var ccr = CreditControlRequest();
      // Set mandatory fields
      ccr.sessionId = "session1";
      ccr.originHost = utf8.encode("host1");
      ccr.originRealm = utf8.encode("realm1");
      ccr.destinationRealm = utf8.encode("realm2");
      ccr.serviceContextId = SERVICE_CONTEXT_PS_CHARGING;
      ccr.ccRequestType = E_CC_REQUEST_TYPE_EVENT_REQUEST;
      ccr.ccRequestNumber = 1;

      ccr.serviceInformation = ServiceInformation(
          serviceGenericInformation: ServiceGenericInformation(
              applicationServerId: 1,
              applicationServiceType: E_APPLICATION_SERVICE_TYPE_RECEIVING,
              applicationSessionId: 5,
              deliveryStatus: "delivered"));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;
      
      expect(parsedCcr.serviceInformation?.serviceGenericInformation?.applicationSessionId, equals(5));
    });
  });
}
