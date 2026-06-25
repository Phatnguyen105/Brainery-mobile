class AppConfig {
  const AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String paymentBankCode = String.fromEnvironment(
    'PAYMENT_BANK_CODE',
    defaultValue: '970436',
  );

  static const String paymentAccountNumber = String.fromEnvironment(
    'PAYMENT_ACCOUNT_NUMBER',
    defaultValue: '0000000000',
  );

  static const String paymentAccountName = String.fromEnvironment(
    'PAYMENT_ACCOUNT_NAME',
    defaultValue: 'BRAINERY DEMO',
  );
}
