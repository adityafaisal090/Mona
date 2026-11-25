
class AuthValidator {

  static String? validateNama(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (val.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  
  static String? validateUsername(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    final clean = val.trim();
    if (clean.length < 3) {
      return 'Username min 3 karakter';
    }
    if (clean.contains('@')) {
      return 'Username tidak boleh mengandung simbol "@"';
    }
    if (clean.contains(' ')) {
      return 'Username tidak boleh menggunakan spasi';
    }
    final validRegex = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!validRegex.hasMatch(clean)) {
      return 'Username hanya boleh huruf, angka, dan underscore';
    }
    return null;
  }


  static String? validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final clean = val.trim().toLowerCase();
    if (clean.endsWith('@siagenda.local')) {
      return 'Gunakan alamat email asli Anda';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(clean)) {
      return 'Format email tidak valid';
    }
    return null;
  }


  static String? validatePassword(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Password wajib diisi';
    }
    if (val.length < 8) {
      return 'Password min 8 karakter';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(val);
    final hasDigit = RegExp(r'[0-9]').hasMatch(val);
    if (!hasLetter || !hasDigit) {
      return 'Password harus mengandung huruf dan angka';
    }
    return null;
  }


  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.trim().isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (val != password) {
      return 'Password tidak cocok';
    }
    return null;
  }
}

/// Utility class validasi logika Form Pembuatan Nomor Agenda
class AgendaValidator {

  static String? validateAgendaForm({
    String? kategori,
    String? kodeKlasifikasi,
    String? perihal,
    String? tujuanSurat,
    String? pemohon,
  }) {
    if (kategori == null || kategori.trim().isEmpty) {
      return 'Kategori surat wajib dipilih';
    }

    final cleanKlasifikasi = kodeKlasifikasi?.trim() ?? '';
    if (cleanKlasifikasi.isEmpty) {
      return 'Kode klasifikasi wajib diisi';
    }

    // Karakter terlarang: [<>{}[\]\\|^`~]
    final forbiddenCharsRegex = RegExp(r'[<>{}[\]\\|^`~]');
    if (forbiddenCharsRegex.hasMatch(cleanKlasifikasi)) {
      return 'Kode memuat karakter terlarang';
    }

    final cleanPerihal = perihal?.trim() ?? '';
    if (cleanPerihal.isEmpty) {
      return 'Perihal surat wajib diisi';
    }
    if (cleanPerihal.length < 5) {
      return 'Perihal minimal 5 karakter';
    }
    if (cleanPerihal.length > 100) {
      return 'Perihal maksimal 100 karakter';
    }

    final cleanTujuan = tujuanSurat?.trim() ?? '';
    if (cleanTujuan.isEmpty) {
      return 'Tujuan surat wajib diisi';
    }

    final cleanPemohon = pemohon?.trim() ?? '';
    if (cleanPemohon.isEmpty) {
      return 'Pemohon nomor wajib diisi';
    }

    return null;
  }

  /// Cek apakah seluruh field sudah terisi (untuk tombol enable/disable)
  static bool isFormFilled({
    String? kategori,
    String? kodeKlasifikasi,
    String? perihal,
    String? tujuanSurat,
    String? pemohon,
  }) {
    return (kategori != null && kategori.trim().isNotEmpty) &&
        (kodeKlasifikasi != null && kodeKlasifikasi.trim().isNotEmpty) &&
        (perihal != null && perihal.trim().isNotEmpty) &&
        (tujuanSurat != null && tujuanSurat.trim().isNotEmpty) &&
        (pemohon != null && pemohon.trim().isNotEmpty);
  }
}
