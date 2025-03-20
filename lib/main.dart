import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/app.dart';
import 'package:movie_tickets/config/firebase_options.dart';
import 'package:movie_tickets/core/utils/simple_bloc_observer.dart';
import 'package:movie_tickets/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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