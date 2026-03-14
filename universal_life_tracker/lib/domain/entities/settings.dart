class AppSettings {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool hapticEnabled;
  final bool soundEnabled;
  final bool onboardingComplete;
  final String? userId;

  const AppSettings({
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.hapticEnabled = true,
    this.soundEnabled = true,
    this.onboardingComplete = false,
    this.userId,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? hapticEnabled,
    bool? soundEnabled,
    bool? onboardingComplete,
    String? userId,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      userId: userId ?? this.userId,
    );
  }
}
