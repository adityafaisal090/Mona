import '../models/agenda_number_model.dart';

/// Kontrak abstraksi repositori untuk pengelolaan nomor agenda SIMONA.
/// 
/// Memungkinkan pemisahan dependensi (dependency inversion) sehingga komponen
/// yang membutuhkan layanan nomor agenda dapat menggunakan implementasi nyata
/// (AgendaService yang terhubung ke Supabase) maupun Test Double (Fake / Stub / Mock)
/// tanpa coupling langsung ke jaringan atau infrastruktur eksternal.
abstract class IAgendaRepository {
  Future<AgendaNumberModel> issueTodayNumber({
    required String kategori,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  });

  Future<AgendaNumberModel> issueBackdateNumber({
    required DateTime tanggal,
    required String kategori,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  });

  Future<AgendaNumberModel> approveAgenda(int id);

  Future<AgendaNumberModel> rejectAgenda(int id, {String? catatan});

  Future<List<AgendaNumberModel>> getRiwayatSuratBidang({
    String? userBidang,
    String? userId,
    bool isAdmin = false,
  });
}
