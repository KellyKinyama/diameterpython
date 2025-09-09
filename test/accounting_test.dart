
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('Accounting Tests', () {
    test('test_acr_create_new', () {
      var acr = AccountingRequest();
      acr.sessionId = "labdra.gy.mno.net;02472683";
      acr.originHost = utf8.encode("dra2.gy.mno.net") as Uint8List;
      acr.originRealm = utf8.encode("mno.net") as Uint8List;
      acr.destinationRealm = utf8.encode("mvno.net") as Uint8List;
      acr.accountingRecordType = E_ACCOUNTING_RECORD_TYPE_EVENT_RECORD;
      acr.accountingRecordNumber = 789874;
      acr.acctApplicationId = APP_DIAMETER_BASE_ACCOUNTING;
      acr.userName = "485079163847";
      acr.destinationHost = utf8.encode("dra3.mvno.net") as Uint8List;
      acr.accountingSubSessionId = 233487;
      acr.acctSessionId = utf8.encode("radius.mno.net;02472683") as Uint8List;
      acr.acctMultiSessionId = "labdra.gy.mno.net;02472683";
      acr.acctInterimInterval = 0;
      acr.accountingRealtimeRequired = E_ACCOUNTING_REALTIME_REQUIRED_DELIVER_AND_GRANT;
      acr.originStateId = 1689134718;
      acr.eventTimestamp = DateTime.utc(2023, 11, 17, 14, 6, 1);
      acr.proxyInfo.add(ProxyInfo(
          proxyHost: utf8.encode("swlab.roam.server.net") as Uint8List,
          proxyState: Uint8List.fromList([0, 0])));
      acr.routeRecord.add(utf8.encode("ix1csdme221.epc.mnc003.mcc228.3gppnetwork.org") as Uint8List);

      var msgBytes = acr.asBytes();
      var parsedAcr = Message.fromBytes(msgBytes) as AccountingRequest;

      expect(acr.header.length, equals(msgBytes.length));
      expect(acr.header.isRequest, isTrue);
      expect(parsedAcr.accountingRecordNumber, equals(789874));
    });

    test('test_aca_create_new', () {
      var aca = AccountingAnswer();
      aca.sessionId = "labdra.gy.mno.net;02472683";
      aca.resultCode = E_RESULT_CODE_SESSION_EXISTS;
      aca.originHost = utf8.encode("dra3.mvno.net") as Uint8List;
      aca.originRealm = utf8.encode("mvno.net") as Uint8List;
      aca.accountingRecordType = E_ACCOUNTING_RECORD_TYPE_EVENT_RECORD;
      aca.accountingRecordNumber = 789874;
      aca.failedAvp = FailedAvp(additionalAvps: [
        Avp.newAvp(AVP_ORIGIN_HOST, value: utf8.encode("dra2.gy.mno.net"))
      ]);

      var msgBytes = aca.asBytes();
      var parsedAca = Message.fromBytes(msgBytes) as AccountingAnswer;

      expect(aca.header.length, equals(msgBytes.length));
      expect(aca.header.isRequest, isFalse);
      expect(parsedAca.resultCode, equals(E_RESULT_CODE_SESSION_EXISTS));
    });

    test('test_acr_to_aca', () {
      var req = AccountingRequest();
      var ans = req.toAnswer();

      expect(ans, isA<AccountingAnswer>());
      expect(ans.header.isRequest, isFalse);
    });
  });
}
