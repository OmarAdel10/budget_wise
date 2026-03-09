class AppConstants {
  static const String appVersion = 'v1.0.0';
  static const String linkedInUrl = 'https://www.linkedin.com/in/omaradel10';
  static const String supportEmail = 'omaradel1.dev@gmail.com';

  static final Uri linkedInUri = Uri.parse(linkedInUrl);
  static final Uri emailUri = Uri(scheme: 'mailto', path: supportEmail);

  static final double textFieldAndRelatedWidgetsHeight = 56.0;
}
