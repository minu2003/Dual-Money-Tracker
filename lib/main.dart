import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_app/Authentication/sign_in.dart';
import 'package:money_app/screens/view/home_screen.dart';
import 'package:provider/provider.dart';
import 'Provider/paymentMethod_provider.dart';
import 'Provider/transaction_period_provider.dart';
import 'components/currency_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final currencyProvider = CurrencyProvider();
  await currencyProvider.loadCurrency();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PaymentMethodProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()..loadCurrency()),
        ChangeNotifierProvider(create: (context) => TransactionPeriodProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
      home: login()
    );
  }
}
