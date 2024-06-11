import 'package:ay_invoiving_app/addPurchase.dart';
import 'package:ay_invoiving_app/createItem.dart';
import 'package:ay_invoiving_app/createParty.dart';
import 'package:ay_invoiving_app/ledger.dart';
import 'package:ay_invoiving_app/partyList.dart';
import 'package:ay_invoiving_app/paymentOut.dart';
import 'package:ay_invoiving_app/provider/company_data.dart';
import 'package:ay_invoiving_app/provider/log_header.dart';
import 'package:ay_invoiving_app/provider/user_provider.dart';
import 'package:ay_invoiving_app/purchaseReport.dart';
import 'package:ay_invoiving_app/sales.dart';
import 'package:ay_invoiving_app/paymentIn.dart';
import 'package:ay_invoiving_app/salesReport.dart';
import 'package:ay_invoiving_app/screens/Home.dart';
import 'package:ay_invoiving_app/screens/attendance.dart';
import 'package:ay_invoiving_app/screens/expense.dart';
import 'package:ay_invoiving_app/screens/loading_screen.dart';
import 'package:ay_invoiving_app/screens/quotation.dart';
import 'package:ay_invoiving_app/screens/top_navigator.dart';
import 'package:ay_invoiving_app/screens/update_sales.dart';
import 'package:ay_invoiving_app/screens/working_on_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ay_invoiving_app/stock.dart';
import 'package:ay_invoiving_app/logs.dart';

import 'login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ...

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> initialiseFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  // _navigate(context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const Sales()));
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LogProvider(check: false),
        ),
        ChangeNotifierProvider(
            create: (context) => CompanyDataProvider(data: []))
      ],
      child: MaterialApp(
        theme: ThemeData(
            // cardColor: Colors.white,
            // cardTheme: const CardTheme(color: Colors.white,surfaceTintColor: Colors.black),
            // // appBarTheme: AppBarTheme(backgroundColor: Colors.amberAccent),
            // iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.black))),
            // iconTheme: const IconThemeData(color: Colors.black),
            //   colorScheme: ColorScheme(
            //       brightness: Brightness.dark,
            //       primary: Colors.amber,
            //       onPrimary: Colors.white,
            //       secondary: Colors.amber.shade200,
            //       onSecondary: Colors.white,
            //       onBackground: Colors.black54,
            //       background: Colors.grey.shade200,
            //       error: const Color.fromARGB(255, 247, 109, 99),
            //       onError: Colors.red,
            //       surface: Colors.primaries[1],
            //       onSurface: Colors.black),
            // useMaterial3: true,
            textTheme: const TextTheme(
              labelLarge: TextStyle(color: Colors.white),
            ),
            fontFamily: GoogleFonts.halant().fontFamily,
            primarySwatch: Colors.amber,
            primaryTextTheme: const TextTheme(
                titleLarge:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        initialRoute: '/',
        routes: {
          '/sales': ((context) => SalesWidget(
                edit: false,
                view: false,
                data: const {},
              )),
          '/ledger': (context) => const Ledger(),
          '/paymentIn': ((context) => const PaymentInWidget(
                data: {},
                edit: false,
                view: false,
              )),
          '/stock': (context) => const Stock(),
          '/addProduct': (context) => const NewItem(
                data: {},
                edit: false,
              ),
          '/partyList': (context) => const PartyList(),
          '/addParty': (context) => NewParty(
                data: const {},
                edit: false,
              ),
          '/logs': (context) => Logs(),
          '/addPurchase': (context) => Purchase(
                data: const {},
                edit: false,
                view: false,
              ),
          '/paymentOut': (context) => const PaymentOutWidget(
                data: {},
                edit: false,
                view: false,
              ),
          '/salesReport': (context) => SalesReport(),
          '/purchaseReport': (context) => PurchaseReport(),
          '/updateSale': (context) => UpdateSales(),
          '/quotation': (context) => Quotation(),
          '/expense': (context) => Expense(),
          '/attendance': (context) => Attendance(),
          '/working': (context) => WorkingOnIt(),
        },
        home: FutureBuilder(
            future: initialiseFirebase(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Error Occured."),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
                  if (firebaseUser == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  } else {
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(firebaseUser.uid)
                        .get()
                        .then((value) {
                      if (value.data()?['admin']) {
                        FirebaseMessaging.instance.subscribeToTopic('admin');
                      } else {
                        FirebaseMessaging.instance
                            .unsubscribeFromTopic('admin');
                      }
                      context.read<UserProvider>().updateUser(
                          isAdmin: value.data()?['admin'],
                          name: value.data()?['name']);
                    });

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TopNavigator()));
                  }
                }).onDone(() {});
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              }
              return Loading();
            }),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
