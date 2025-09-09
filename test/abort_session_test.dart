
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('AbortSession Tests', () {
    test('test_asr_create_new', () {
      var asr = AbortSessionRequest();
      asr.sessionId = "epc.mnc003.mcc228.3gppnetwork.org;02472683";
      asr.originHost = utf8.encode("dra2.gy.mno.net") as Uint8List;
      asr.originRealm = utf8.encode("mno.net") as Uint8List;
      asr.destinationRealm = utf8.encode("mvno.net") as Uint8List;
      asr.destinationHost = utf8.encode("dra3.mvno.net") as Uint8List;
      asr.userName = "485079163847";
      asr.authApplicationId = APP_DIAMETER_COMMON_MESSAGES;

      var msgBytes = asr.asBytes();
      var parsedAsr = Message.fromBytes(msgBytes) as AbortSessionRequest;

      expect(asr.header.length, equals(msgBytes.length));
      expect(asr.header.isRequest, isTrue);
      expect(parsedAsr.userName, equals("485079163847"));
    });

    test('test_asa_create_new', () {
      var asa = AbortSessionAnswer();
      asa.sessionId = "epc.mnc003.mcc228.3gppnetwork.org;02472683";
      asa.resultCode = E_RESULT_CODE_DIAMETER_UNABLE_TO_COMPLY;
      asa.originHost = utf8.encode("dra3.mvno.net") as Uint8List;
      asa.originRealm = utf8.encode("mvno.net") as Uint8List;
      asa.errorMessage = "Not possible at this time";

      var msgBytes = asa.asBytes();
      var parsedAsa = Message.fromBytes(msgBytes) as AbortSessionAnswer;

      expect(asa.header.length, equals(msgBytes.length));
      expect(asa.header.isRequest, isFalse);
      expect(parsedAsa.errorMessage, equals("Not possible at this time"));
    });

    test('test_asr_to_asa', () {
      var req = AbortSessionRequest();
      var ans = req.toAnswer();

      expect(ans, isA<AbortSessionAnswer>());
      expect(ans.header.isRequest, isFalse);
    });
  });
}
