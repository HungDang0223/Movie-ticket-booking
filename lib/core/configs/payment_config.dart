class PaymentConfig {
  // Stripe publishable key - replace with your actual key in production
  // test key
  static const String stripePublishableKey = 'pk_test_51R5zqZDirq456dDgTE0pfAzcrQ8OkDyKLoZdEmtvgc9h7k2xeZC4X1qsHfBqPVajkClcbxfgYX1VqtQLSKgntFM000MzzSFMiM';
  static const String stripeSecretKey = 'sk_test_51R5zqZDirq456dDg1Kh6mszMxPIjDJn1z4IE2RWGwgWYvTydtl6mudxOAPQRX8pq0ZA58JbLJh8Elbd9JCMwQpXk00iSsVP9bv';
  
  // live key
  // static const String stripePublishableKey = 'pk_live_51R5zqZDirq456dDgC883oLmaISz8gMbACsII53MpEmuuKHqynGsg619GPXxrHISlTzMR0hAwlT2OEtrS9tWSVxU200wBeZfCAj';
  // static const String stripeSecretKey = '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';
  
  // Backend API URL for payment processing (if applicable)
  static const String paymentApiUrl = 'https://api.stripe.com/v1';

  // ZaloPay API URL
  static const String createOrderUrl = "https://sb-openapi.zalopay.vn/v2/create";
  
  // Payment currencies
  static const String defaultCurrency = 'vnd';
  
  // Merchant info
  static const String merchantName = 'CMAX';
  static const String merchantCountryCode = 'VN';
} 