import 'package:flutter_test/flutter_test.dart';
import 'package:siagenda_app/models/user_model.dart';
import 'test_doubles/stub_auth_service.dart';

/// ============================================================================
/// UNIT TESTING DENGAN TEST DOUBLE: STUB & MOCK
/// Target: StubAuthService (Canned Responses & Interaction Verification)
/// Format: Pola AAA (Arrange, Act, Assert)
/// ============================================================================
void main() {
  late StubAuthService authService;

  setUp(() {
    authService = StubAuthService();
  });

  group('Stub & Mock - Login Authentication Workflow', () {
    test('Positif: Login berhasil mengembalikan data UserModel dan Mock memverifikasi interaksi', () async {
      // Arrange
      final expectedUser = UserModel(
        id: 'user-aptika-123',
        username: 'aptika_operator',
        nama: 'Operator Aptika Diskominfo',
        role: 'operator',
        bidang: 'Aplikasi Informatika',
        email: 'aptika@diskominfo.go.id',
      );
      authService.stubUser = expectedUser;

      // Act
      final result = await authService.login('aptika_operator', 'Password123');

      // Assert
      // 1. Verifikasi Data (Stub)
      expect(result.id, equals('user-aptika-123'));
      expect(result.username, equals('aptika_operator'));
      expect(result.nama, equals('Operator Aptika Diskominfo'));
      expect(result.role, equals('operator'));
      expect(result.isOperator, isTrue);

      // 2. Verifikasi Perilaku / Interaksi (Mock)
      expect(authService.loginCallCount, equals(1));
      expect(authService.lastLoginUsername, equals('aptika_operator'));
      expect(authService.lastLoginPassword, equals('Password123'));
    });

    test('Negatif: Login gagal dengan kredensial salah (Stub melempar Exception kredensial salah)', () async {
      // Arrange
      authService.stubLoginError = Exception('Username atau password salah.');

      // Act & Assert
      expect(
        () async => await authService.login('user_salah', 'pass_salah'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'error message',
          contains('Username atau password salah.'),
        )),
      );

      // Mock Behavioral Assertion
      expect(authService.loginCallCount, equals(1));
      expect(authService.lastLoginUsername, equals('user_salah'));
    });

    test('Negatif: Login gagal karena gangguan jaringan/server Supabase', () async {
      // Arrange
      authService.stubLoginError = Exception('Gagal terhubung ke Supabase. Periksa koneksi internet Anda.');

      // Act & Assert
      expect(
        () async => await authService.login('admin', 'admin123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'error message',
          contains('Gagal terhubung ke Supabase'),
        )),
      );

      // Mock Behavioral Assertion
      expect(authService.loginCallCount, equals(1));
    });
  });

  group('Stub & Mock - Registration Workflow', () {
    test('Positif: Registrasi berhasil dan Mock memverifikasi payload parameter yang dikirim', () async {
      // Arrange
      const inputNama = 'Budi Santoso';
      const inputUsername = 'budi_santoso';
      const inputEmail = 'budi@gmail.com';
      const inputBidang = 'Persandian dan Keamanan Informasi';
      const inputPassword = 'Password2026';

      // Act
      final result = await authService.register(
        nama: inputNama,
        username: inputUsername,
        email: inputEmail,
        bidang: inputBidang,
        password: inputPassword,
      );

      // Assert
      // 1. Verifikasi Response (Stub)
      expect(result.username, equals(inputUsername));
      expect(result.nama, equals(inputNama));
      expect(result.bidang, equals(inputBidang));
      expect(result.email, equals(inputEmail));

      // 2. Verifikasi Parameter Mock
      expect(authService.registerCallCount, equals(1));
      expect(authService.lastRegisterParams?['nama'], equals(inputNama));
      expect(authService.lastRegisterParams?['username'], equals(inputUsername));
      expect(authService.lastRegisterParams?['email'], equals(inputEmail));
      expect(authService.lastRegisterParams?['bidang'], equals(inputBidang));
      expect(authService.lastRegisterParams?['password'], equals(inputPassword));
    });

    test('Negatif: Registrasi gagal jika username sudah terpakai', () async {
      // Arrange
      authService.stubRegisterError = Exception('Username sudah digunakan oleh pengguna lain');

      // Act & Assert
      expect(
        () async => await authService.register(
          nama: 'User Duplikat',
          username: 'aptika',
          email: 'aptika2@gmail.com',
          bidang: 'Aplikasi Informatika',
          password: 'Password123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'error message',
          contains('Username sudah digunakan'),
        )),
      );

      expect(authService.registerCallCount, equals(1));
    });
  });

  group('Stub & Mock - Username Availability & Session Check', () {
    test('Positif: Mengembalikan true jika username masih tersedia', () async {
      // Arrange
      authService.isUsernameAvailableResult = true;

      // Act
      final isAvailable = await authService.isUsernameAvailable('username_baru');

      // Assert
      expect(isAvailable, isTrue);
      expect(authService.isUsernameAvailableCallCount, equals(1));
      expect(authService.lastCheckedUsername, equals('username_baru'));
    });

    test('Negatif: Mengembalikan false jika username sudah terdaftar', () async {
      // Arrange
      authService.isUsernameAvailableResult = false;

      // Act
      final isAvailable = await authService.isUsernameAvailable('admin');

      // Assert
      expect(isAvailable, isFalse);
      expect(authService.isUsernameAvailableCallCount, equals(1));
      expect(authService.lastCheckedUsername, equals('admin'));
    });

    test('Session Check: Mengembalikan UserModel jika sesi aktif dan null jika tidak aktif', () async {
      // Skenario 1: Sesi tidak aktif (null)
      // Arrange
      authService.stubUser = null;

      // Act
      final userNull = await authService.checkSession();

      // Assert
      expect(userNull, isNull);
      expect(authService.checkSessionCallCount, equals(1));

      // Skenario 2: Sesi aktif
      // Arrange
      final activeUser = UserModel(
        id: 'user-active',
        username: 'active_user',
        nama: 'Active User',
        role: 'operator',
      );
      authService.stubUser = activeUser;

      // Act
      final userActive = await authService.checkSession();

      // Assert
      expect(userActive, isNotNull);
      expect(userActive?.username, equals('active_user'));
      expect(authService.checkSessionCallCount, equals(2));
    });
  });
}
