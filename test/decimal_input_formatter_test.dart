import 'package:e_fuel/helpers/decimal_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecimalInputFormatter', () {
    final formatter = DecimalInputFormatter();

    TextEditingValue apply(String oldText, String newText, {int? offset}) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: offset ?? newText.length),
        ),
      );
    }

    test('mengonversi keypad koma menjadi titik', () {
      final result = apply('68', '68,');
      expect(result.text, '68.');

      final result2 = apply('68.', '68,96');
      expect(result2.text, '68.96');
    });

    test('menolak lebih dari satu pemisah desimal', () {
      final result = apply('68.96', '68.96.');
      expect(result.text, '68.96');

      final result2 = apply('68.96', '68.96,');
      expect(result2.text, '68.96');
    });

    test('menolak karakter non-angka seperti huruf, spasi, minus', () {
      expect(apply('68', '68a').text, '68');
      expect(apply('68', '68 ').text, '68');
      expect(apply('68', '-68').text, '68');
    });

    test('auto-prefix 0 ketika mulai dengan titik atau koma', () {
      final resDot = apply('', '.');
      expect(resDot.text, '0.');
      expect(resDot.selection.baseOffset, 2);

      final resComma = apply('', ',5');
      expect(resComma.text, '0.5');
      expect(resComma.selection.baseOffset, 3);
    });

    test('mempertahankan posisi kursor saat edit di tengah angka', () {
      final result = apply('68.96', '608.96', offset: 2);
      expect(result.text, '608.96');
      expect(result.selection.baseOffset, 2);
    });

    test('mengizinkan menghapus sampai kosong', () {
      final result = apply('6', '');
      expect(result.text, '');
    });

    test('simulasi kasus Transfer Solar: pengambilan 150.0, aktual 68.96 -> sisa 81.04', () {
      final formatted = apply('68', '68,96');
      expect(formatted.text, '68.96');

      final double aktual = double.parse(formatted.text);
      const double pengambilan = 150.0;
      final double varian = double.parse((pengambilan - aktual).toStringAsFixed(2));

      expect(aktual <= pengambilan, isTrue);
      expect(varian, 81.04);
    });
  });
}
