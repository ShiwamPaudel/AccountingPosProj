import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tassist/core/models/inactivecustomer.dart';
import 'package:tassist/core/models/payables.dart';
import 'package:tassist/core/models/receivables.dart';
import 'package:tassist/core/models/stockitem.dart';
import 'package:tassist/core/models/vouchers.dart';
import 'package:tassist/core/services/auth.dart';
import 'package:tassist/core/services/database.dart';
import 'package:tassist/core/services/inactivecustomerservice.dart';
import 'package:tassist/core/services/payablesservice.dart';
import 'package:tassist/core/services/receivablesservice.dart';
import 'package:tassist/core/services/stockservice.dart';
import 'package:tassist/core/services/vouchers.dart';
import 'package:tassist/route_generator.dart';
import 'package:tassist/theme/texts.dart';
import 'core/models/company.dart';
import 'core/models/ledger.dart';
import 'core/services/companyservice.dart';
import 'core/services/ledgerservice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String _title = "TallyAssist";

    return MultiProvider(providers: [
      StreamProvider<FirebaseUser>.value(
        value: AuthService().user,
      ),
    ], child: TopWidget(title: _title));
  }
}

class TopWidget extends StatefulWidget {
  const TopWidget({
    Key key,
    @required String title,
  })  : _title = title,
        super(key: key);

  final String _title;

  @override
  _TopWidgetState createState() => _TopWidgetState();
}

class _TopWidgetState extends State<TopWidget> {

  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _saveDeviceToken();


    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    await _fcm.getToken();

  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);
    return MultiProvider(
      providers: [
        StreamProvider<List<ReceivablesItem>>.value(
          value: ReceivablesItemService(uid: user?.uid).accountsReceivableData,
        ),
        // LEDGER/PARTY DATA
        StreamProvider<List<LedgerItem>>.value(
            value: LedgerItemService(uid: user?.uid).ledgerItemData),
        StreamProvider<List<StockItem>>.value(
            value: StockItemService(uid: user?.uid).stockItemsData),
        StreamProvider<List<PayablesItem>>.value(
            value: PayablesItemService(uid: user?.uid).accountsPayablesData),
        StreamProvider<List<InactiveCustomer>>.value(
            value:
            InactiveCustomerService(uid: user?.uid).inactiveCustomerData),
        StreamProvider<List<Voucher>>.value(
            value: VoucherService(uid: user?.uid).voucherData),
        StreamProvider<Company>.value(
            value: CompanyService(uid: user?.uid).companyData),
      ],
      child: MaterialApp(
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        title: widget._title,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(headline6: primaryAppBarTitle),
          ),
          textTheme: TextTheme(
              headline6: secondaryListTitle,
              subtitle1: secondaryCategoryDesc,
              bodyText1: secondaryListDisc,
              bodyText2: secondaryListTitle2),
        ),
        // Some Basic Changes comments to be pushed in Github to increase the GitHub Streaks.
      ),
    );
  }
}
