
import 'dart:convert';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('CreditControl Tests', () {
    test('test_ccr_create_new', () {
      var ccr = CreditControlRequest();
      ccr.sessionId = "sctp-saegwc-poz01.lte.orange.pl;221424325;287370797;65574b0c-2d02";
      ccr.originHost = utf8.encode("dra2.gy.mno.net");
      ccr.originRealm = utf8.encode("mno.net");
      ccr.destinationRealm = utf8.encode("mvno.net");
      ccr.serviceContextId = SERVICE_CONTEXT_PS_CHARGING;
      ccr.ccRequestType = E_CC_REQUEST_TYPE_UPDATE_REQUEST;
      ccr.ccRequestNumber = 952;
      ccr.userName = "user@example.com";
      
      ccr.subscriptionId.add(SubscriptionId(
          subscriptionIdType: E_SUBSCRIPTION_ID_TYPE_END_USER_E164,
          subscriptionIdData: "485089163847"));

      ccr.multipleServicesCreditControl.add(MultipleServicesCreditControl(
          requestedServiceUnit: RequestedServiceUnit(ccTotalOctets: 0),
          usedServiceUnit: [UsedServiceUnit(ccTotalOctets: 998415321)],
          additionalAvps: [
            Avp.newAvp(AVP_TGPP_3GPP_REPORTING_REASON,
                vendorId: VENDOR_TGPP, value: 2)
          ]));

      var msgBytes = ccr.asBytes();
      var parsedCcr = Message.fromBytes(msgBytes) as CreditControlRequest;

      expect(ccr.header.length, equals(msgBytes.length));
      expect(parsedCcr.sessionId, equals(ccr.sessionId));
      expect(parsedCcr.multipleServicesCreditControl.first.usedServiceUnit!.first.ccTotalOctets, equals(998415321));
    });

    test('test_cca_create_new', () {
        var cca = CreditControlAnswer();
        cca.sessionId = "sctp-saegwc-poz01.lte.orange.pl;221424325;287370797;65574b0c-2d02";
        cca.originHost = utf8.encode("ocs6.mvno.net");
        cca.originRealm = utf8.encode("mvno.net");
        cca.ccRequestNumber = 952;
        cca.resultCode = E_RESULT_CODE_DIAMETER_SUCCESS;
        cca.ccRequestType = E_CC_REQUEST_TYPE_UPDATE_REQUEST;

        cca.multipleServicesCreditControl.add(MultipleServicesCreditControl(
            grantedServiceUnit: GrantedServiceUnit(ccTotalOctets: 174076000),
            ratingGroup: 8000,
            validityTime: 3600,
            resultCode: E_RESULT_CODE_DIAMETER_SUCCESS));
        
        var msgBytes = cca.asBytes();
        var parsedCca = Message.fromBytes(msgBytes) as CreditControlAnswer;

        expect(cca.header.length, equals(msgBytes.length));
        expect(parsedCca.multipleServicesCreditControl.first.ratingGroup, equals(8000));
    });
  });
}
