# movie_tickets

A new Flutter project.

## Payment Card Icons

For the payment card functionality to work properly, please add the following card icons to the assets/icons directory:

- credit_card.png - Main icon for credit card payment method
- visa.png - Visa card logo
- mastercard.png - Mastercard logo
- amex.png - American Express logo

## Setup

1. Run `flutter pub get` to install dependencies
2. Set up Stripe payment:
   - Create a Stripe account at [stripe.com](https://stripe.com)
   - Get your publishable key from the Stripe dashboard
   - Update the `stripePublishableKey` in `lib/payment/domain/config/payment_config.dart`
   - For production, you'll need to set up a backend server to handle payment intents securely. Update the `paymentApiUrl` in the same file.
3. Run `flutter run` to start the application

## Features

### Payment Integration

This app features a complete payment system with:

- Credit/debit card payment through Stripe
- Saved cards for returning customers
- Support for various payment methods (Visa, Mastercard, MoMo, ZaloPay, etc.)
- Voucher/discount code application
- Detailed payment receipts

The card input uses the `flutter_credit_card` package for a beautiful UI, and card information is saved securely using shared preferences.

For production use, please implement a secure backend service to handle payment intents and avoid exposing your Stripe secret key in the app.
