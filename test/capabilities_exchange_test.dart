
import 'dart:convert';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('CapabilitiesExchange Tests', () {
    test('test_cer_create_new', () {
      var cer = CapabilitiesExchangeRequest();
      cer.originHost = utf8.encode("dra2.gy.mno.net");
      cer.originRealm = utf8.encode("mno.net");
      cer.hostIpAddress.add("10.12.56.109");
      cer.vendorId = 99999;
      cer.productName = "Dart Diameter Gy";
      cer.originStateId = 1689134718;
      cer.supportedVendorId.add(VENDOR_TGPP);
      cer.authApplicationId.add(APP_DIAMETER_CREDIT_CONTROL_APPLICATION);
      cer.inbandSecurityId.add(E_INBAND_SECURITY_ID_NO_INBAND_SECURITY);
      cer.acctApplicationId.add(APP_DIAMETER_CREDIT_CONTROL_APPLICATION);
      cer.firmwareRevision = 16777216;

      var msgBytes = cer.asBytes();

      expect(cer.header.length, equals(msgBytes.length));
      expect(cer.header.isRequest, isTrue);

      var parsedCer = Message.fromBytes(msgBytes) as CapabilitiesExchangeRequest;
      expect(parsedCer.productName, equals("Dart Diameter Gy"));
      expect(parsedCer.authApplicationId.first, equals(APP_DIAMETER_CREDIT_CONTROL_APPLICATION));
    });

    test('test_cea_create_new', () {
      var cea = CapabilitiesExchangeAnswer();
      cea.resultCode = E_RESULT_CODE_DIAMETER_SUCCESS;
      cea.originHost = utf8.encode("dra1.mvno.net");
      cea.originRealm = utf8.encode("mvno.net");
      cea.hostIpAddress.add("10.16.36.201");
      cea.vendorId = 39216;
      cea.productName = "Dart Diameter Gy";
      
      var msgBytes = cea.asBytes();
      
      expect(cea.header.length, equals(msgBytes.length));
      expect(cea.header.isRequest, isFalse);
    });

    test('test_cer_to_cea', () {
      var req = CapabilitiesExchangeRequest();
      var ans = req.toAnswer();

      expect(ans, isA<CapabilitiesExchangeAnswer>());
      expect(ans.header.isRequest, isFalse);
    });
  });
}
