import 'package:flutter_test/flutter_test.dart';
import 'package:siagenda_app/utils/validators.dart';

/// ============================================================================
/// PENGUJIAN WHITE-BOX: STATEMENT & BRANCH COVERAGE
/// Target: AuthValidator & AgendaValidator (Pure Business Logic)
/// Format: Pola AAA (Arrange, Act, Assert)
/// ============================================================================
void main() {
  group('AuthValidator - Nama Lengkap Tests (Statement & Branch Coverage)', () {
    test('Negatif: Mengembalikan error jika nama bernilai null (Branch 1)', () {
      // Arrange
      const String? inputNama = null;

      // Act
      final result = AuthValidator.validateNama(inputNama);

      // Assert
      expect(result, equals('Nama lengkap wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika nama hanya berupa spasi kosong (Branch 1)', () {
      // Arrange
      const inputNama = '   ';

      // Act
      final result = AuthValidator.validateNama(inputNama);

      // Assert
      expect(result, equals('Nama lengkap wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika panjang nama kurang dari 3 karakter (Branch 2)', () {
      // Arrange
      const inputNama = 'Ab';

      // Act
      final result = AuthValidator.validateNama(inputNama);

      // Assert
      expect(result, equals('Nama minimal 3 karakter'));
    });

    test('Positif: Mengembalikan null jika nama valid (3 karakter atau lebih) (Branch 3)', () {
      // Arrange
      const inputNama = 'Ahmad Faisal';

      // Act
      final result = AuthValidator.validateNama(inputNama);

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthValidator - Username Tests (Statement & Branch Coverage)', () {
    test('Negatif: Mengembalikan error jika username kosong / null (Branch 1)', () {
      // Arrange
      const String? inputUsername = null;

      // Act
      final result = AuthValidator.validateUsername(inputUsername);

      // Assert
      expect(result, equals('Username wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika panjang username < 3 karakter (Branch 2)', () {
      // Arrange
      const inputUsername = 'op';

      // Act
      final result = AuthValidator.validateUsername(inputUsername);

      // Assert
      expect(result, equals('Username min 3 karakter'));
    });

    test('Negatif: Mengembalikan error jika username mengandung simbol @ (Branch 3)', () {
      // Arrange
      const inputUsername = 'admin@kominfo';

      // Act
      final result = AuthValidator.validateUsername(inputUsername);

      // Assert
      expect(result, equals('Username tidak boleh mengandung simbol "@"'));
    });

    test('Negatif: Mengembalikan error jika username mengandung spasi (Branch 4)', () {
      // Arrange
      const inputUsername = 'operator aptika';

      // Act
      final result = AuthValidator.validateUsername(inputUsername);

      // Assert
      expect(result, equals('Username tidak boleh menggunakan spasi'));
    });

    test('Negatif: Mengembalikan error jika username memuat karakter khusus ilegal (Branch 5)', () {
      // Arrange
      const inputUsername = 'user#diskominfo!';

      // Act
      final result = AuthValidator.validateUsername(inputUsername);

      // Assert
      expect(result, equals('Username hanya boleh huruf, angka, dan underscore'));
    });

    test('Positif: Mengembalikan null jika format username valid alfanumerik / underscore (Branch 6)', () {
      // Arrange
      const inputUsername = 'operator_aptika.01';

      // Act
      final result = AuthValidator.validateUsername(inputUsername);

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthValidator - Email Tests (Statement & Branch Coverage)', () {
    test('Negatif: Mengembalikan error jika email null / kosong (Branch 1)', () {
      // Arrange
      const String? inputEmail = ' ';

      // Act
      final result = AuthValidator.validateEmail(inputEmail);

      // Assert
      expect(result, equals('Email wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika format email tidak valid (Branch 2)', () {
      // Arrange
      const inputEmail = 'bukan-format-email';

      // Act
      final result = AuthValidator.validateEmail(inputEmail);

      // Assert
      expect(result, equals('Format email tidak valid'));
    });

    test('Negatif: Mengembalikan error jika menggunakan domain dummy internal @siagenda.local (Branch 3)', () {
      // Arrange
      const inputEmail = 'user@siagenda.local';

      // Act
      final result = AuthValidator.validateEmail(inputEmail);

      // Assert
      expect(result, equals('Gunakan alamat email asli Anda'));
    });

    test('Positif: Mengembalikan null jika email valid (Branch 4)', () {
      // Arrange
      const inputEmail = 'ahmad.faisal@malangkab.go.id';

      // Act
      final result = AuthValidator.validateEmail(inputEmail);

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthValidator - Password Tests (Statement & Branch Coverage)', () {
    test('Negatif: Mengembalikan error jika password null / kosong (Branch 1)', () {
      // Arrange
      const String? inputPass = null;

      // Act
      final result = AuthValidator.validatePassword(inputPass);

      // Assert
      expect(result, equals('Password wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika password kurang dari 8 karakter (Branch 2)', () {
      // Arrange
      const inputPass = 'Pass1';

      // Act
      final result = AuthValidator.validatePassword(inputPass);

      // Assert
      expect(result, equals('Password min 8 karakter'));
    });

    test('Negatif: Mengembalikan error jika password hanya huruf tanpa angka (Branch 3)', () {
      // Arrange
      const inputPass = 'passwordtanpaangka';

      // Act
      final result = AuthValidator.validatePassword(inputPass);

      // Assert
      expect(result, equals('Password harus mengandung huruf dan angka'));
    });

    test('Negatif: Mengembalikan error jika password hanya angka tanpa huruf (Branch 3)', () {
      // Arrange
      const inputPass = '1234567890';

      // Act
      final result = AuthValidator.validatePassword(inputPass);

      // Assert
      expect(result, equals('Password harus mengandung huruf dan angka'));
    });

    test('Positif: Mengembalikan null jika password memenuhi kombinasi huruf dan angka >= 8 char (Branch 4)', () {
      // Arrange
      const inputPass = 'MonaPass2026';

      // Act
      final result = AuthValidator.validatePassword(inputPass);

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthValidator - Konfirmasi Password Tests', () {
    test('Negatif: Mengembalikan error jika konfirmasi password kosong', () {
      // Arrange
      const String? inputConfirm = '';
      const passwordAsli = 'Password123';

      // Act
      final result = AuthValidator.validateConfirmPassword(inputConfirm, passwordAsli);

      // Assert
      expect(result, equals('Konfirmasi password wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika konfirmasi password tidak cocok', () {
      // Arrange
      const inputConfirm = 'BedaPassword123';
      const passwordAsli = 'Password123';

      // Act
      final result = AuthValidator.validateConfirmPassword(inputConfirm, passwordAsli);

      // Assert
      expect(result, equals('Password tidak cocok'));
    });

    test('Positif: Mengembalikan null jika konfirmasi password identik dengan password asli', () {
      // Arrange
      const inputConfirm = 'Password123';
      const passwordAsli = 'Password123';

      // Act
      final result = AuthValidator.validateConfirmPassword(inputConfirm, passwordAsli);

      // Assert
      expect(result, isNull);
    });
  });

  group('AgendaValidator - Form Agenda Tests (Statement & Branch Coverage)', () {
    test('Negatif: Mengembalikan error jika kategori belum dipilih', () {
      // Arrange
      const String? kategori = null;

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: kategori,
        kodeKlasifikasi: '000.1.2',
        perihal: 'Undangan Rapat Dinas',
        tujuanSurat: 'Bupati Malang',
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Kategori surat wajib dipilih'));
    });

    test('Negatif: Mengembalikan error jika kode klasifikasi kosong', () {
      // Arrange
      const kode = '';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: kode,
        perihal: 'Undangan Rapat Dinas',
        tujuanSurat: 'Bupati Malang',
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Kode klasifikasi wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika kode klasifikasi memuat karakter berbahaya', () {
      // Arrange
      const kodeTerlarang = '000.1<script>';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: kodeTerlarang,
        perihal: 'Undangan Rapat Dinas',
        tujuanSurat: 'Bupati Malang',
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Kode memuat karakter terlarang'));
    });

    test('Negatif: Mengembalikan error jika perihal kosong', () {
      // Arrange
      const perihal = '   ';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: '000.1.2',
        perihal: perihal,
        tujuanSurat: 'Bupati Malang',
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Perihal surat wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika panjang perihal kurang dari 5 karakter', () {
      // Arrange
      const perihal = 'Rpt';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: '000.1.2',
        perihal: perihal,
        tujuanSurat: 'Bupati Malang',
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Perihal minimal 5 karakter'));
    });

    test('Negatif: Mengembalikan error jika panjang perihal lebih dari 100 karakter', () {
      // Arrange
      final perihalPanjang = 'A' * 101;

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: '000.1.2',
        perihal: perihalPanjang,
        tujuanSurat: 'Bupati Malang',
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Perihal maksimal 100 karakter'));
    });

    test('Negatif: Mengembalikan error jika tujuan surat kosong', () {
      // Arrange
      const tujuan = '';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: '000.1.2',
        perihal: 'Koordinasi Server Pusdatin',
        tujuanSurat: tujuan,
        pemohon: 'Bidang Aptika',
      );

      // Assert
      expect(result, equals('Tujuan surat wajib diisi'));
    });

    test('Negatif: Mengembalikan error jika pemohon nomor kosong', () {
      // Arrange
      const pemohon = '';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: 'surat_keluar',
        kodeKlasifikasi: '000.1.2',
        perihal: 'Koordinasi Server Pusdatin',
        tujuanSurat: 'Kepala Dinas Kominfo',
        pemohon: pemohon,
      );

      // Assert
      expect(result, equals('Pemohon nomor wajib diisi'));
    });

    test('Positif: Mengembalikan null jika seluruh isian form agenda valid', () {
      // Arrange
      const kategori = 'surat_keluar';
      const kode = '000.1.2';
      const perihal = 'Permohonan Akses Server Simona';
      const tujuan = 'Kepala Dinas Kominfo';
      const pemohon = 'Bidang Aplikasi Informatika';

      // Act
      final result = AgendaValidator.validateAgendaForm(
        kategori: kategori,
        kodeKlasifikasi: kode,
        perihal: perihal,
        tujuanSurat: tujuan,
        pemohon: pemohon,
      );

      // Assert
      expect(result, isNull);
    });

    test('isFormFilled mengembalikan true jika semua field terisi dan false jika ada yang kosong', () {
      // Arrange & Act & Assert
      expect(
        AgendaValidator.isFormFilled(
          kategori: 'surat_keluar',
          kodeKlasifikasi: '100',
          perihal: 'Surat Keputusan',
          tujuanSurat: 'Bupati',
          pemohon: 'Sekretariat',
        ),
        isTrue,
      );

      expect(
        AgendaValidator.isFormFilled(
          kategori: '',
          kodeKlasifikasi: '100',
          perihal: 'Surat Keputusan',
          tujuanSurat: 'Bupati',
          pemohon: 'Sekretariat',
        ),
        isFalse,
      );
    });
  });
}
