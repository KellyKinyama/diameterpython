
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('AaMobileNode Tests', () {
    test('test_amr_create_new', () {
      var amr = AaMobileNodeRequest();
      amr.sessionId = "dra1.local.realm;1;2;3";
      amr.authApplicationId = 2;
      amr.userName = "19490909";
      amr.destinationRealm = utf8.encode("local.realm") as Uint8List;
      amr.originHost = utf8.encode("dra1.local.realm") as Uint8List;
      amr.originRealm = utf8.encode("local.realm") as Uint8List;
      amr.mipRegRequest = Uint8List.fromList([0x01, 0x0f, 0x0f]);
      amr.mipMnAaaAuth = MipMnAaaAuth(
          mipMnAaaSpi: 1,
          mipAuthenticatorLength: 1,
          mipAuthenticatorOffset: 1,
          mipAuthInputDataLength: 1);
      amr.authorizationLifetime = 1200;
      amr.authSessionState = E_AUTH_SESSION_STATE_STATE_MAINTAINED;

      var msgBytes = amr.asBytes();
      var parsedAmr = Message.fromBytes(msgBytes) as AaMobileNodeRequest;

      expect(amr.header.length, equals(msgBytes.length));
      expect(amr.header.isRequest, isTrue);
      expect(parsedAmr.userName, equals("19490909"));
      expect(parsedAmr.mipMnAaaAuth?.mipMnAaaSpi, equals(1));
    });

    test('test_ama_create_new', () {
      var ama = AaMobileNodeAnswer();
      ama.sessionId = "dra1.local.realm;1;2;3";
      ama.authApplicationId = 2;
      ama.resultCode = E_RESULT_CODE_DIAMETER_UNABLE_TO_COMPLY;
      ama.originHost = utf8.encode("dra2.local.realm") as Uint8List;
      ama.originRealm = utf8.encode("local.realm") as Uint8List;
      ama.userName = "19490909";
      ama.mipFilterRule.add(utf8.encode("permit in ip from 10.0.0.1 to 10.0.0.99") as Uint8List);

      var msgBytes = ama.asBytes();
      var parsedAma = Message.fromBytes(msgBytes) as AaMobileNodeAnswer;

      expect(ama.header.length, equals(msgBytes.length));
      expect(ama.header.isRequest, isFalse);
      expect(utf8.decode(parsedAma.mipFilterRule.first), "permit in ip from 10.0.0.1 to 10.0.0.99");
    });
  });
}
