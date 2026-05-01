class AppConstants {
  // Gunakan IP Address laptop  jika running di Real Device
  // Gunakan 10.0.2.2 untuk Android Emulator
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String logout = "$baseUrl/auth/logout";
  static const String profile = "$baseUrl/auth/user-profile";
  static const String mahasiswaProfile = "$baseUrl/auth/mahasiswa-profile";
  static const String matkul = "$baseUrl/matkuls";
  static const String mahasiswa = "$baseUrl/mahasiswas";
  
  // KRS
  static const String krs = "$baseUrl/krs";
  static const String allKrs = "$baseUrl/krs/all";
  static const String schedule = "$baseUrl/krs/schedule";

  // Presensi
  static const String presensi = "$baseUrl/presensi";
  static const String allPresensi = "$baseUrl/presensi/all";
  static const String adminPresensi = "$baseUrl/presensi/admin";

  // Bimbingan
  static const String bimbingan = "$baseUrl/bimbingan";
  static const String allBimbingan = "$baseUrl/bimbingan/all";
  static const String bimbinganDosens = "$baseUrl/bimbingan/dosens";
}
