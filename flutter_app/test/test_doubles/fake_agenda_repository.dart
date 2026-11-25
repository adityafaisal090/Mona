import 'package:siagenda_app/models/agenda_number_model.dart';
import 'package:siagenda_app/repositories/agenda_repository.dart';

/// ============================================================================
/// TEST DOUBLE 1: FAKE REPOSITORY (In-Memory Fake)
/// ============================================================================
/// 
/// PENJELASAN & ALASAN PEMILIHAN (RATIONALE):
/// ----------------------------------------------------------------------------
/// Fake adalah jenis Test Double yang memiliki implementasi kerja fungsional yang
/// sebenarnya, namun mengambil jalan pintas (shortcut) yang tidak cocok untuk
/// production — dalam hal ini menyimpan data di memori (in-memory List) alih-alih
/// melakukan query jaringan/RPC ke PostgreSQL Supabase.
/// 
/// Alasan memilih Fake:
/// 1. Menguji logika bisnis penomoran agenda (auto-increment sequence, penentuan
///    status 'disetujui' untuk hari ini vs 'menunggu' untuk backdate, format
///    nomor surat, serta alur persetujuan/penolakan admin) secara realistis.
/// 2. Menghilangkan ketergantungan pada koneksi internet dan database eksternal
///    sehingga unit test berjalan instan (< 100ms), terisolasi, dan deterministik.
/// ============================================================================
class FakeAgendaRepository implements IAgendaRepository {
  final List<AgendaNumberModel> _storage = [];
  int _idCounter = 1;
  int _nomorCounter = 100;

  /// Inisialisasi awal atau reset data untuk keperluan test
  void reset() {
    _storage.clear();
    _idCounter = 1;
    _nomorCounter = 100;
  }

  /// Helper untuk menyisipkan data dummy ke in-memory storage (Arrange phase)
  void seed(List<AgendaNumberModel> items) {
    _storage.addAll(items);
  }

  /// Mengambil semua data yang tersimpan di in-memory storage (Assert phase)
  List<AgendaNumberModel> get storage => List.unmodifiable(_storage);

  @override
  Future<AgendaNumberModel> issueTodayNumber({
    required String kategori,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  }) async {
    _nomorCounter++;
    final currentYear = DateTime.now().year;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    // Nomor agenda hari ini langsung disetujui (status_acc = 'disetujui') dan is_backdate = false
    final newAgenda = AgendaNumberModel(
      id: _idCounter++,
      tahun: currentYear,
      nomorAgenda: _nomorCounter,
      nomorLengkap: '$kodeKlasifikasi / $_nomorCounter / 35.07.315/$currentYear',
      kategori: kategori,
      kodeKlasifikasi: kodeKlasifikasi,
      tujuanSurat: tujuanSurat,
      perihal: perihal,
      pemohon: pemohon,
      tanggalAgenda: nowStr,
      isBackdate: false,
      dibuatOleh: pemohon,
      statusAcc: 'disetujui',
      catatanAdmin: null,
      createdAt: DateTime.now().toIso8601String(),
    );

    _storage.add(newAgenda);
    return newAgenda;
  }

  @override
  Future<AgendaNumberModel> issueBackdateNumber({
    required DateTime tanggal,
    required String kategori,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  }) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final targetDateOnly = DateTime(tanggal.year, tanggal.month, tanggal.day);

    // Validasi aturan bisnis: Tanggal backdate tidak boleh melampaui hari ini
    if (targetDateOnly.isAfter(todayOnly)) {
      throw Exception('Tanggal backdate tidak boleh lebih dari hari ini');
    }

    _nomorCounter++;
    final dateStr =
        '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

    // Backdate memerlukan persetujuan admin (status_acc = 'menunggu') dan is_backdate = true
    final newAgenda = AgendaNumberModel(
      id: _idCounter++,
      tahun: tanggal.year,
      nomorAgenda: _nomorCounter,
      nomorLengkap: '$kodeKlasifikasi / $_nomorCounter / 35.07.315/${tanggal.year}',
      kategori: kategori,
      kodeKlasifikasi: kodeKlasifikasi,
      tujuanSurat: tujuanSurat,
      perihal: perihal,
      pemohon: pemohon,
      tanggalAgenda: dateStr,
      isBackdate: true,
      dibuatOleh: pemohon,
      statusAcc: 'menunggu',
      catatanAdmin: 'Menunggu ACC Admin',
      createdAt: DateTime.now().toIso8601String(),
    );

    _storage.add(newAgenda);
    return newAgenda;
  }

  @override
  Future<AgendaNumberModel> approveAgenda(int id) async {
    final index = _storage.indexWhere((element) => element.id == id);
    if (index == -1) {
      throw Exception('Agenda dengan ID $id tidak ditemukan');
    }

    final current = _storage[index];
    final updated = AgendaNumberModel(
      id: current.id,
      tahun: current.tahun,
      nomorAgenda: current.nomorAgenda,
      nomorLengkap: current.nomorLengkap,
      kategori: current.kategori,
      kodeKlasifikasi: current.kodeKlasifikasi,
      tujuanSurat: current.tujuanSurat,
      perihal: current.perihal,
      pemohon: current.pemohon,
      bidang: current.bidang,
      tanggalAgenda: current.tanggalAgenda,
      isBackdate: current.isBackdate,
      dibuatOleh: current.dibuatOleh,
      statusAcc: 'disetujui',
      catatanAdmin: 'Disetujui oleh Admin',
      createdAt: current.createdAt,
    );

    _storage[index] = updated;
    return updated;
  }

  @override
  Future<AgendaNumberModel> rejectAgenda(int id, {String? catatan}) async {
    final index = _storage.indexWhere((element) => element.id == id);
    if (index == -1) {
      throw Exception('Agenda dengan ID $id tidak ditemukan');
    }

    final current = _storage[index];
    final updated = AgendaNumberModel(
      id: current.id,
      tahun: current.tahun,
      nomorAgenda: current.nomorAgenda,
      nomorLengkap: current.nomorLengkap,
      kategori: current.kategori,
      kodeKlasifikasi: current.kodeKlasifikasi,
      tujuanSurat: current.tujuanSurat,
      perihal: current.perihal,
      pemohon: current.pemohon,
      bidang: current.bidang,
      tanggalAgenda: current.tanggalAgenda,
      isBackdate: current.isBackdate,
      dibuatOleh: current.dibuatOleh,
      statusAcc: 'ditolak',
      catatanAdmin: catatan ?? 'Permohonan ditolak oleh Admin',
      createdAt: current.createdAt,
    );

    _storage[index] = updated;
    return updated;
  }

  @override
  Future<List<AgendaNumberModel>> getRiwayatSuratBidang({
    String? userBidang,
    String? userId,
    bool isAdmin = false,
  }) async {
    if (isAdmin) {
      return List.from(_storage);
    }

    if (userBidang == null || userBidang.trim().isEmpty) {
      return [];
    }

    final norm = userBidang.toLowerCase().trim();
    return _storage.where((item) {
      final bidangMatch = item.bidang?.toLowerCase().contains(norm) ?? false;
      final pemohonMatch = item.pemohon.toLowerCase().contains(norm);
      return bidangMatch || pemohonMatch;
    }).toList();
  }
}
