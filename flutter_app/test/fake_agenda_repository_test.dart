import 'package:flutter_test/flutter_test.dart';
import 'package:siagenda_app/models/agenda_number_model.dart';
import 'test_doubles/fake_agenda_repository.dart';

/// ============================================================================
/// UNIT TESTING DENGAN TEST DOUBLE: FAKE REPOSITORY
/// Target: FakeAgendaRepository (In-Memory Business Logic Simulation)
/// Format: Pola AAA (Arrange, Act, Assert)
/// ============================================================================
void main() {
  late FakeAgendaRepository repository;

  setUp(() {
    repository = FakeAgendaRepository();
  });

  group('FakeAgendaRepository - Issue Today Number Tests (AAA Pattern)', () {
    test('Positif: Menerbitkan nomor agenda hari ini dengan status langsung disetujui', () async {
      // Arrange
      const kategori = 'surat_keluar';
      const kodeKlasifikasi = '000.1.2';
      const tujuan = 'Kepala Dinas Kominfo';
      const perihal = 'Pengantar Laporan Triwulan IV';
      const pemohon = 'Bidang Aptika';

      // Act
      final result = await repository.issueTodayNumber(
        kategori: kategori,
        kodeKlasifikasi: kodeKlasifikasi,
        tujuanSurat: tujuan,
        perihal: perihal,
        pemohon: pemohon,
      );

      // Assert
      expect(result.id, equals(1));
      expect(result.nomorAgenda, equals(101));
      expect(result.nomorLengkap, contains('000.1.2 / 101 / 35.07.315/'));
      expect(result.kategori, equals('surat_keluar'));
      expect(result.isBackdate, isFalse);
      expect(result.statusAcc, equals('disetujui'));
      expect(repository.storage.length, equals(1));
    });

    test('Positif: Sequence nomor agenda bertambah secara berurutan (auto-increment)', () async {
      // Arrange
      const kategori = 'nota_dinas';

      // Act
      final surat1 = await repository.issueTodayNumber(
        kategori: kategori,
        kodeKlasifikasi: '500.1',
        tujuanSurat: 'Sekretariat',
        perihal: 'Permohonan Nota Dinas 1',
        pemohon: 'Bidang Statistik',
      );

      final surat2 = await repository.issueTodayNumber(
        kategori: kategori,
        kodeKlasifikasi: '500.1',
        tujuanSurat: 'Sekretariat',
        perihal: 'Permohonan Nota Dinas 2',
        pemohon: 'Bidang Statistik',
      );

      // Assert
      expect(surat1.nomorAgenda, equals(101));
      expect(surat2.nomorAgenda, equals(102));
      expect(repository.storage.length, equals(2));
    });
  });

  group('FakeAgendaRepository - Issue Backdate Number Tests (AAA Pattern)', () {
    test('Positif: Menerbitkan nomor agenda backdate dengan status "menunggu"', () async {
      // Arrange
      final tanggalLampau = DateTime.now().subtract(const Duration(days: 3));
      const kategori = 'surat_keputusan';
      const kodeKlasifikasi = '100';
      const tujuan = 'Bupati Malang';
      const perihal = 'SK Pembentukan Tim Monitoring';
      const pemohon = 'Sekretariat';

      // Act
      final result = await repository.issueBackdateNumber(
        tanggal: tanggalLampau,
        kategori: kategori,
        kodeKlasifikasi: kodeKlasifikasi,
        tujuanSurat: tujuan,
        perihal: perihal,
        pemohon: pemohon,
      );

      // Assert
      expect(result.nomorAgenda, equals(101));
      expect(result.isBackdate, isTrue);
      expect(result.statusAcc, equals('menunggu'));
      expect(result.catatanAdmin, equals('Menunggu ACC Admin'));
      expect(result.tanggalAgenda, contains(tanggalLampau.year.toString()));
    });

    test('Negatif: Melempar Exception jika tanggal backdate melampaui hari ini (future date)', () async {
      // Arrange
      final tanggalBesok = DateTime.now().add(const Duration(days: 2));

      // Act & Assert
      expect(
        () async => await repository.issueBackdateNumber(
          tanggal: tanggalBesok,
          kategori: 'surat_keluar',
          kodeKlasifikasi: '000.1.2',
          tujuanSurat: 'Dinas Pendidikan',
          perihal: 'Surat Masa Depan',
          pemohon: 'Bidang Aptika',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'pesan error',
          contains('Tanggal backdate tidak boleh lebih dari hari ini'),
        )),
      );
      expect(repository.storage.isEmpty, isTrue);
    });
  });

  group('FakeAgendaRepository - Admin Approval & Rejection Workflow', () {
    test('Positif: Admin dapat menyetujui (approve) agenda berstatus menunggu', () async {
      // Arrange
      final backdateItem = await repository.issueBackdateNumber(
        tanggal: DateTime.now().subtract(const Duration(days: 1)),
        kategori: 'surat_keluar',
        kodeKlasifikasi: '000.1.2',
        tujuanSurat: 'Inspektorat',
        perihal: 'Laporan Audit Kinerja',
        pemohon: 'Bidang Persandian',
      );
      expect(backdateItem.statusAcc, equals('menunggu'));

      // Act
      final approvedItem = await repository.approveAgenda(backdateItem.id);

      // Assert
      expect(approvedItem.id, equals(backdateItem.id));
      expect(approvedItem.statusAcc, equals('disetujui'));
      expect(approvedItem.catatanAdmin, equals('Disetujui oleh Admin'));
    });

    test('Positif: Admin dapat menolak (reject) agenda disertai catatan penolakan', () async {
      // Arrange
      final item = await repository.issueBackdateNumber(
        tanggal: DateTime.now().subtract(const Duration(days: 2)),
        kategori: 'nota_dinas',
        kodeKlasifikasi: '500.1',
        tujuanSurat: 'Kadis Kominfo',
        perihal: 'Permohonan Pengadaan Router',
        pemohon: 'Bidang Aptika',
      );

      // Act
      final rejectedItem = await repository.rejectAgenda(
        item.id,
        catatan: 'Lampiran spesifikasi teknis belum lengkap',
      );

      // Assert
      expect(rejectedItem.id, equals(item.id));
      expect(rejectedItem.statusAcc, equals('ditolak'));
      expect(rejectedItem.catatanAdmin, equals('Lampiran spesifikasi teknis belum lengkap'));
    });

    test('Negatif: Melempar Exception jika ID agenda yang di-approve/reject tidak ditemukan', () async {
      // Arrange
      const invalidId = 999;

      // Act & Assert
      expect(
        () async => await repository.approveAgenda(invalidId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'pesan',
          contains('tidak ditemukan'),
        )),
      );

      expect(
        () async => await repository.rejectAgenda(invalidId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'pesan',
          contains('tidak ditemukan'),
        )),
      );
    });
  });

  group('FakeAgendaRepository - Filtering Riwayat Surat Bidang', () {
    test('Positif: Mengembalikan surat yang sesuai dengan bidang pengguna', () async {
      // Arrange
      repository.seed([
        AgendaNumberModel(
          id: 1,
          tahun: 2026,
          nomorAgenda: 10,
          nomorLengkap: '000.1.2/10/35.07.315/2026',
          kategori: 'surat_keluar',
          kodeKlasifikasi: '000.1.2',
          tujuanSurat: 'Bupati',
          perihal: 'Aplikasi SIMONA',
          pemohon: 'Aptika',
          bidang: 'Aplikasi Informatika',
          tanggalAgenda: '2026-03-01',
          isBackdate: false,
          dibuatOleh: 'aptika',
          statusAcc: 'disetujui',
          createdAt: '2026-03-01T08:00:00Z',
        ),
        AgendaNumberModel(
          id: 2,
          tahun: 2026,
          nomorAgenda: 11,
          nomorLengkap: '500.1/11/35.07.315/2026',
          kategori: 'nota_dinas',
          kodeKlasifikasi: '500.1',
          tujuanSurat: 'Sekda',
          perihal: 'Publikasi Statistik Daerah',
          pemohon: 'Statistik',
          bidang: 'Data dan Statistik',
          tanggalAgenda: '2026-03-02',
          isBackdate: false,
          dibuatOleh: 'statistik',
          statusAcc: 'disetujui',
          createdAt: '2026-03-02T08:00:00Z',
        ),
      ]);

      // Act
      final riwayatAptika = await repository.getRiwayatSuratBidang(userBidang: 'Aplikasi Informatika');
      final riwayatStatistik = await repository.getRiwayatSuratBidang(userBidang: 'Statistik');

      // Assert
      expect(riwayatAptika.length, equals(1));
      expect(riwayatAptika.first.perihal, equals('Aplikasi SIMONA'));

      expect(riwayatStatistik.length, equals(1));
      expect(riwayatStatistik.first.perihal, equals('Publikasi Statistik Daerah'));
    });

    test('Positif: Admin dapat melihat seluruh surat tanpa terfilter bidang', () async {
      // Arrange
      repository.seed([
        AgendaNumberModel(
          id: 1,
          tahun: 2026,
          nomorAgenda: 1,
          nomorLengkap: '000.1/1/2026',
          kategori: 'surat_keluar',
          kodeKlasifikasi: '000.1',
          tujuanSurat: 'Bupati',
          perihal: 'Surat 1',
          pemohon: 'Aptika',
          tanggalAgenda: '2026-03-01',
          isBackdate: false,
          dibuatOleh: 'aptika',
          statusAcc: 'disetujui',
          createdAt: '2026-03-01T08:00:00Z',
        ),
        AgendaNumberModel(
          id: 2,
          tahun: 2026,
          nomorAgenda: 2,
          nomorLengkap: '000.2/2/2026',
          kategori: 'surat_keluar',
          kodeKlasifikasi: '000.2',
          tujuanSurat: 'Bupati',
          perihal: 'Surat 2',
          pemohon: 'Sekretariat',
          tanggalAgenda: '2026-03-02',
          isBackdate: false,
          dibuatOleh: 'sekretariat',
          statusAcc: 'disetujui',
          createdAt: '2026-03-02T08:00:00Z',
        ),
      ]);

      // Act
      final allLetters = await repository.getRiwayatSuratBidang(isAdmin: true);

      // Assert
      expect(allLetters.length, equals(2));
    });
  });
}
