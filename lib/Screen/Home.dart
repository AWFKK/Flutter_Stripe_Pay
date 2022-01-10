import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static TextEditingController inputController = new TextEditingController();

  //Payment Intent
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          const Text("Input amount you want to pay.",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),


          const SizedBox(height: 50,),

          //Input Field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              controller: inputController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.green)),
                hintText: '57.0',
                labelText: 'Amount',
                prefixIcon: const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          const SizedBox(height: 50,),

          //Payment Button
          InkWell(
            onTap: () async {
              await makePayment(inputController.text, "USD");
            },
            child: Container(
              height: 45,
              width: 150,
              decoration: const BoxDecoration(
                  color: Colors.green, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ]
              ),
              child: const Center(
                child: Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> makePayment(String amount, String currencyCode)async{
    try {
      paymentIntentData = await createPaymentIntent(amount, currencyCode); //json.decode(response.body);
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  //How you can add Apple And Google Pay
                  applePay: true,
                  googlePay: true,
                  testEnv: true,
                  style: ThemeMode.dark,
                  merchantCountryCode: 'US',
                  merchantDisplayName: 'Faiz'))
          .then((value) {
        displayPaymentSheet();
      });
    } catch (e) {
      print("Exception OnClick " + e.toString());
    }
  }

  displayPaymentSheet() async {

    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
            clientSecret: paymentIntentData!['client_secret'],
            confirmPayment: true,
          )).then((newValue){

        print('payment intent'+paymentIntentData!['id'].toString());
        print('payment intent'+paymentIntentData!['client_secret'].toString());
        print('payment intent'+paymentIntentData!['amount'].toString());
        print('payment intent'+paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());

        setState(() {
          paymentIntentData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("paid successfully")));



      }).onError((error, stackTrace){
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });


    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try{
      Map<String, dynamic>body = {
        'amount': calculateMount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer sk_test_51KFd7HHjhOs2YctLJjPWRMLLEPI9bFcAWnhy8WGBfNnpJhY2jNMKQS62xznqdHeeGWACqBgUceKIAIwlSJGQgoOv00ELTk8nFR',
            'Content-Type': 'application/x-www-form-urlencoded'
          }
      );
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);

    }catch(e){
      print("Exception"+e.toString());
    }
  }


  calculateMount(String amount){
    final price = int.parse(amount)*100;
    return price.toString();
  }

}


