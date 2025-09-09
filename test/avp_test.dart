
import 'dart:typed_data';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:diameter/diameter.dart';

void main() {
  group('AVP Tests', () {
    test('test_create_from_new', () {
      var a = Avp.newAvp(AVP_ORIGIN_HOST, value: utf8.encode("dra4.gy.mvno.net"));
      expect(a.code, equals(AVP_ORIGIN_HOST));
      expect(a.value, equals(utf8.encode("dra4.gy.mvno.net")));
      expect(a.isMandatory, isTrue);
    });

    test('test_decode_from_bytes', () {
      var avpBytes = Uint8List.fromList([0, 0, 1, 205, 64, 0, 0, 22, 51, 50, 50, 53, 49, 64, 51, 103, 112, 112, 46, 111, 114, 103, 0, 0]);
      var a = Avp.fromBytes(avpBytes);

      expect(a.code, equals(461));
      expect(a.isMandatory, isTrue);
      expect(a.isPrivate, isFalse);
      expect(a.isVendor, isFalse);
      expect(a.length, equals(24)); // Note: Length includes padding
      expect(a.value, equals("32251@3gpp.org"));
    });

    test('test_create_address_type', () {
      var a = AvpAddress(code: AVP_TGPP_SGSN_ADDRESS);
      
      a.value = "193.16.219.96";
      expect(a.value, equals((1, "193.16.219.96")));
      expect(a.payload, equals(Uint8List.fromList([0, 1, 193, 16, 219, 96])));

      a.value = "8b71:8c8a:1e29:716a:6184:7966:fd43:4200";
      expect(a.value, equals((2, "8b71:8c8a:1e29:716a:6184:7966:fd43:4200")));

      a.value = "48507909008";
      expect(a.value, equals((8, "48507909008")));
    });

    test('test_create_time_type', () {
      var a = AvpTime(code: AVP_EVENT_TIMESTAMP);
      var now = DateTime.now().toUtc();
      a.value = now;

      // Dart DateTime has microsecond precision, AVP time does not.
      var nowSeconds = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - (now.millisecondsSinceEpoch % 1000), isUtc: true);
      expect(a.value, equals(nowSeconds));
    });

    test('test_create_grouped_type', () {
      var ag = AvpGrouped(code: AVP_SUBSCRIPTION_ID);
      var at = Avp.newAvp(AVP_SUBSCRIPTION_ID_TYPE, value: 0);
      var ad = Avp.newAvp(AVP_SUBSCRIPTION_ID_DATA, value: "485079164547");

      ag.value = [at, ad];

      expect(ag.value.length, equals(2));
      expect((ag.value[0] as AvpInteger32).value, equals(0));
      expect((ag.value[1] as AvpUtf8String).value, equals("485079164547"));
      
      var expectedPayload = BytesBuilder();
      expectedPayload.add(at.asBytes());
      expectedPayload.add(ad.asBytes());
      expect(ag.payload, equals(expectedPayload.toBytes()));
    });

    test('test_error_handling', () {
      // Test invalid value for Integer32
      expect(() {
        Avp.newAvp(AVP_ACCT_INPUT_PACKETS, value: "not a number");
      }, throwsA(isA<AvpEncodeError>()));

      // Test decoding invalid bytes
      var shortBytes = Uint8List.fromList([0, 0, 1, 205, 64, 0, 0, 22, 51, 50]);
      expect(() {
        Avp.fromBytes(shortBytes);
      }, throwsA(isA<AvpDecodeError>()));
    });
  });
}
