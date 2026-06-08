class AppConstants {
  static const String appName = 'Cuidar+';
  static const String appVersion = '1.0.0';
  static const String privacyPolicyVersion = '1.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String familiesCollection = 'families';
  static const String elderlyCollection = 'elderly';
  static const String medicationsCollection = 'medications';
  static const String medicationLogsCollection = 'medication_logs';
  static const String alertsCollection = 'alerts';
  static const String appointmentsCollection = 'appointments';
  static const String caregiversCollection = 'caregivers';
  static const String reportsCollection = 'reports';
  static const String qrProfilesCollection = 'qr_profiles';
  static const String inviteKeysCollection = 'invite_keys';

  // Alert default config (minutes)
  static const int alertBefore30Min = 30;
  static const int alertBefore2Min = 2;
  static const int alertRepeatEvery5Min = 5;
  static const int alertMaxRepeat = 6;

  // User roles
  static const String roleElderly = 'elderly';
  static const String roleFamiliar = 'familiar';
  static const String roleCaregiver = 'caregiver';
  static const String roleAdmin = 'admin';

  // Medication frequencies
  static const List<String> frequencies = [
    'Uma vez ao dia',
    'Duas vezes ao dia',
    'Três vezes ao dia',
    'Quatro vezes ao dia',
    'A cada 6 horas',
    'A cada 8 horas',
    'A cada 12 horas',
    'Conforme necessário',
    'Semanal',
    'Mensal',
  ];

  // Blood types
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Não sei'
  ];
}
