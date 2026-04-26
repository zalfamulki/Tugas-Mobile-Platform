class AppConstants {
  // Gunakan IP Address laptop  jika running di Real Device
  // Gunakan 10.0.2.2 untuk Android Emulator
  static const String baseUrl = "http://192.168.0.101:8000/api";

  // Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String logout = "$baseUrl/auth/logout";
  static const String profile = "$baseUrl/auth/user-profile";
  static const String matkul = "$baseUrl/matkuls";
  static const String mahasiswa = "$baseUrl/mahasiswas";
  static const String grade = "$baseUrl/grades";
  static const String krs = "$baseUrl/krs/my-krs";
  static const String schedule = "$baseUrl/krs/schedule";
}
