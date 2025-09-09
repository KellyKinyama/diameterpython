
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('CreditControl 3GPP Service-Information Extensions', () {
    CreditControlRequest createBaseCcr() {
      var ccr = CreditControlRequest();
      ccr.sessionId = "sctp-saegwc-poz01.lte.orange.pl;221424325;287370797;65574b0c-2d02";
      ccr.originHost = utf8.encode("dra2.gy.mno.net") as Uint8List;
      ccr.originRealm = utf8.encode("mno.net") as Uint8List;
      ccr.destinationRealm = utf8.encode("mvno.net") as Uint8List;
      ccr.serviceContextId = SERVICE_CONTEXT_PS_CHARGING;
      ccr.ccRequestType = E_CC_REQUEST_TYPE_UPDATE_REQUEST;
      ccr.ccRequestNumber = 952;
      return ccr;
    }

    test('test_ccr_3gpp_dcd_information', () {
      var ccr = createBaseCcr();
      ccr.serviceInformation = ServiceInformation(
          dcdInformation: DcdInformation(
              contentId: "1", 
              contentProviderId: "id"));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(ccr.header.length, equals(msgBytes.length));
      expect(parsedCcr.serviceInformation?.dcdInformation?.contentId, equals("1"));
    });

    test('test_ccr_3gpp_im_information', () {
      var ccr = createBaseCcr();
      ccr.serviceInformation = ServiceInformation(
          imInformation: ImInformation(
              totalNumberOfMessagesSent: 1,
              totalNumberOfMessagesExploded: 1,
              numberOfMessagesSuccessfullySent: 5,
              numberOfMessagesSuccessfullyExploded: 5));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(ccr.header.length, equals(msgBytes.length));
      expect(parsedCcr.serviceInformation?.imInformation?.numberOfMessagesSuccessfullySent, equals(5));
    });

    test('test_ccr_3gpp_lcs_information', () {
      var ccr = createBaseCcr();
      ccr.serviceInformation = ServiceInformation(
          lcsInformation: LcsInformation(
              lcsClientId: LcsClientId(
                  lcsClientType: E_LCS_CLIENT_TYPE_EMERGENCY_SERVICES,
                  lcsClientExternalId: "ext id"),
              locationType: LocationType(
                  locationEstimateType: E_LOCATION_ESTIMATE_TYPE_CURRENT_LOCATION),
              msisdn: utf8.encode("41780000000") as Uint8List));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(ccr.header.length, equals(msgBytes.length));
      expect(parsedCcr.serviceInformation?.lcsInformation?.lcsClientId?.lcsClientExternalId, equals("ext id"));
    });

    test('test_ccr_3gpp_mbms_information', () {
      var ccr = createBaseCcr();
      ccr.serviceInformation = ServiceInformation(
          mbmsInformation: MbmsInformation(
              tmgi: Uint8List.fromList([0xff, 0xff]),
              mbmsServiceType: E_MBMS_SERVICE_TYPE_BROADCAST,
              mbmsUserServiceType: E_MBMS_USER_SERVICE_TYPE_STREAMING,
              fileRepairSupported: E_FILE_REPAIR_SUPPORTED_SUPPORTED));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(ccr.header.length, equals(msgBytes.length));
      expect(parsedCcr.serviceInformation?.mbmsInformation?.mbmsServiceType, equals(E_MBMS_SERVICE_TYPE_BROADCAST));
    });
    
    // Additional tests for MMTel, PoC, ProSe would follow the same pattern.
    // They are omitted here to keep the example concise, but the structure is identical.
  });
}
