import 'package:siagenda_app/models/user_model.dart';
import 'package:siagenda_app/services/auth_service.dart';

/// ============================================================================
/// TEST DOUBLE 2: STUB & MOCK AUTH SERVICE
/// ============================================================================
/// 
/// PENJELASAN & ALASAN PEMILIHAN (RATIONALE):
/// ----------------------------------------------------------------------------
/// 1. STUB:
///    Stub adalah Test Double yang menyediakan jawaban terprogram (canned answers)
///    terhadap panggilan yang dilakukan selama pengujian. Stub tidak memiliki logika
///    penyimpanan kompleks, melainkan langsung mengembalikan data tiruan atau
///    melempar Exception yang telah disiapkan sebelumnya.
/// 
///    Alasan memilih Stub:
///    - Memungkinkan pengujian cabang positif (login sukses menghasilkan UserModel)
///      dan cabang negatif / error boundary (kredensial salah, jaringan terputus,
///      username telah terdaftar) secara terkendali tanpa bergantung pada API Supabase.
/// 
/// 2. MOCK:
///    Mock adalah Test Double yang mencatat interaksi pemanggilan (call history,
///    parameter, call count) untuk kemudian diverifikasi (behavior verification).
/// 
///    Alasan memilih Mock:
///    - Memverifikasi apakah layer presentasi/provider memanggil dependensi autentikasi
///      dengan parameter yang tepat (misalnya username yang telah di-lowercase/trim)
///      dan tidak memanggil fungsi secara redundan.
/// ============================================================================
class StubAuthService extends AuthService {
  // --- KONFIGURASI STUB (Canned Responses) ---
  UserModel? stubUser;
  Exception? stubLoginError;
  Exception? stubRegisterError;
  bool isUsernameAvailableResult = true;

  // --- REKAMAN INTERAKSI MOCK (Behavior Tracking) ---
  int loginCallCount = 0;
  String? lastLoginUsername;
  String? lastLoginPassword;

  int registerCallCount = 0;
  Map<String, String>? lastRegisterParams;

  int isUsernameAvailableCallCount = 0;
  String? lastCheckedUsername;

  int checkSessionCallCount = 0;

  /// Reset semua konfigurasi stub dan riwayat mock
  void reset() {
    stubUser = null;
    stubLoginError = null;
    stubRegisterError = null;
    isUsernameAvailableResult = true;

    loginCallCount = 0;
    lastLoginUsername = null;
    lastLoginPassword = null;

    registerCallCount = 0;
    lastRegisterParams = null;

    isUsernameAvailableCallCount = 0;
    lastCheckedUsername = null;

    checkSessionCallCount = 0;
  }

  @override
  Future<UserModel> login(String usernameInput, String password) async {
    loginCallCount++;
    lastLoginUsername = usernameInput;
    lastLoginPassword = password;

    if (stubLoginError != null) {
      throw stubLoginError!;
    }

    if (stubUser != null) {
      return stubUser!;
    }

    // Default mock behavior jika tidak di-override
    return UserModel(
      id: 'mock-user-uuid-1',
      username: usernameInput,
      nama: 'Dummy User',
      role: 'operator',
      bidang: 'Aplikasi Informatika',
      email: '$usernameInput@diskominfo.go.id',
    );
  }

  @override
  Future<UserModel> register({
    required String nama,
    required String username,
    required String email,
    required String bidang,
    required String password,
  }) async {
    registerCallCount++;
    lastRegisterParams = {
      'nama': nama,
      'username': username,
      'email': email,
      'bidang': bidang,
      'password': password,
    };

    if (stubRegisterError != null) {
      throw stubRegisterError!;
    }

    if (stubUser != null) {
      return stubUser!;
    }

    return UserModel(
      id: 'mock-new-user-uuid',
      username: username,
      nama: nama,
      role: 'operator',
      bidang: bidang,
      email: email,
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    isUsernameAvailableCallCount++;
    lastCheckedUsername = username;
    return isUsernameAvailableResult;
  }

  @override
  Future<UserModel?> checkSession() async {
    checkSessionCallCount++;
    return stubUser;
  }
}
