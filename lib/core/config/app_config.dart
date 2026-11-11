abstract final class AppConfig {
  static const productCollection = 'product';
  static const projectId = 'giuaki-13b9b';
  static const adminUid = String.fromEnvironment(
    'ADMIN_UID',
    defaultValue: 'kmRuft7UYMb3Qihsqzqaa691hkr1',
  );
  static const cloudName = String.fromEnvironment(
    'CLOUD_NAME',
    defaultValue: 'dqv9sna9b',
  );
  static const uploadPreset = String.fromEnvironment(
    'UPLOAD_PRESET',
    defaultValue: 'flutter_unsigned_users',
  );
  static const maxImageBytes = 5 * 1024 * 1024;
}
