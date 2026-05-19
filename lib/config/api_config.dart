class ApiConfig {
  static const String baseUrl = 'https://cloud-gallery-smcb.onrender.com';
  static const String apiBase = '$baseUrl/api';
  static const String externalApi = '$apiBase/external';
  static const String clipsApi = '$apiBase/clips';
  static const String profilesApi = '$apiBase/profiles';
  static const String searchApi = '$apiBase/search';
  static const String authApi = '$apiBase/auth';

  static const int maxVideoDuration = 60;
  static const int maxFileSizeMB = 100;
}
