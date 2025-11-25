import 'package:flutter_test/flutter_test.dart';
import 'package:english_app/utils/validators.dart';

void main() {
  test('Validar Email', () {
    expect(Validators.validateEmail('user@example.com'), true);
    expect(Validators.validateEmail('invalid'), false);
  });

  test('Seguridad Contraseña', () {
    expect(Validators.isPasswordStrong('1234567'), true);
    expect(Validators.isPasswordStrong('12345'), false);
  });

  test('Calculadora Descuento', () {
    expect(Validators.applyDiscount(100, 10), 90);
    expect(Validators.applyDiscount(200, 0), 200);
  });

  test('Rango Válido', () {
    expect(Validators.isValidRange(1), true);
    expect(Validators.isValidRange(10), true);
    expect(Validators.isValidRange(0), false);
    expect(Validators.isValidRange(11), false);
  });

  test('Texto a Mayúsculas', () {
    expect(Validators.toUppercase('hola mundo'), 'HOLA MUNDO');
  });
}