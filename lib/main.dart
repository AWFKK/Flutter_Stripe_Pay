import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment/Screen/Home.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51KFd7HHjhOs2YctLJgLY8xxj2LJduIQxYPDe04GyTjTLPFP6viTeGUfneSqDWaIHXu5Xlxr17cIfklJATpqB7hOk00NCJjjYro';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strip Pay',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}
