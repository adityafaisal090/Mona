import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agenda_number_model.dart';
import '../repositories/agenda_repository.dart';

class AgendaService implements IAgendaRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<AgendaNumberModel> issueTodayNumber({
    required String kategori,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  }) async {
    try {
      final response = await _supabase.rpc('issue_today_number', params: {
        'p_kategori': kategori,
        'p_kode_klasifikasi': kodeKlasifikasi,
        'p_tujuan_surat': tujuanSurat,
        'p_perihal': perihal,
        'p_pemohon': pemohon,
      });

      final data = response as Map<String, dynamic>;
      return AgendaNumberModel.fromJson(data);
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<AgendaNumberModel> issueBackdateNumber({
    required DateTime tanggal,
    required String kategori,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  }) async {
    try {
      final dateStr =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

      final response = await _supabase.rpc('issue_backdate_number', params: {
        'p_tanggal': dateStr,
        'p_kategori': kategori,
        'p_kode_klasifikasi': kodeKlasifikasi,
        'p_tujuan_surat': tujuanSurat,
        'p_perihal': perihal,
        'p_pemohon': pemohon,
      });

      final data = response as Map<String, dynamic>;
      return AgendaNumberModel.fromJson(data);
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<void> generateDailyBuffer(DateTime tanggal) async {
    try {
      final dateStr =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

      await _supabase.rpc('generate_daily_buffer', params: {
        'p_tanggal': dateStr,
      });
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>>> getBufferSettings() async {
    try {
      final response = await _supabase.from('buffer_settings').select().order('kategori');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<void> updateBufferSetting(String kategori, int jumlahBuffer) async {
    try {
      await _supabase.rpc('update_buffer_setting', params: {
        'p_kategori': kategori,
        'p_jumlah': jumlahBuffer,
      });
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<Map<String, int>> getBufferStatusForPeriod(String kategori, DateTime date) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      var query = _supabase
          .from('agenda_buffers')
          .select('status, nomor, periode')
          .eq('kategori', kategori);

      if (kategori == 'surat_keluar') {
        query = query.eq('periode', dateStr);
      } else {

        final startOfMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}-01';
        final nextMonth = date.month == 12 ? DateTime(date.year + 1, 1, 1) : DateTime(date.year, date.month + 1, 1);
        final endOfMonth = '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01';
        query = query.gte('periode', startOfMonth).lt('periode', endOfMonth);
      }

      final response = await query;
      final list = response as List;
      int tersedia = 0;
      int terpakai = 0;
      for (final item in list) {
        if (item['status'] == 'tersedia') tersedia++;
        if (item['status'] == 'terpakai') terpakai++;
      }
      return {
        'tersedia': tersedia,
        'terpakai': terpakai,
        'total': list.length,
      };
    } catch (_) {
      return {'tersedia': 0, 'terpakai': 0, 'total': 0};
    }
  }

  Future<void> generateBufferForPeriod(String kategori, DateTime date) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await _supabase.rpc('generate_buffer_for_period', params: {
        'p_kategori': kategori,
        'p_periode': dateStr,
      });
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<AgendaNumberModel> approveAgenda(int id) async {
    try {
      final response = await _supabase.rpc('approve_agenda', params: {
        'p_id': id,
      });
      final data = response as Map<String, dynamic>;
      return AgendaNumberModel.fromJson(data);
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<AgendaNumberModel> rejectAgenda(int id, {String? catatan}) async {
    try {
      final response = await _supabase.rpc('reject_agenda', params: {
        'p_id': id,
        'p_catatan': catatan,
      });
      final data = response as Map<String, dynamic>;
      return AgendaNumberModel.fromJson(data);
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<AgendaNumberModel> updateAgendaDraft({
    required int id,
    required String kodeKlasifikasi,
    required String tujuanSurat,
    required String perihal,
    required String pemohon,
  }) async {
    try {
      final response = await _supabase.rpc('update_agenda_draft', params: {
        'p_id': id,
        'p_kode_klasifikasi': kodeKlasifikasi,
        'p_tujuan_surat': tujuanSurat,
        'p_perihal': perihal,
        'p_pemohon': pemohon,
      });
      final data = response as Map<String, dynamic>;
      return AgendaNumberModel.fromJson(data);
    } catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Mengambil riwayat surat yang dibatasi per bidang pengguna yang login.
  /// Pembatasan dipaksa di sisi database (PostgreSQL RPC get_riwayat_surat_bidang atau server-side query),
  /// bukan sekadar filtering di memori Flutter.
  Future<List<AgendaNumberModel>> getRiwayatSuratBidang({
    String? userBidang,
    String? userId,
    bool isAdmin = false,
  }) async {
    try {
      // 1. Eksekusi RPC Security Definier di PostgreSQL (memaksa filter di database)
      final response = await _supabase.rpc('get_riwayat_surat_bidang');
      final list = (response as List)
          .map((json) => AgendaNumberModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      // 2. Fallback: jika fungsi RPC belum di-apply di server database,
      // lakukan database-level query langsung dengan klausa filter PostgREST
      try {
        if (isAdmin) {
          final res = await _supabase
              .from('agenda_numbers')
              .select()
              .order('created_at', ascending: false);
          return (res as List)
              .map((json) => AgendaNumberModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        final currentUid = userId ?? _supabase.auth.currentUser?.id;
        var query = _supabase.from('agenda_numbers').select();

        if (userBidang != null && userBidang.trim().isNotEmpty) {
          final norm = userBidang.toLowerCase().trim();
          String keyword = userBidang;
          if (norm.contains('aptika') || norm.contains('aplikasi')) {
            keyword = 'Aptika';
          } else if (norm.contains('sandi') || norm.contains('keamanan')) {
            keyword = 'Sandi';
          } else if (norm.contains('komunikasi')) {
            keyword = 'Komunikasi';
          } else if (norm.contains('statistik') || norm.contains('data')) {
            keyword = 'Statistik';
          } else if (norm.contains('sekretariat')) {
            keyword = 'Sekretariat';
          }

          if (currentUid != null) {
            query = query.or('dibuat_oleh.eq.$currentUid,pemohon.ilike.%$keyword%');
          } else {
            query = query.ilike('pemohon', '%$keyword%');
          }
        } else if (currentUid != null) {
          query = query.eq('dibuat_oleh', currentUid);
        }

        final res = await query.order('created_at', ascending: false);
        return (res as List)
            .map((json) => AgendaNumberModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (dbError) {
        final message = _extractErrorMessage(dbError);
        throw Exception(message);
      }
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is PostgrestException) {

      final msg = error.message;
      if (msg.contains('FORBIDDEN')) {
        return 'Akses ditolak: Hanya Admin yang dapat mengonfigurasi buffer settings.';
      }
      if (msg.contains('BUFFER_HABIS') || msg.contains('Sudah Habis')) {
        return 'Nomor Agenda Untuk Tanggal Tersebut Sudah Habis, silahkan koordinasi lebih lanjut dengan TU';
      }
      if (msg.contains('Template tetap belum dikonfigurasi')) {
        return 'Template tetap belum dikonfigurasi. Hubungi admin.';
      }
      return msg;
    }
    final str = error.toString();
    if (str.contains('FORBIDDEN')) {
      return 'Akses ditolak: Hanya Admin yang dapat mengonfigurasi buffer settings.';
    }
    if (str.contains('BUFFER_HABIS') || str.contains('Sudah Habis')) {
      return 'Nomor Agenda Untuk Tanggal Tersebut Sudah Habis, silahkan koordinasi lebih lanjut dengan TU';
    }
    return str.replaceAll('Exception: ', '');
  }
}
