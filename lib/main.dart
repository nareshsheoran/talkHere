import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app/data_All/appDetails.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/firebaseMessage.dart';
import 'package:whats_app/provider/home_provider.dart';
import 'package:whats_app/provider/profile_provider.dart';
import 'package:whats_app/provider/phone_provider.dart';
import 'package:whats_app/ui_design/phone_number.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'data_All/SharedPreferences.dart';
import 'ui_design/home.dart';

var uuid = const Uuid();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: AppDetails.appFirebaseApiKey,
      appId: AppDetails.appFirebaseID,
      messagingSenderId: AppDetails.appMsgId,
      storageBucket: AppDetails.appStorageBucket,
      projectId: AppDetails.appProjectId,
    ),
  );
  await FirebaseApps().initNotification();
  FirebaseCrashlytics.instance.recordError;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return PhoneProvider();
      },
      child: ChangeNotifierProvider(
        create: (_) {
          return HomeProvider();
        },
        child: ChangeNotifierProvider(
          create: (_) {
            return ProfileProvider();
          },
          child: ChangeNotifierProvider(
            create: (_) {
              return HomeProvider();
            },
            child: MaterialApp(
              navigatorObservers: [observer],
              debugShowCheckedModeBanner: false,
              title: AppDetails.appName,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: const MyHomePage(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  AppLifecycleState? appLifecycleState;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    await getUserDetails();
    setState(() {
      appLifecycleState = state;
    });
    print("State of app in appLifecycleState:::$appLifecycleState");

    switch (state) {
      case AppLifecycleState.resumed:
        FirebaseFirestore.instance
            .collection("users")
            .doc(UserDetails.userId)
            .update({'userOnline': "Active"});
        print("State of app in resumed:$appLifecycleState");
        break;
      case AppLifecycleState.inactive:
        FirebaseFirestore.instance
            .collection("users")
            .doc(UserDetails.userId)
            .update({'userOnline': "Offline"});
        print("State of app in inactive:$appLifecycleState");
        break;
      case AppLifecycleState.paused:
        FirebaseFirestore.instance
            .collection("users")
            .doc(UserDetails.userId)
            .update({'userOnline': "Away"});
        print("State of app in paused:$appLifecycleState");
        break;
      case AppLifecycleState.detached:
        FirebaseFirestore.instance
            .collection("users")
            .doc(UserDetails.userId)
            .update({'userOnline': "Away"});
        print("State of app in detached:$appLifecycleState");
        break;
      // case AppLifecycleState.hidden:
      //   FirebaseFirestore.instance
      //       .collection("users")
      //       .doc(UserDetails.userId)
      //       .update({'userOnline': "Active"});
      //   print("State of app in detached:$appLifecycleState");
      //   break;

      // TODO: Handle this case.
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getData();
    getUserDetails();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight(MediaQuery.of(context).size.height);
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  Icons.messenger_outlined,
                  size: AppFontSize.font130,
                  color: AppColor.amber,
                ),
                Positioned(
                  left: AppFontSize.font20,
                  bottom: AppFontSize.font80,
                  child: Text(
                    AppDetails.appName,
                    style: TextStyle(
                        fontSize: AppFontSize.font20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  left: AppFontSize.font40,
                  top: AppFontSize.font40,
                  child: Icon(
                    Icons.edit_note_outlined,
                    size: AppFontSize.font50,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppFontSize.font30,
            ),
            SpinKitFadingCircle(
              size: AppFontSize.font50,
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: index.isEven ? Colors.amber : Colors.black,
                      backgroundBlendMode: BlendMode.color),
                );
              },
            ),
          ],
        ),
      )),
    );
  }

  getData() async {
    await LocalDataSaver.getUserLogin().then((value) async {
      if (value == true) {
        Provider.of<ProfileProvider>(context, listen: false).currentUserData();
        await getUserDetails();
        await FirebaseApps().initNotification();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Phone_No()));
        });
      }
    });
  }
}
