import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_tickets/app.dart';
import 'package:movie_tickets/core/configs/firebase_options.dart';
import 'package:movie_tickets/core/utils/simple_bloc_observer.dart';
import 'package:movie_tickets/injection.dart' as di;
import 'package:movie_tickets/core/configs/payment_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = PaymentConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  // Initializa Supabase
  await Supabase.initialize(
      url: "https://hjpcomvusdrclccarcwt.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhqcGNvbXZ1c2RyY2xjY2FyY3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcwMjA2ODIsImV4cCI6MjA2MjU5NjY4Mn0.lkobdsl4_08wx26MHG3XKFGb7ovF-wJVp-2vc_Kxy24");
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  Bloc.observer = SimpleBlocObserver();
  debugPrint = setDebugPrint;
  // Run the app
  runApp(const MyApp());
}

void setDebugPrint(String? message, {int? wrapWidth}) {
  final date = DateTime.now();
  var msg = '${date.year}/${date.month}/${date.day}';
  msg += ' ${date.hour}:${date.minute}:${date.second}';
  msg += ' $message';
  debugPrintSynchronously(
    msg,
    wrapWidth: wrapWidth,
  );
}