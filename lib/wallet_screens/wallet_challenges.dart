import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:momerlin/data/localstorage/userdata_source.dart';
import 'package:momerlin/data/userrepository.dart';
import 'package:momerlin/tabscreen/tabscreen.dart';
import 'package:momerlin/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:device_apps/device_apps.dart';
//import 'package:momerlin/wallet_screens/horizontallist.dart';
import 'package:momerlin/wallet_screens/my_activity.dart';
import 'package:momerlin/wallet_screens/viewmore_join_challenge.dart';
import 'package:momerlin/wallet_screens/viewmore_my_challenges.dart';
// import 'package:momerlin/wallet_screens/my_reports.dart';
import 'package:momerlin/wallet_screens/wallet_challenge_final.dart';
// import 'package:momerlin/wallet_screens/wallet_creating_challenge.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import 'healthkit.dart';

class Challenges {
  var mode;
  var type;
  var totalCompetitors;
  var streakDays;
  var totalKm;
  var wage;
  var id;

  Challenges({
    this.mode,
    this.type,
    this.totalCompetitors,
    this.streakDays,
    this.totalKm,
    this.wage,
    this.id,
  });

  factory Challenges.fromJson(Map<String, dynamic> json) => Challenges(
        mode: json["mode"] == null ? null : json["mode"],
        type: json["type"],
        totalCompetitors: json["totalCompetitors"],
        streakDays: json["streakDays"],
        totalKm: json["totalKm"],
        wage: json["wage"],
        id: json["_id"],
      );
}

class MyChallenges {
  var mode;
  var type;
  var totalCompetitors;
  var streakDays;
  var totalKm;
  var wage;
  var id;
  var startDate;
  var endDate;

  MyChallenges({
    this.mode,
    this.type,
    this.totalCompetitors,
    this.streakDays,
    this.totalKm,
    this.wage,
    this.id,
    this.startDate,
    this.endDate,
  });

  factory MyChallenges.fromJson(Map<String, dynamic> json) => MyChallenges(
      mode: json["mode"] == null ? null : json["mode"],
      type: json["type"],
      totalCompetitors: json["totalCompetitors"],
      streakDays: json["streakDays"],
      totalKm: json["totalKm"],
      wage: json["wage"],
      id: json["_id"],
      startDate: json["startAt"],
      endDate: json["endAt"]);
}

class JoingetChallenges {
  var mode;
  var type;
  var totalCompetitors;
  var streakDays;
  var totalKm;
  var wage;
  var id;
  var startDate;
  var endDate;

  JoingetChallenges({
    this.mode,
    this.type,
    this.totalCompetitors,
    this.streakDays,
    this.totalKm,
    this.wage,
    this.id,
    this.startDate,
    this.endDate,
  });

  factory JoingetChallenges.fromJson(Map<String, dynamic> json) =>
      JoingetChallenges(
          mode: json["mode"] == null ? null : json["mode"],
          type: json["type"],
          totalCompetitors: json["totalCompetitors"],
          streakDays: json["streakDays"],
          totalKm: json["totalKm"],
          wage: json["wage"],
          id: json["_id"],
          startDate: json["startAt"],
          endDate: json["endAt"]);
}

class WalletChallenges extends StatefulWidget {
  const WalletChallenges({Key key}) : super(key: key);

  @override
  _WalletChallengesState createState() => _WalletChallengesState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED
}

class _WalletChallengesState extends State<WalletChallenges> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  DateTime now = DateTime.now();

  var steps = 0.0;
  Future fetchData() async {
    // get everything from midnight until now

    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endDate = DateTime(2025, 11, 07, 23, 59, 59);

    HealthFactory health = HealthFactory();

    // define the types to get
    List<HealthDataType> types = [
      HealthDataType.DISTANCE_DELTA,
    ];
    List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(startDate, endDate, types);
    print("123223434 ${healthData.length}");
    healthData.length != 0
        ? setState(() => googlefitint = true)
        : setState(() => _state = AppState.FETCHING_DATA);

    // you MUST request access to the data types before reading them
    bool accessWasGranted = await health.requestAuthorization(types);

    if (accessWasGranted) {
      try {
        // fetch new data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(startDate, endDate, types);

        // save all the new data points
        _healthDataList.addAll(healthData);
      } catch (e) {
        print("Caught exception in getHealthDataFromTypes: $e");
      }

      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      // print the results

      _healthDataList.forEach((x) {
        // print("Data point: $x");
        steps += x.value / 1000;
      });

      print("Steps: $steps");

      // update the UI to display the results
      setState(() {
        _state =
            _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  List<Challenges> challengesOne = [];
  List<MyChallenges> mychallenge = [];
  List<JoingetChallenges> joingetchallenge = [];
  var userLanguage, user, lang = [];
  bool loading = true;
  bool leaderViewMore = false;
  bool recentWinnerViewMore = false;
  bool viewProfile = false;
  List<int> data = [];
  bool googlefitint = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    getUserLanguage();
    getChallenges();
    getapp();
    return null;
  }

  int value = 0;
  var startdate;
  var exprydate;
  @override
  void initState() {
    super.initState();
    getUserLanguage();
    getChallenges();
    getapp();
    //fetchData();
  }

  // ignore: todo
  //TODO :languagestart
  Future<void> getUserLanguage() async {
    lang = await UserDataSource().getLanguage();
    user = await UserDataSource().getUser();

    if (lang.length != null && lang.length != 0) {
      userLanguage = lang[0];
    }
    getmyChallenges();
    getjoinChallenges();
  }

  // ignore: todo
  //TODO: LanguageEnd

  Future<void> getChallenges() async {
    setState(() {
      loading = false;
    });
    var res = await UserRepository().getChallenges();
    if (res == false) {
      // Scaffold
      //   .of(context)
      //   .showSnackBar(SnackBar(content: Text('No Internet Connection'),backgroundColor: Colors.red,));
    } else {
      if (res["success"] == true) {
        setState(() {
          loading = false;
        });
        challengesOne = [];
        for (var i = 0; i < res["challenges"]["docs"].length; i++) {
          challengesOne.add(Challenges.fromJson(res["challenges"]["docs"][i]));
        }
      } else {
        Scaffold.of(context)
            // ignore: deprecated_member_use
            .showSnackBar(SnackBar(
          content: Text('Please Try Again!'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> getapp() async {
    bool isInstalled =
        await DeviceApps.isAppInstalled('com.google.android.apps.fitness');
    print("1232434345pavi $isInstalled");
  }

  Future<void> getmyChallenges() async {
    setState(() {
      loading = false;
    });
    var res = await UserRepository().getmyChallenges(user[0]["uid"]);
    print("USER ID :" + user[0]["uid"]);

    setState(() {
      loading = false;
    });
    if (res == false) {
      // Scaffold
      //   .of(context)
      //   .showSnackBar(SnackBar(content: Text('No Internet Connection'),backgroundColor: Colors.red,));
    } else {
      if (res["success"] == true) {
        mychallenge = [];
        for (var i = 0; i < res["challenges"]["docs"].length; i++) {
          print("pavimno");
          print(res["challenges"]["docs"][i]);
          mychallenge.add(MyChallenges.fromJson(res["challenges"]["docs"][i]));
        }
      } else {
        Scaffold.of(context)
            // ignore: deprecated_member_use
            .showSnackBar(SnackBar(
          content: Text('Please Try Again!'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> getwinnerChallenges(challangeid) async {
    setState(() {
      loading = false;
    });
    var res = await UserRepository().getwinnerChallenges(challangeid);
    print("USER ID :" + user[0]["uid"]);

    print("PAVIMANO $res");
  }

  Future<void> getjoinChallenges() async {
    setState(() {
      loading = false;
    });
    var res = await UserRepository().joingetchallenge(user[0]["uid"]);
    print("pavimano $res");
    setState(() {
      loading = false;
    });
    if (res == false) {
      // Scaffold
      //   .of(context)
      //   .showSnackBar(SnackBar(content: Text('No Internet Connection'),backgroundColor: Colors.red,));
    } else {
      if (res["success"] == true) {
        joingetchallenge = [];
        for (var i = 0; i < res["challenges"]["docs"].length; i++) {
          joingetchallenge
              .add(JoingetChallenges.fromJson(res["challenges"]["docs"][i]));
        }
      } else {
        Scaffold.of(context)
            // ignore: deprecated_member_use
            .showSnackBar(SnackBar(
          content: Text('Please Try Again!'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> createChallenges() async {
    var todayDate = new DateTime.now();
    var todayDate1 = new DateTime.now();
    var days =
        new DateTime(todayDate1.year, todayDate1.month, todayDate1.day + 7);
    var expiryDate = (DateFormat.yMMMd().format(days)).toString();
    var today1 = (DateFormat.yMMMd().format(todayDate)).toString();

    setState(() {
      loading = false;
    });
    var createchallange = await UserRepository().createchallenge({
      "mode": selecttype,
      "type": challenge,
      "totalCompetitors": wagar,
      "streakDays": 7,
      "totalKm": kmchallenge,
      "createdBy": user[0]["uid"],
      "startAt": today1,
      "endAt": expiryDate,
      "wage": competitorsgets,
    });
    if (createchallange == false) {
      Scaffold.of(context)
          // ignore: deprecated_member_use
          .showSnackBar(SnackBar(
        content: Text('No Internet Connection'),
        backgroundColor: Colors.red,
      ));
    } else {
      if (createchallange["success"] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeFinal(),
          ),
        );
      } else {
        Scaffold.of(context)
            // ignore: deprecated_member_use
            .showSnackBar(SnackBar(
          content: Text('Please Try Again!'),
          backgroundColor: Colors.red,
        ));
      }
    }
    print("user $createchallange");
  }

  // ignore: non_constant_identifier_names
  Future<void> JoinChallenges(uid, challangeid) async {
    var joinchallange = await UserRepository().joiningchallenge(
      uid,
      challangeid,
    );
    print("Joinchallange $joinchallange");
    if (joinchallange == false) {
      Scaffold.of(context)
          // ignore: deprecated_member_use
          .showSnackBar(SnackBar(
        content: Text('No Internet Connection'),
        backgroundColor: Colors.red,
      ));
    } else {
      if (joinchallange["success"] == true) {
        challengeAccepted(context);
      } else {
        Scaffold.of(context)
            // ignore: deprecated_member_use
            .showSnackBar(
          SnackBar(
            content: Text(joinchallange["error"]),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    print("user $joinchallange");
  }

  List elements = [
    {
      "count": "1",
      "leadername": "zuno",
      "name": "@momozuno \nhas earned",
      "url":
          "https://www.pngitem.com/pimgs/m/78-786293_1240-x-1240-0-avatar-profile-icon-png.png",
      "amt": "400",
      "type": "Gwei",
    },
    {
      "count": "2",
      "leadername": "timodit",
      "name": "@jade.sim \nhas earned",
      "url":
          "https://cdn.imgbin.com/1/8/12/imgbin-computer-icons-user-profile-avatar-woman-business-woman-2x9qVDw4EgxX299EhCLm9fN89.jpg",
      "amt": "230",
      "type": "Gwei",
    },
    {
      "count": "3",
      "leadername": "sadiam",
      "name": "@cam.c \nhas earned",
      "url":
          "https://www.clipartmax.com/png/middle/171-1717870_stockvader-predicted-cron-for-may-user-profile-icon-png.png",
      "amt": "40",
      "type": "Gwei",
    },
    {
      "count": "4",
      "leadername": "sadiam",
      "name": "@momozuno \nhas earned",
      "url":
          "https://www.pngitem.com/pimgs/m/78-786293_1240-x-1240-0-avatar-profile-icon-png.png",
      "amt": "400",
      "type": "Gwei",
    },
    {
      "count": "5",
      "leadername": "sadiam",
      "name": "@jade.sim \nhas earned",
      "url":
          "https://cdn.imgbin.com/1/8/12/imgbin-computer-icons-user-profile-avatar-woman-business-woman-2x9qVDw4EgxX299EhCLm9fN89.jpg",
      "amt": "230",
      "type": "Gwei",
    },
    {
      "count": "6",
      "leadername": "sadiam",
      "name": "@cam.c \nhas earned",
      "url":
          "https://www.clipartmax.com/png/middle/171-1717870_stockvader-predicted-cron-for-may-user-profile-icon-png.png",
      "amt": "40",
      "type": "Gwei",
    },
  ];

  List elementsOne = [
    {
      "name": "5KM RUN STREAK",
      "url":
          "https://www.pngitem.com/pimgs/m/78-786293_1240-x-1240-0-avatar-profile-icon-png.png",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "5/7",
      "trophys": "trophy3",
      "color": Colors.blue,
    },
    {
      "name": "3KM RUN STREAK",
      "url":
          "https://cdn.imgbin.com/1/8/12/imgbin-computer-icons-user-profile-avatar-woman-business-woman-2x9qVDw4EgxX299EhCLm9fN89.jpg",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "3/7",
      "trophys": "trophy2",
      "color": Colors.greenAccent,
    },
    {
      "name": "1KM WALK STREAK",
      "url":
          "https://www.clipartmax.com/png/middle/171-1717870_stockvader-predicted-cron-for-may-user-profile-icon-png.png",
      "amt": "+300",
      "type": "Gwei",
      "day": "DAY",
      "count": "1/7",
      "trophys": "trophy1",
      "color": Colors.redAccent,
    },
    {
      "name": "5KM RUN STREAK",
      "url":
          "https://www.pngitem.com/pimgs/m/78-786293_1240-x-1240-0-avatar-profile-icon-png.png",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "5/7",
      "trophys": "trophy3",
      "color": Colors.blue,
    },
    {
      "name": "3KM RUN STREAK",
      "url":
          "https://cdn.imgbin.com/1/8/12/imgbin-computer-icons-user-profile-avatar-woman-business-woman-2x9qVDw4EgxX299EhCLm9fN89.jpg",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "3/7",
      "trophys": "trophy2",
      "color": Colors.greenAccent,
    },
    {
      "name": "1KM WALK STREAK",
      "url":
          "https://www.clipartmax.com/png/middle/171-1717870_stockvader-predicted-cron-for-may-user-profile-icon-png.png",
      "amt": "+300",
      "type": "Gwei",
      "day": "DAY",
      "count": "1/7",
      "trophys": "trophy1",
      "color": Colors.redAccent,
    },
  ];
  List elementsTwo = [
    {
      "name": "5KM RUN \nSTREAK",
      "url":
          "https://www.pngitem.com/pimgs/m/78-786293_1240-x-1240-0-avatar-profile-icon-png.png",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "5/7",
      "trophys": "trophy3",
      "color": Colors.blue,
    },
    {
      "name": "3KM RUN \nSTREAK",
      "url":
          "https://cdn.imgbin.com/1/8/12/imgbin-computer-icons-user-profile-avatar-woman-business-woman-2x9qVDw4EgxX299EhCLm9fN89.jpg",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "3/7",
      "trophys": "trophy2",
      "color": Colors.greenAccent,
    },
    {
      "name": "1KM WALK \nSTREAK",
      "url":
          "https://www.clipartmax.com/png/middle/171-1717870_stockvader-predicted-cron-for-may-user-profile-icon-png.png",
      "amt": "+300",
      "type": "Gwei",
      "day": "DAY",
      "count": "1/7",
      "trophys": "trophy1",
      "color": Colors.redAccent,
    },
    {
      "name": "5KM RUN \nSTREAK",
      "url":
          "https://www.pngitem.com/pimgs/m/78-786293_1240-x-1240-0-avatar-profile-icon-png.png",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "5/7",
      "trophys": "trophy3",
      "color": Colors.blue,
    },
    {
      "name": "3KM RUN \nSTREAK",
      "url":
          "https://cdn.imgbin.com/1/8/12/imgbin-computer-icons-user-profile-avatar-woman-business-woman-2x9qVDw4EgxX299EhCLm9fN89.jpg",
      "amt": "+750",
      "type": "Gwei",
      "day": "DAY",
      "count": "3/7",
      "trophys": "trophy2",
      "color": Colors.greenAccent,
    },
    {
      "name": "1KM WALK \nSTREAK",
      "url":
          "https://www.clipartmax.com/png/middle/171-1717870_stockvader-predicted-cron-for-may-user-profile-icon-png.png",
      "amt": "+300",
      "type": "Gwei",
      "day": "DAY",
      "count": "1/7",
      "trophys": "trophy1",
      "color": Colors.redAccent,
    },
  ];
  var colors = [
    blue1,
    Colors.greenAccent,
    Colors.orangeAccent,
    blue1,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];
  List<Color> joinChallengeColorList = [
    blue1,
    spendingPink,
    containerOrange,
  ];
  List<Color> myActivityColorList = [
    containerGreen,
    spendingPink,
    containerOrange,
  ];
  List<Color> leaderboardColorList = [
    orange,
    blue1,
    spendingPink,
    text1,
  ];

  var trophy = [
    Image.asset("assets/images/trophy3.png"),
    Image.asset("assets/images/trophy2.png"),
    Image.asset("assets/images/trophy1.png"),
  ];
  List<String> day = ["5", "6", "4", "2", "1", "3", "7"];
  var colors1 = [
    Colors.green[300],
    Colors.pinkAccent[100],
    Colors.orange[300],
    Colors.green[300],
    Colors.pinkAccent[100],
    Colors.orange[300],
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKeyWallet,
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        backgroundColor: backgroundcolor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              // height: 50,
              // width: 50,
              color: button,
              child: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Tabscreen(
                                  index: 1,
                                )));
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
        title: Text(
          (lang.length != null &&
                  lang.length != 0 &&
                  userLanguage['chellenges'] != null)
              ? "${userLanguage['chellenges']}"
              : "CHALLENGES",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.35,
              decoration: BoxDecoration(
                  color: button, borderRadius: BorderRadius.circular(40)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "300",
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      (lang.length != null &&
                              lang.length != 0 &&
                              userLanguage['sats'] != null)
                          ? "${userLanguage['sats']}"
                          : "Gwei",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          backgroundColor: blue,
                          valueColor: new AlwaysStoppedAnimation<Color>(blue1),
                        ),
                        Positioned(
                            child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 5),
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['level'] != null)
                                    ? "${userLanguage['level']}"
                                    : "LEVEL",
                                style: GoogleFonts.poppins(
                                  fontSize: 5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 12),
                              child: Text(
                                "02",
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),

                  /******* RECENT WINNERS ListView   *******/
                  Container(
                    height: recentWinnerViewMore == true
                        ? MediaQuery.of(context).size.height * 0.5
                        : MediaQuery.of(context).size.height * 0.27,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        //color: Color(0xff707070),
                        color: Colors.white.withOpacity(0.1),
                        // gradient: RadialGradient(
                        //   colors: [gPink, gBlue, white.withOpacity(0.1)],
                        //   // Add one stop for each color
                        //   // Values should increase from 0.0 to 1.0
                        //   //stops: [0.1, 0.5, 0.6]
                        //   center: Alignment(-1.2, 0.0),
                        //   //focal: Alignment(0.1, -0.1),
                        // ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['recentwinners'] != null)
                                    ? "${userLanguage['recentwinners']}"
                                    : "RECENT WINNERS",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  recentWinnerViewMore = true;
                                });
                              },
                              child: recentWinnerViewMore == true
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          recentWinnerViewMore = false;
                                          //print(recentWinnerViewMore);
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          decoration: BoxDecoration(
                                              color: blue2,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                            child: Text(
                                              (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage[
                                                              'viewless'] !=
                                                          null)
                                                  ? "${userLanguage['viewless']}"
                                                  : "VIEW LESS",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 8,
                                                  color: white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: BoxDecoration(
                                            color: blue.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['viewmore'] !=
                                                        null)
                                                ? "${userLanguage['viewmore']}"
                                                : "VIEW MORE",
                                            style: GoogleFonts.poppins(
                                                fontSize: 8,
                                                color: blue1,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                gPink.withOpacity(0.3),
                                // gBlue.withOpacity(0.5),
                                white.withOpacity(0.0)
                              ],
                              // Add one stop for each color
                              // Values should increase from 0.0 to 1.0
                              //stops: [0.3, 0.7, 0.8],
                              center: Alignment(-1.0, 0.0),
                              focal: Alignment(-1.0, -0.1),
                            ),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 0, right: 0),
                            //color: Colors.indigo,
                            // decoration: BoxDecoration(
                            //   gradient: RadialGradient(
                            //     colors: [
                            //       //gPink.withOpacity(0.3),
                            //       gBlue.withOpacity(0.2),
                            //       white.withOpacity(0.0)
                            //     ],
                            //     // Add one stop for each color
                            //     // Values should increase from 0.0 to 1.0
                            //     stops: [0.4, 0.8],
                            //     center: Alignment(-0.4, 0.0),
                            //     focal: Alignment(-0.5, -0.2),
                            //   ),
                            // ),
                            padding: EdgeInsets.only(
                                left: 4, top: 10, bottom: 0, right: 0),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: elements.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  // onTap: () {
                                  //   if (elements[index]['name'] ==
                                  //       '@momozuno \nhas earned') {
                                  //     Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //             builder: (context) => MyActivity()));
                                  //   }
                                  // },
                                  child: Stack(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.17,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        //color: Colors.pink,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.15,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.30,
                                              //height: 112,
                                              //width: 113,
                                              decoration: BoxDecoration(
                                                  color: white.withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.04,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      //height: 29, width: 79,
                                                      //color: Colors.red,
                                                      child: Center(
                                                        child: Text(
                                                            elements[index]
                                                                ['name'],
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 11,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.06,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    // height: 43, width: 93,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.25),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            elements[index][
                                                                'amt'],
                                                            style: GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          child: Text(
                                                              elements[index]
                                                                  ['type'],
                                                              style: GoogleFonts.poppins(
                                                                  color: Colors
                                                                      .orangeAccent,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.001,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.13,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Container(
                                              height: 30,
                                              width: 30,
                                              color: button,
                                              child: Image.network(
                                                elements[index]['url'],
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  /******* JOIN CHALLENGES  ListView   *******/
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    // decoration: BoxDecoration(
                    //     //color: Color(0xff313248),
                    //     borderRadius: BorderRadius.circular(10)),

                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          //gPink.withOpacity(0.3),
                          gBlue.withOpacity(0.1),
                          white.withOpacity(0.0),
                        ],
                        // Add one stop for each color
                        // Values should increase from 0.0 to 1.0
                        stops: [0.6, 1],
                        center: Alignment(-.2, 0),
                        focal: Alignment(0.1, -0.1),
                        //focalRadius: 0.3,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['joinchallenges'] != null)
                                    ? "${userLanguage['joinchallenges']}"
                                    : "JOIN CHALLENGE",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewmoreJoinChallenge()));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: BoxDecoration(
                                      color: blue.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['viewmore'] != null)
                                          ? "${userLanguage['viewmore']}"
                                          : "VIEW MORE",
                                      style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          color: blue1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        challengesOne.length == 0
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("NO CHALLENGES",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ),
                              )
                            : loading == true
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    color: backgroundcolor,
                                    child: Center(
                                      child: SpinKitSpinningLines(
                                        color: white,
                                        size: 60,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(left: 5, right: 0),
                                    //color: Colors.indigo,
                                    // decoration: BoxDecoration(
                                    //   gradient: RadialGradient(
                                    //     colors: [
                                    //       //gPink.withOpacity(0.3),
                                    //       gBlue.withOpacity(0.4),
                                    //       white.withOpacity(0.0),
                                    //     ],
                                    //     // Add one stop for each color
                                    //     // Values should increase from 0.0 to 1.0
                                    //     stops: [0.6, 1],
                                    //     center: Alignment(-.2, -.2),
                                    //     focal: Alignment(0.1, -0.1),
                                    //     //focalRadius: 0.3,
                                    //   ),
                                    // ),
                                    padding: EdgeInsets.only(
                                        left: 4, top: 10, bottom: 0, right: 0),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: challengesOne.length,
                                      itemBuilder: (context, index) {
                                        print(
                                            "challenge length : ${challengesOne.length}");
                                        return InkWell(
                                          onTap: () {
                                            // googlefitint != true
                                            //     ? startBetting(context,
                                            //         challengesOne[index])
                                            // :
                                            joinChallenge(
                                                context, challengesOne[index]);
                                            //   if (elements[index]['name'] ==
                                            //       '@momozuno \nhas earned') {
                                            //     Navigator.push(
                                            //         context,
                                            //         MaterialPageRoute(
                                            //             builder: (context) => MyActivity()));
                                            //   }
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.38,
                                                //color: Colors.pink,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.17,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.35,
                                                      // height: 126,
                                                      // width: 130,
                                                      decoration: BoxDecoration(
                                                        color: joinChallengeColorList[
                                                            index %
                                                                joinChallengeColorList
                                                                    .length],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 20),
                                                            child: Center(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        challengesOne[index].totalKm +
                                                                            "KM ",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        challengesOne[index].mode ==
                                                                                "Walking"
                                                                            ? "WALK"
                                                                            : "RUN",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    challengesOne[
                                                                            index]
                                                                        .type
                                                                        .toUpperCase(),
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.06,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.28,
                                                            // height: 43,
                                                            // width: 93,
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xffFF8C00),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.28,
                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .scaleDown,
                                                                    child: Text(
                                                                      "+" +
                                                                          challengesOne[index]
                                                                              .wage +
                                                                          " Gwei",
                                                                      style: GoogleFonts.poppins(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Positioned(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01,
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.13,
                                                child: Container(
                                                  height: 43,
                                                  width: 43,
                                                  //color: button,
                                                  child: trophy[
                                                      index % trophy.length],
                                                ),
                                              ),
                                              // Positioned(
                                              //   top: MediaQuery.of(context)
                                              //           .size
                                              //           .height *
                                              //       0.01,
                                              //   left: MediaQuery.of(context)
                                              //           .size
                                              //           .width *
                                              //       0.13,
                                              //   child: Container(
                                              //     height: 43,
                                              //     width: 43,
                                              //     //color: button,
                                              //     child: Image.asset(
                                              //       "assets/images/${elementsTwo[index]['trophys']}.png",
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  /******* MY CHALLENGES ListView   *******/
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        //color: Color(0xff313248),
                        gradient: RadialGradient(
                          colors: [
                            gPink.withOpacity(0.1),
                            //gBlue.withOpacity(0.2),
                            white.withOpacity(0.0),
                          ],
                          // Add one stop for each color
                          // Values should increase from 0.0 to 1.0
                          stops: [0.6, 1],
                          center: Alignment(0.4, 0),
                          focal: Alignment(0.6, -0.1),
                          //focalRadius: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['mychallenges'] != null)
                                    ? "${userLanguage['mychallenges']}"
                                    : "MY CHALLENGES",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewmoreMyChallenge()));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: BoxDecoration(
                                      color: blue.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['viewmore'] != null)
                                          ? "${userLanguage['viewmore']}"
                                          : "VIEW MORE",
                                      style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          color: blue1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                        /**  add err condition for my challenge**/
                        mychallenge.length == 0
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("NO CHALLENGES",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ),
                              )
                            : loading == true
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    color: backgroundcolor,
                                    child: Center(
                                      child: SpinKitSpinningLines(
                                        color: white,
                                        size: 60,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(left: 5, right: 0),
                                    //color: Colors.indigo,
                                    padding: EdgeInsets.only(
                                        left: 4, top: 10, bottom: 0, right: 0),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mychallenge.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            challangedetails(
                                                context, mychallenge[index]);
                                            // if (elementsOne[index]['name'] ==
                                            //     '5KM RUN STREAK') {
                                            // joinChallenge(context);
                                            //}
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.38,
                                                //color: Colors.pink,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.17,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.35,
                                                      // height: 126,
                                                      // width: 130,
                                                      decoration: BoxDecoration(
                                                          color: joinChallengeColorList[
                                                              index %
                                                                  joinChallengeColorList
                                                                      .length],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 20),
                                                            child: Center(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        challengesOne[index].totalKm +
                                                                            "KM ",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        challengesOne[index].mode ==
                                                                                "Walking"
                                                                            ? "WALK"
                                                                            : "RUN",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    challengesOne[
                                                                            index]
                                                                        .type
                                                                        .toUpperCase(),
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.06,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.28,
                                                            // height: 43,
                                                            // width: 93,
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xffFF8C00),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.28,
                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .scaleDown,
                                                                    child: Text(
                                                                      "+" +
                                                                          challengesOne[index]
                                                                              .wage +
                                                                          " Gwei",
                                                                      style: GoogleFonts.poppins(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01,
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.13,
                                                child: Container(
                                                  height: 43,
                                                  width: 43,
                                                  //color: button,
                                                  child: trophy[
                                                      index % trophy.length],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  /******* MY ACTIVITY ListView   *******/
                  Container(
                    // height: MediaQuery.of(context).size.height * 0.28,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        //color: white.withOpacity(0.3),
                        gradient: RadialGradient(
                          colors: [
                            //gPink.withOpacity(0.1),
                            gBlue.withOpacity(0.15),
                            white.withOpacity(0.0),
                          ],
                          // Add one stop for each color
                          // Values should increase from 0.0 to 1.0
                          stops: [0.6, 1],
                          center: Alignment(-.3, 0),
                          focal: Alignment(-.3, -0.1),
                          //focalRadius: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['myactivity'] != null)
                                    ? "${userLanguage['myactivity']}"
                                    : "MY ACTIVITY",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                //print("Gopinath");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyActivity()));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: BoxDecoration(
                                      color: blue.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['viewmore'] != null)
                                          ? "${userLanguage['viewmore']}"
                                          : "VIEW MORE",
                                      style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          color: blue1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        joingetchallenge.length == 0
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("NO CHALLENGES",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ),
                              )
                            : loading == true
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    color: backgroundcolor,
                                    child: Center(
                                      child: SpinKitSpinningLines(
                                        color: white,
                                        size: 60,
                                      ),
                                    ),
                                  )
                                : Container(
                                    // height: MediaQuery.of(context).size.height *
                                    //     0.26,
                                    // width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(left: 5, right: 0),
                                    //color: Colors.indigo,
                                    padding: EdgeInsets.only(
                                        left: 4, top: 10, bottom: 0, right: 0),
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: joingetchallenge.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        print(joingetchallenge.length);
                                        return GestureDetector(
                                          onTap: () {
                                            print(joingetchallenge[index]);
                                            getwinnerChallenges(
                                                joingetchallenge[index].id);
                                            challangedetails(context,
                                                joingetchallenge[index]);
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             HealthKit()));
                                          },
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 15,
                                                      ),
                                                      Container(
                                                        height: 59,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.83,
                                                        decoration: BoxDecoration(
                                                            color: myActivityColorList[
                                                                index %
                                                                    myActivityColorList
                                                                        .length],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              height: 59,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius: BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            15),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            25),
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            15),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            25)),
                                                              ),
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      joingetchallenge[index]
                                                                              .totalKm +
                                                                          "KM ",
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      joingetchallenge[index].mode ==
                                                                              "Walking"
                                                                          ? "WALK "
                                                                          : "RUN ",
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      joingetchallenge[
                                                                              index]
                                                                          .type
                                                                          .toUpperCase(),
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      " (" +
                                                                          steps.toStringAsFixed(
                                                                              2) +
                                                                          "KM)",
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 0),
                                                              child: Container(
                                                                height: 33,
                                                                width: 85,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.25),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text("DAY",
                                                                        style: GoogleFonts.poppins(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600)),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              5),
                                                                      child: Text(
                                                                          "5",
                                                                          style: GoogleFonts.poppins(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600)),
                                                                    ),
                                                                    Text(
                                                                        " / " +
                                                                            joingetchallenge[index]
                                                                                .streakDays,
                                                                        style: GoogleFonts.poppins(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // child: ListTile(
                                                        //   title: Padding(
                                                        //     padding:
                                                        //         const EdgeInsets.fromLTRB(
                                                        //             0, 0, 20, 2),
                                                        //     child: Container(
                                                        //       height: 60,
                                                        //       decoration: BoxDecoration(
                                                        //           color: Colors.black
                                                        //               .withOpacity(0.1),
                                                        //           borderRadius:
                                                        //               BorderRadius.circular(
                                                        //                   15)),
                                                        //       child: Center(
                                                        //         child: Text(
                                                        //           elementsOne[index]['name'],
                                                        //           style: GoogleFonts.poppins(
                                                        //             color: Colors.black,
                                                        //             fontSize: 14,
                                                        //             fontWeight:
                                                        //                 FontWeight.w600,
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        //   trailing: Container(
                                                        //     height: 33,
                                                        //     width: 85,
                                                        //     decoration: BoxDecoration(
                                                        //         color: Colors.white
                                                        //             .withOpacity(0.25),
                                                        //         borderRadius:
                                                        //             BorderRadius.circular(
                                                        //                 16)),
                                                        //     child: Row(
                                                        //       mainAxisAlignment:
                                                        //           MainAxisAlignment.center,
                                                        //       children: [
                                                        //         Text(
                                                        //             elementsOne[index]['day'],
                                                        //             style:
                                                        //                 GoogleFonts.poppins(
                                                        //                     color:
                                                        //                         Colors.white,
                                                        //                     fontSize: 12,
                                                        //                     fontWeight:
                                                        //                         FontWeight
                                                        //                             .w600)),
                                                        //         Padding(
                                                        //           padding:
                                                        //               const EdgeInsets.only(
                                                        //                   left: 5),
                                                        //           child: Text(
                                                        //               elementsOne[index]
                                                        //                   ['count'],
                                                        //               style:
                                                        //                   GoogleFonts.poppins(
                                                        //                       color: Colors
                                                        //                           .white,
                                                        //                       fontSize: 12,
                                                        //                       fontWeight:
                                                        //                           FontWeight
                                                        //                               .w400)),
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15)
                                                ],
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: trophy[
                                                      index % trophy.length],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  /******* Leaderboard ListView   *******/
                  Container(
                    // height: MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        //color: white.withOpacity(0.3),
                        gradient: RadialGradient(
                          colors: [
                            //gPink.withOpacity(0.1),
                            gBlue.withOpacity(0.1),
                            white.withOpacity(0.0),
                          ],
                          // Add one stop for each color
                          // Values should increase from 0.0 to 1.0
                          stops: [0.6, 1],
                          center: Alignment(0.4, 0),
                          focal: Alignment(0.6, -0.1),
                          //focalRadius: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['leaderboard'] != null)
                                    ? "${userLanguage['leaderboard']}"
                                    : "LEADERBOARD",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  leaderViewMore = true;
                                  //print(leaderViewMore);
                                });
                              },
                              child: leaderViewMore == true
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          leaderViewMore = false;
                                          //print(leaderViewMore);
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          decoration: BoxDecoration(
                                              color: blue2,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                            child: Text(
                                              (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage[
                                                              'viewless'] !=
                                                          null)
                                                  ? "${userLanguage['viewless']}"
                                                  : "VIEW LESS",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 8,
                                                  color: white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: BoxDecoration(
                                            color: blue.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['viewmore'] !=
                                                        null)
                                                ? "${userLanguage['viewmore']}"
                                                : "VIEW MORE",
                                            style: GoogleFonts.poppins(
                                                fontSize: 8,
                                                color: blue1,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        /**** leaderboard view less container *****/
                        leaderViewMore == false
                            ? Container(
                                // height: MediaQuery.of(context).size.height * 0.28,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(left: 5, right: 0),
                                //color: Colors.indigo,
                                padding: EdgeInsets.only(
                                    left: 4, top: 10, bottom: 0, right: 0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: elements.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        leaderboardProfile(context);
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.07,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  //height: 63, width: 42,
                                                  decoration: BoxDecoration(
                                                      color: leaderboardColorList[
                                                          index %
                                                              leaderboardColorList
                                                                  .length],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16)),
                                                  child: Center(
                                                    child: Text(
                                                      elements[index]["count"],
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.07,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.75,
                                                  //height: 63, width: 300,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  child: ListTile(
                                                    leading: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Container(
                                                          height: 35,
                                                          width: 35,
                                                          color: button,
                                                          child: Image.network(
                                                            elements[index]
                                                                ['url'],
                                                            fit: BoxFit.cover,
                                                          )),
                                                    ),
                                                    title: Text(
                                                      elements[index]
                                                              ["leadername"]
                                                          .toString()
                                                          .toUpperCase(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),

                                                    //subtitle: Text("rating"),
                                                    subtitle: RatingBar.builder(
                                                      initialRating: 3,
                                                      minRating: 1,
                                                      direction:
                                                          Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemCount: 3,
                                                      itemSize: 10,
                                                      itemPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 0.2),
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        print(rating);
                                                      },
                                                    ),
                                                    trailing: Container(
                                                      // height: MediaQuery.of(context)
                                                      //         .size
                                                      //         .height *
                                                      //     0.05,
                                                      // width: MediaQuery.of(context)
                                                      //         .size
                                                      //         .width *
                                                      //     0.25,
                                                      height: 38, width: 98,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.25),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              elements[index]
                                                                  ['amt'],
                                                              style: GoogleFonts.poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5),
                                                            child: Text("Gwei",
                                                                style: GoogleFonts.poppins(
                                                                    color: Colors
                                                                        .orangeAccent,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )

                            /**** leaderboard view more container *****/

                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    width: MediaQuery.of(context).size.width,
                                    //color: Colors.red,
                                    child: GridView.builder(
                                        itemCount: elements.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? 3
                                              : 2,
                                          crossAxisSpacing: 0,
                                          mainAxisSpacing: 0,
                                          childAspectRatio: (1 / 0.8),
                                        ),
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          return GestureDetector(
                                            onTap: () {
                                              //leaderboardProfile(context);
                                              // Navigator.of(context)
                                              //     .pushNamed(RouteName.GridViewCustom);
                                            },
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.15,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.09,
                                                    decoration: BoxDecoration(
                                                      color: leaderboardColorList[
                                                          index %
                                                              leaderboardColorList
                                                                  .length],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        (lang.length != null &&
                                                                lang.length !=
                                                                    0 &&
                                                                userLanguage[
                                                                        ''] !=
                                                                    null)
                                                            ? "${userLanguage['']}"
                                                            : elements[index]
                                                                ["count"],
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 14,
                                                                color: white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      // leaderboardProfile(context);
                                                      // setState(() {
                                                      //   viewProfile == true;
                                                      // });
                                                    },
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.15,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.17,
                                                      decoration: BoxDecoration(
                                                        color: white
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            leading: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              child: Container(
                                                                  height: 45,
                                                                  width: 45,
                                                                  color: button,
                                                                  child: Image
                                                                      .network(
                                                                    elements[
                                                                            index]
                                                                        ['url'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                            ),
                                                            title: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                elements[index][
                                                                        "leadername"]
                                                                    .toUpperCase(),
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            subtitle: RatingBar
                                                                .builder(
                                                              initialRating: 3,
                                                              minRating: 1,
                                                              direction: Axis
                                                                  .horizontal,
                                                              allowHalfRating:
                                                                  true,
                                                              itemCount: 3,
                                                              itemSize: 10,
                                                              itemPadding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          0.2),
                                                              itemBuilder:
                                                                  (context,
                                                                          _) =>
                                                                      Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              onRatingUpdate:
                                                                  (rating) {
                                                                print(rating);
                                                              },
                                                            ),
                                                          ),
                                                          viewProfile == false
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      viewProfile =
                                                                          true;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.05,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.3,
                                                                    //height: 40, width: 105,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                                0.25),
                                                                        borderRadius:
                                                                            BorderRadius.circular(17)),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        FittedBox(
                                                                          fit: BoxFit
                                                                              .scaleDown,
                                                                          child: Text(
                                                                              elements[index]['amt'],
                                                                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 3),
                                                                          child: Text(
                                                                              "Gwei",
                                                                              style: GoogleFonts.poppins(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w400)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : InkWell(
                                                                  onTap: () {
                                                                    leaderboardProfile(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.05,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.3,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          blue2,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              17),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        (lang.length != null &&
                                                                                lang.length != 0 &&
                                                                                userLanguage['viewprofile'] != null)
                                                                            ? "${userLanguage['viewprofile']}"
                                                                            : "VIEW PROFILE",
                                                                        style: GoogleFonts.montserrat(
                                                                            fontSize:
                                                                                9,
                                                                            color:
                                                                                white,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        })),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(
                      color: blue1,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () {
                        showdialog(context);
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => WalletCreatingChallenge()));
                      },
                      color: blue1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              showdialog(context);
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Text(
                            (lang.length != null &&
                                    lang.length != 0 &&
                                    userLanguage['createachallenge'] != null)
                                ? "${userLanguage['createachallenge']}"
                                : "CREATE A CHALLENGE",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool ischeckvisible = false;
  bool iswalking = false;
  bool isrunning = false;
  var selecttype;
  var wagar;
  var challenge;
  var kmchallenge;
  var competitorsgets;

  void showdialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        (lang.length != null &&
                                lang.length != 0 &&
                                userLanguage['createachellenge'] != null)
                            ? "${userLanguage['createachellenge']}"
                            : "CREATE A \nCHALLENGE",
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.none,
                          height: 1,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LinearPercentIndicator(
                          width: 100,
                          lineHeight: 25.0,
                          percent: 0.25,
                          center: Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Text(
                              "25%",
                              style: GoogleFonts.poppins(
                                  color: white,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: backgroundcolor,
                          progressColor: blue,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: 467,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            SizedBox(height: 40),
                            Text(
                              "Select an Activity",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 70),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 188,
                                  width: 134,
                                  decoration: BoxDecoration(
                                      color: iswalking == true ? blue1 : button,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: GestureDetector(
                                    onTap: () {
                                      selecttype = "";
                                      setState(() {
                                        selecttype = "Walking";
                                        iswalking = !iswalking;
                                        isrunning = false;
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Container(
                                                height: 25,
                                                width: 25,
                                                color: backgroundcolor,
                                                child: iswalking == true
                                                    ? IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            iswalking = true;
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.check,
                                                          color: blue1,
                                                          size: 10,
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0,
                                                      ) // : SizedBox(0),
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Container(
                                              height: 60,
                                              width: 48,
                                              //color: Colors.red,
                                              child: Image.asset(
                                                "assets/images/walking.png",
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['walking'] !=
                                                        null)
                                                ? "${userLanguage['walking']}"
                                                : "WALKING",
                                            style: GoogleFonts.poppins(
                                                decoration: TextDecoration.none,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30),
                                Container(
                                  height: 188,
                                  width: 134,
                                  decoration: BoxDecoration(
                                      color: isrunning == true ? blue1 : button,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: GestureDetector(
                                    onTap: () {
                                      selecttype = "";
                                      setState(() {
                                        selecttype = "Running";
                                        isrunning = !isrunning;
                                        iswalking = false;
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Container(
                                                height: 25,
                                                width: 25,
                                                color: backgroundcolor,
                                                child: isrunning == true
                                                    ? IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            isrunning = true;
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.check,
                                                          color: blue1,
                                                          size: 10,
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0,
                                                      ) // : SizedBox(0),
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Container(
                                              height: 60,
                                              width: 48,
                                              //color: Colors.red,
                                              child: Image.asset(
                                                "assets/images/running.png",
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['running'] !=
                                                        null)
                                                ? "${userLanguage['running']}"
                                                : "RUNNING",
                                            style: GoogleFonts.poppins(
                                                decoration: TextDecoration.none,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              height: 55,
                              width: 321,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                onPressed: () {
                                  if (iswalking == true || isrunning == true) {
                                    print("selcettype$selecttype");
                                    Navigator.pop(context);
                                    selectsat(context);
                                  }
                                  return;
                                },
                                //color: blue.withOpacity(0.3),
                                color: iswalking == true || isrunning == true
                                    ? blue1
                                    : button,
                                child: Text(
                                  (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['next'] != null)
                                      ? "${userLanguage['next']}"
                                      : "NEXT",
                                  style: GoogleFonts.poppins(
                                    //color: blue1,
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _focusedIndex = 0;
  void selectsat(BuildContext context) {
    for (int i = 0; i < 40; i++) {
      value = value + 5;
      data.add(value);
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            void _onItemFocus(int index) {
              print("123456,$index");
              print(data[index]);
              setState(() {
                _focusedIndex = index;
                print(_focusedIndex);
              });
            }

            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        (lang.length != null &&
                                lang.length != 0 &&
                                userLanguage['createachellenge'] != null)
                            ? "${userLanguage['createachellenge']}"
                            : "CREATE A \nCHALLENGE",
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.none,
                          height: 1,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LinearPercentIndicator(
                          width: 100,
                          lineHeight: 25.0,
                          percent: 0.40,
                          center: Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Text(
                              "50%",
                              style: GoogleFonts.poppins(
                                  color: white,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          // trailing: Icon(Icons.mood),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: backgroundcolor,
                          progressColor: blue,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: 467,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            // SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  // width: MediaQuery.of(context).size.width,
                                  //color: Colors.red,
                                  child: Center(
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage['howmany'] !=
                                                      null)
                                              ? "${userLanguage['howmany']}"
                                              : 'How many',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      TextSpan(
                                          text: (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage['sats'] != null)
                                              ? "${userLanguage['sats']}"
                                              : ' Gwei ',
                                          style: GoogleFonts.poppins(
                                            color: Colors.orange,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      TextSpan(
                                          text: (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage[
                                                          'wouldyouliketowager'] !=
                                                      null)
                                              ? "${userLanguage['wouldyouliketowager']}"
                                              : 'would \n       you like to wager?',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            height: 1,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ])),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            // HorizontalList(),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              child: ScrollSnapList(
                                duration: 500,
                                scrollPhysics: BouncingScrollPhysics(),
                                onItemFocus: _onItemFocus,
                                itemSize: 50,
                                itemBuilder: _buildListItem,
                                itemCount: data.length,
                                reverse: false,
                                dynamicItemSize: false,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width * 0.8,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                onPressed: () {
                                  print(data[_focusedIndex]);

                                  wagar = data[_focusedIndex];
                                  Navigator.pop(context);
                                  selectKM(context);

                                  // print(_focusedIndex);
                                },
                                //color: blue.withOpacity(0.3),
                                color: blue1,
                                child: Text(
                                  (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['next'] != null)
                                      ? "${userLanguage['next']}"
                                      : "NEXT",
                                  style: GoogleFonts.poppins(
                                    //color: blue1,
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void selectKM(BuildContext context) {
    for (int i = 0; i < 40; i++) {
      value = value + 5;
      data.add(value);
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            void _onItemFocus(int index) {
              print("123456,$index");
              print(data[index]);
              setState(() {
                _focusedIndex = index;
                print(_focusedIndex);
              });
            }

            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        (lang.length != null &&
                                lang.length != 0 &&
                                userLanguage['createachellenge'] != null)
                            ? "${userLanguage['createachellenge']}"
                            : "CREATE A \nCHALLENGE",
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.none,
                          height: 1,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LinearPercentIndicator(
                          width: 100,
                          lineHeight: 25.0,
                          percent: 0.40,
                          center: Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Text(
                              "50%",
                              style: GoogleFonts.poppins(
                                  color: white,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          // trailing: Icon(Icons.mood),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: backgroundcolor,
                          progressColor: blue,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: 467,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            // SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  // width: MediaQuery.of(context).size.width,
                                  //color: Colors.red,
                                  child: Center(
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage['howmany'] !=
                                                      null)
                                              ? "${userLanguage['howmany']}"
                                              : 'How many',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      TextSpan(
                                          text: (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage['sats'] != null)
                                              ? "${userLanguage['sats']}"
                                              : ' Km ',
                                          style: GoogleFonts.poppins(
                                            color: Colors.orange,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      TextSpan(
                                          text: (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage[
                                                          'wouldyouliketowager'] !=
                                                      null)
                                              ? "${userLanguage['wouldyouliketowager']}"
                                              : 'would \n   you like to $selecttype?',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            height: 1,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ])),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            // HorizontalList(),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.16,
                              child: ScrollSnapList(
                                duration: 500,
                                scrollPhysics: BouncingScrollPhysics(),
                                onItemFocus: _onItemFocus,
                                itemSize: 50,
                                itemBuilder: _buildListItem,
                                itemCount: data.length,
                                reverse: false,
                                dynamicItemSize: false,
                              ),
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width * 0.8,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                onPressed: () {
                                  print(data[_focusedIndex]);

                                  kmchallenge = data[_focusedIndex];
                                  Navigator.pop(context);
                                  selectchallengetype(context);

                                  // print(_focusedIndex);
                                },
                                //color: blue.withOpacity(0.3),
                                color: blue1,
                                child: Text(
                                  (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['next'] != null)
                                      ? "${userLanguage['next']}"
                                      : "NEXT",
                                  style: GoogleFonts.poppins(
                                    //color: blue1,
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void selectchallengetype(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        (lang.length != null &&
                                lang.length != 0 &&
                                userLanguage['createachellenge'] != null)
                            ? "${userLanguage['createachellenge']}"
                            : "CREATE A \nCHALLENGE",
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.none,
                          height: 1,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LinearPercentIndicator(
                          width: 100,
                          lineHeight: 25.0,
                          percent: 0.50,
                          center: Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Text(
                              "75%",
                              style: GoogleFonts.poppins(
                                  color: white,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          // trailing: Icon(Icons.mood),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: backgroundcolor,
                          progressColor: blue,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: 467,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            // SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    // width: MediaQuery.of(context).size.width,
                                    //color: Colors.red,
                                    child: Center(
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage[
                                                        'whattypeofchallenge'] !=
                                                    null)
                                            ? "${userLanguage['whattypeofchallenge']}"
                                            : "What type of \n  challenge?",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.white,
                                            height: 1,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      ischeckvisible = !ischeckvisible;
                                    });
                                  },
                                  child: Container(
                                    height: 188,
                                    width: 134,
                                    decoration: BoxDecoration(
                                        color: ischeckvisible == true
                                            ? blue1
                                            : button,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: GestureDetector(
                                            onTap: () {
                                              // setState(() {
                                              //   ischeckvisible = true;
                                              // });
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                color: backgroundcolor,
                                                child: ischeckvisible == true
                                                    ? IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            ischeckvisible =
                                                                false;
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.check,
                                                          color: blue1,
                                                          size: 10,
                                                        ))
                                                    : SizedBox(
                                                        height: 0,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Container(
                                              height: 60,
                                              width: 48,
                                              //color: Colors.red,
                                              child: Image.asset(
                                                "assets/images/streak.png",
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['streak'] !=
                                                        null)
                                                ? "${userLanguage['streak']}"
                                                : "STREAK",
                                            style: GoogleFonts.poppins(
                                                decoration: TextDecoration.none,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 188,
                                  width: 134,
                                  decoration: BoxDecoration(
                                      color: button,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Container(
                                          height: 28,
                                          width: 86,
                                          decoration: BoxDecoration(
                                              color: blue1,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Center(
                                            child: Text(
                                                (lang.length != null &&
                                                        lang.length != 0 &&
                                                        userLanguage[
                                                                'commingsoon'] !=
                                                            null)
                                                    ? "${userLanguage['commingsoon']}"
                                                    : "COMING SOON",
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                            height: 60,
                                            width: 40,
                                            //color: Colors.red,
                                            child: Opacity(
                                              opacity: 0.25,
                                              child: Image.asset(
                                                "assets/images/speed.png",
                                                fit: BoxFit.fill,
                                              ),
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage['speed'] != null)
                                              ? "${userLanguage['speed']}"
                                              : "SPEED",
                                          style: GoogleFonts.poppins(
                                              decoration: TextDecoration.none,
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 60,
                            ),
                            Container(
                              height: 55,
                              width: 321,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  onPressed: () {
                                    if (ischeckvisible == true) {
                                      challenge = "Streak";
                                      Navigator.pop(context);
                                      selectshowcompetitors(context);
                                    }
                                    return;
                                  },
                                  //color: blue.withOpacity(0.3),
                                  color:
                                      ischeckvisible == true ? blue1 : button,
                                  child: Text(
                                    (lang.length != null &&
                                            lang.length != 0 &&
                                            userLanguage['next'] != null)
                                        ? "${userLanguage['next']}"
                                        : "NEXT",
                                    style: GoogleFonts.poppins(
                                      //color: blue1,
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void selectshowcompetitors(BuildContext context) {
    for (int i = 0; i < 40; i++) {
      value = value + 5;
      data.add(value);
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            void _onItemFocus(int index) {
              print("123456,$index");
              print(data[index]);
              setState(() {
                _focusedIndex = index;
                print(_focusedIndex);
              });
            }

            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        (lang.length != null &&
                                lang.length != 0 &&
                                userLanguage['createachellenge'] != null)
                            ? "${userLanguage['createachellenge']}"
                            : "CREATE A \nCHALLENGE",
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.none,
                          height: 1,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LinearPercentIndicator(
                          width: 100,
                          lineHeight: 25.0,
                          percent: 0.50,
                          center: Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Text(
                              "75%",
                              style: GoogleFonts.poppins(
                                  color: white,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          // trailing: Icon(Icons.mood),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: backgroundcolor,
                          progressColor: blue,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: 467,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            // SizedBox(height: 40),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    // width: MediaQuery.of(context).size.width,
                                    //color: Colors.red,
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage[
                                                              'howmanycompetitorswouldyoulike'] !=
                                                          null)
                                                  ? "${userLanguage['howmanycompetitorswouldyoulike']}"
                                                  : 'How many competitors \n         would you like?',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.16,
                              child: ScrollSnapList(
                                duration: 500,
                                scrollPhysics: BouncingScrollPhysics(),
                                onItemFocus: _onItemFocus,
                                itemSize: 50,
                                itemBuilder: _buildListItem,
                                itemCount: data.length,
                                reverse: false,
                                dynamicItemSize: false,
                              ),
                            ),
                            // HorizontalList(),
                            // Container(
                            //   height: MediaQuery.of(context).size.height * 0.13,
                            //   width: MediaQuery.of(context).size.width,
                            //   // color: Colors.amber,
                            //   child: SfLinearGauge(
                            //       markerPointers: [
                            //         LinearShapePointer(
                            //           value: _pointerValue,
                            //           onValueChanged: (value) => {
                            //             setState(() => {_pointerValue = value})
                            //           },
                            //           shapeType: LinearShapePointerType
                            //               .invertedTriangle,
                            //           color: blue1,
                            //           elevation: 10,
                            //         )
                            //       ],
                            //       tickPosition: LinearElementPosition.outside,
                            //       labelPosition: LinearLabelPosition.outside,
                            //       majorTickStyle: LinearTickStyle(
                            //           length: 70, thickness: 2, color: button),
                            //       minorTickStyle: LinearTickStyle(
                            //           length: 40,
                            //           thickness: 1.75,
                            //           color: button),
                            //       axisLabelStyle: GoogleFonts.montserrat(
                            //         fontSize: 15,
                            //         color: Colors.grey,
                            //       )),
                            // ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              "WINNER GETS",
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF808DA7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${data[_focusedIndex] * 100}",
                              style: GoogleFonts.montserrat(
                                  color: Colors.orange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width * 0.8,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  onPressed: () {
                                    competitorsgets = data[_focusedIndex] * 100;
                                    Navigator.pop(context);
                                    selectshowsummary(context);
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             WalletChallengeFive()));
                                  },
                                  //color: blue.withOpacity(0.3),
                                  color: blue1,
                                  child: Text(
                                    (lang.length != null &&
                                            lang.length != 0 &&
                                            userLanguage['next'] != null)
                                        ? "${userLanguage['next']}"
                                        : "NEXT",
                                    style: GoogleFonts.poppins(
                                      //color: blue1,
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void selectshowsummary(BuildContext context) {
    var todayDate = new DateTime.now();
    var todayDate1 = new DateTime.now();
    var days =
        new DateTime(todayDate1.year, todayDate1.month, todayDate1.day + 7);
    var expiryDate = (DateFormat.yMMMd().format(days)).toString();
    var today1 = (DateFormat.yMMMd().format(todayDate)).toString();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: backgroundcolor.withOpacity(0.7),
                margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                child: Column(
                  //  shrinkWrap: true,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Card(
                          color: gridcolor,
                          elevation: 20,
                          // shadowColor: button.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                            // side: new BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: gridcolor),
                              child: Center(
                                child: Icon(Icons.arrow_back,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          (lang.length != null &&
                                  lang.length != 0 &&
                                  userLanguage['createachellenge'] != null)
                              ? "${userLanguage['createachellenge']}"
                              : "CREATE A \nCHALLENGE",
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.none,
                            height: 1,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: LinearPercentIndicator(
                            width: 100,
                            lineHeight: 25.0,
                            percent: 0.80,
                            center: Padding(
                              padding: const EdgeInsets.only(left: 54),
                              child: Text(
                                "95%",
                                style: GoogleFonts.poppins(
                                    color: white,
                                    letterSpacing: 1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            // trailing: Icon(Icons.mood),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            backgroundColor: backgroundcolor,
                            progressColor: blue,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        shadowColor: button.withOpacity(0.5),
                        color: Color(0xff1C203A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            child: Column(
                              // shrinkWrap: true,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage[
                                                        'challengesummary'] !=
                                                    null)
                                            ? "${userLanguage['challengesummary']}"
                                            : "Challenge Summary",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage['activity'] !=
                                                    null)
                                            ? "${userLanguage['activity']}"
                                            : "Activity",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 50),
                                      child: Text(
                                        "Gwei Wagered",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Container(
                                                height: 32,
                                                width: 25,
                                                //color: blue1,
                                                child: Image.asset(
                                                  selecttype == "Walking"
                                                      ? "assets/images/walking.png"
                                                      : "assets/images/running.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                selecttype,
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       left: 185),
                                            //   child: ClipRRect(
                                            //     borderRadius:
                                            //         BorderRadius.circular(30),
                                            //     child: Container(
                                            //       height: 25,
                                            //       width: 25,
                                            //       color: blue1,
                                            //       child: IconButton(
                                            //           onPressed: () {},
                                            //           icon: Icon(
                                            //             Icons.check,
                                            //             color: Colors.white,
                                            //             size: 11,
                                            //           )),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                competitorsgets.toString(),
                                                style: GoogleFonts.montserrat(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Text(
                                              (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage['gwei'] !=
                                                          null)
                                                  ? "${userLanguage['sats']}"
                                                  : "Gwei",
                                              style: GoogleFonts.poppins(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Colors.orange,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: blue1,
                                                  child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.note_add_outlined,
                                                        color: Colors.white,
                                                        size: 12,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        "Start Date",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 90),
                                      child: Text(
                                        "End Date",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                today1,
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       left: 185),
                                            //   child: ClipRRect(
                                            //     borderRadius:
                                            //         BorderRadius.circular(30),
                                            //     child: Container(
                                            //       height: 25,
                                            //       width: 25,
                                            //       color: blue1,
                                            //       child: IconButton(
                                            //           onPressed: () {},
                                            //           icon: Icon(
                                            //             Icons.check,
                                            //             color: Colors.white,
                                            //             size: 11,
                                            //           )),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                expiryDate,
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Row(
                                //   children: [
                                //     Padding(
                                //       padding: const EdgeInsets.only(
                                //           top: 20, left: 25),
                                //       child: Text(
                                //         (lang.length != null &&
                                //                 lang.length != 0 &&
                                //                 userLanguage['satswagered'] !=
                                //                     null)
                                //             ? "${userLanguage['satswagered']}"
                                //             : "Gwei Wagered",
                                //         style: GoogleFonts.poppins(
                                //             decoration: TextDecoration.none,
                                //             color: Colors.grey,
                                //             fontSize: 15,
                                //             fontWeight: FontWeight.w400),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage[
                                                        'typesofchallenge'] !=
                                                    null)
                                            ? "${userLanguage['typesofchallenge']}"
                                            : "Type of Challenge",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Container(
                                                //color: blue1,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 32,
                                                      width: 25,
                                                      //color: blue1,
                                                      child: Image.asset(
                                                        "assets/images/streak.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        selecttype,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: blue1,
                                                  child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 11,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        "Number of Competitors ",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                wagar.toString(),
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: blue1,
                                                  child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.note_add_outlined,
                                                        color: Colors.white,
                                                        size: 12,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "WINNER GETS",
                                      style: GoogleFonts.poppins(
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      competitorsgets.toString(),
                                      style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.none,
                                          color: Colors.orange,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "GWEI",
                                      style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.none,
                                          color: Colors.orange,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                Container(
                                  height: 55,
                                  width:
                                      MediaQuery.of(context).size.height * 0.6,
                                  decoration: BoxDecoration(
                                    //color: Colors.amber,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  // ignore: deprecated_member_use
                                  child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        createChallenges();
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             ChallengeFinal()));
                                      },
                                      color: blue1,
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage[
                                                        'createchallenge'] !=
                                                    null)
                                            ? "${userLanguage['createchallenge']}"
                                            : "CREATE CHALLENGE",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )),
                                ),
                                // SizedBox(
                                //   height:
                                //       MediaQuery.of(context).size.height * 0.03,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //challangedetails screen start//
  void challangedetails(BuildContext context, detail) {
    // var newDateTimeObj2 = new DateFormat("dd/MM/yyyy HH:mm:ss").parse(detail.startDate);
    // print("dfghjkl $newDateTimeObj2");
    DateTime parseDate =
        new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(detail.startDate);
    var inputDate = DateTime.parse(parseDate.toString());
    var startDate = (DateFormat.yMMMd().format(inputDate)).toString();
    DateTime parseendDate =
        new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(detail.endDate);
    var endinputDate = DateTime.parse(parseendDate.toString());
    var endDate = (DateFormat.yMMMd().format(endinputDate)).toString();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: backgroundcolor.withOpacity(0.7),
                margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                child: Column(
                  //  shrinkWrap: true,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Card(
                          color: gridcolor,
                          elevation: 20,
                          // shadowColor: button.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                            // side: new BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: gridcolor),
                              child: Center(
                                child: Icon(Icons.arrow_back,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "LeaderBoard",
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.none,
                            height: 1,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        shadowColor: button.withOpacity(0.5),
                        color: Color(0xff1C203A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            child: Column(
                              // shrinkWrap: true,
                              children: [
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Padding(
                                //       padding: const EdgeInsets.only(
                                //           top: 20, left: 25),
                                //       child: Text(
                                //         (lang.length != null &&
                                //                 lang.length != 0 &&
                                //                 userLanguage[
                                //                         'challengesummary'] !=
                                //                     null)
                                //             ? "${userLanguage['challengesummary']}"
                                //             : "Challenge Summary",
                                //         style: GoogleFonts.poppins(
                                //             decoration: TextDecoration.none,
                                //             color: Colors.white,
                                //             fontSize: 25,
                                //             fontWeight: FontWeight.w600),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage['activity'] !=
                                                    null)
                                            ? "${userLanguage['activity']}"
                                            : "Activity",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 50),
                                      child: Text(
                                        "Gwei Wagered",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Container(
                                                height: 32,
                                                width: 25,
                                                //color: blue1,
                                                child: Image.asset(
                                                  detail.mode == "Walking"
                                                      ? "assets/images/walking.png"
                                                      : "assets/images/running.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                detail.mode,
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       left: 185),
                                            //   child: ClipRRect(
                                            //     borderRadius:
                                            //         BorderRadius.circular(30),
                                            //     child: Container(
                                            //       height: 25,
                                            //       width: 25,
                                            //       color: blue1,
                                            //       child: IconButton(
                                            //           onPressed: () {},
                                            //           icon: Icon(
                                            //             Icons.check,
                                            //             color: Colors.white,
                                            //             size: 11,
                                            //           )),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                detail.wage,
                                                style: GoogleFonts.montserrat(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Text(
                                              (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage['gwei'] !=
                                                          null)
                                                  ? "${userLanguage['sats']}"
                                                  : "Gwei",
                                              style: GoogleFonts.poppins(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Colors.orange,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: blue1,
                                                  child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.note_add_outlined,
                                                        color: Colors.white,
                                                        size: 12,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        "Start Date",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 90),
                                      child: Text(
                                        "End Date",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                startDate.toString(),
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       left: 185),
                                            //   child: ClipRRect(
                                            //     borderRadius:
                                            //         BorderRadius.circular(30),
                                            //     child: Container(
                                            //       height: 25,
                                            //       width: 25,
                                            //       color: blue1,
                                            //       child: IconButton(
                                            //           onPressed: () {},
                                            //           icon: Icon(
                                            //             Icons.check,
                                            //             color: Colors.white,
                                            //             size: 11,
                                            //           )),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                endDate.toString(),
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Row(
                                //   children: [
                                //     Padding(
                                //       padding: const EdgeInsets.only(
                                //           top: 20, left: 25),
                                //       child: Text(
                                //         (lang.length != null &&
                                //                 lang.length != 0 &&
                                //                 userLanguage['satswagered'] !=
                                //                     null)
                                //             ? "${userLanguage['satswagered']}"
                                //             : "Gwei Wagered",
                                //         style: GoogleFonts.poppins(
                                //             decoration: TextDecoration.none,
                                //             color: Colors.grey,
                                //             fontSize: 15,
                                //             fontWeight: FontWeight.w400),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage[
                                                        'typesofchallenge'] !=
                                                    null)
                                            ? "${userLanguage['typesofchallenge']}"
                                            : "Type of Challenge",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Container(
                                                //color: blue1,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 32,
                                                      width: 25,
                                                      //color: blue1,
                                                      child: Image.asset(
                                                        "assets/images/streak.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        detail.mode,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: blue1,
                                                  child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 11,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 25),
                                      child: Text(
                                        "Number of Competitors ",
                                        style: GoogleFonts.poppins(
                                            decoration: TextDecoration.none,
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 25),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            color: button,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                detail.totalCompetitors
                                                    .toString(),
                                                style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  color: blue1,
                                                  child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.note_add_outlined,
                                                        color: Colors.white,
                                                        size: 12,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "WINNER GETS",
                                      style: GoogleFonts.poppins(
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      (num.parse(detail.wage*10)).toString(),
                                      style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.none,
                                          color: Colors.orange,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "GWEI",
                                      style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.none,
                                          color: Colors.orange,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                // Container(
                                //   height: 55,
                                //   width:
                                //       MediaQuery.of(context).size.height * 0.6,
                                //   decoration: BoxDecoration(
                                //     //color: Colors.amber,
                                //     borderRadius: BorderRadius.circular(15),
                                //   ),
                                //   // ignore: deprecated_member_use
                                //   child: RaisedButton(
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(30),
                                //       ),
                                //       onPressed: () {
                                //         Navigator.pop(context);
                                //         createChallenges();
                                //         // Navigator.push(
                                //         //     context,
                                //         //     MaterialPageRoute(
                                //         //         builder: (context) =>
                                //         //             ChallengeFinal()));
                                //       },
                                //       color: blue1,
                                //       child: Text(
                                //         (lang.length != null &&
                                //                 lang.length != 0 &&
                                //                 userLanguage[
                                //                         'createchallenge'] !=
                                //                     null)
                                //             ? "${userLanguage['createchallenge']}"
                                //             : "CREATE CHALLENGE",
                                //         style: GoogleFonts.poppins(
                                //           color: Colors.white,
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.w600,
                                //         ),
                                //       )),
                                // ),
                                // SizedBox(
                                //   height:
                                //       MediaQuery.of(context).size.height * 0.03,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
//challange details screen end//

  void joinChallenge(BuildContext context, chall) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                color: backgroundcolor.withOpacity(0.4),
                margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Card(
                          color: gridcolor,
                          elevation: 20,
                          // shadowColor: button.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                            // side: new BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: gridcolor),
                              child: Center(
                                child: Icon(Icons.arrow_back,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        // Text(
                        //   (lang.length != null &&
                        //           lang.length != 0 &&
                        //           userLanguage['createachellenge'] != null)
                        //       ? "${userLanguage['createachellenge']}"
                        //       : "CREATE A \nCHALLENGE",
                        //   style: GoogleFonts.poppins(
                        //     decoration: TextDecoration.none,
                        //     height: 1,
                        //     color: Colors.white,
                        //     fontSize: 17,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.2,
                    // ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.85,
                      //color: Colors.red,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 140),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              width: MediaQuery.of(context).size.width * 0.85,
                              decoration: BoxDecoration(
                                color: backgroundcolor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 100),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage[
                                                      'areyousureyouwanttoenter'] !=
                                                  null)
                                          ? "${userLanguage['areyousureyouwanttoenter']}"
                                          : "Are you sure you \n  want to enter?",
                                      style: GoogleFonts.poppins(
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      //height: 36, width: 210,
                                      decoration: BoxDecoration(
                                        color: spr.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Text(
                                                  (lang.length != null &&
                                                          lang.length != 0 &&
                                                          userLanguage[
                                                                  'activity'] !=
                                                              null)
                                                      ? "${userLanguage['activity']}"
                                                      : "Activity: ",
                                                  style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: text1,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  chall.mode,
                                                  style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                Text(
                                                  (lang.length != null &&
                                                          lang.length != 0 &&
                                                          userLanguage[
                                                                  'type'] !=
                                                              null)
                                                      ? "${userLanguage['type']}"
                                                      : "Type: ",
                                                  style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: text1,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  chall.type,
                                                  style: GoogleFonts.poppins(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['wager'] != null)
                                          ? "${userLanguage['wager']}"
                                          : "WAGER",
                                      style: GoogleFonts.poppins(
                                        decoration: TextDecoration.none,
                                        color: text1,
                                        fontSize: 9,
                                        //fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      chall.totalCompetitors,
                                      style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['winnergets'] !=
                                                  null)
                                          ? "${userLanguage['winnergets']}"
                                          : "WINNER GETS",
                                      style: GoogleFonts.poppins(
                                        decoration: TextDecoration.none,
                                        color: text1,
                                        fontSize: 12,
                                        //fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${chall.wage} Gwei",
                                      style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.orange,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 55,
                                      width: 144,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      // ignore: deprecated_member_use
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            JoinChallenges(
                                              user[0]["uid"],
                                              chall.id,
                                            );
                                          },
                                          color: blue2,
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['confirm'] !=
                                                        null)
                                                ? "${userLanguage['confirm']}"
                                                : "Confirm",
                                            style: GoogleFonts.poppins(
                                              color: white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Tabscreen(
                                              index: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage['cancel'] != null)
                                            ? "${userLanguage['cancel']}"
                                            : "CANCEL",
                                        style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.none,
                                          color: blue2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: MediaQuery.of(context).size.width * 0.03,
                            child: Image.asset("assets/images/jc1.png"),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.055,
                            left: MediaQuery.of(context).size.width * 0.065,
                            child: Image.asset("assets/images/jc2.png"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void challengeAccepted(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: backgroundcolor.withOpacity(0.4),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 150,
                    ),
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width * 0.85,
                          //color: Colors.red,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 65),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  decoration: BoxDecoration(
                                    color: backgroundcolor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 75),
                                      Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage[
                                                        'challengeaccepted'] !=
                                                    null)
                                            ? "${userLanguage['challengeaccepted']}"
                                            : "Challenge \nAccepted!",
                                        style: GoogleFonts.poppins(
                                          height: 1,
                                          decoration: TextDecoration.none,
                                          color: white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 25),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: (lang.length != null &&
                                                        lang.length != 0 &&
                                                        userLanguage[
                                                                'youcantrackyourprogressinthischallengeandothersin'] !=
                                                            null)
                                                    ? "${userLanguage['youcantrackyourprogressinthischallengeandothersin']}"
                                                    : 'You can track your progress in this \nchallenge and others in',
                                                style: GoogleFonts.poppins(
                                                  color: text1,
                                                  fontSize: 12,
                                                  // fontWeight: FontWeight.w600,
                                                )),
                                            TextSpan(
                                                text: (lang.length != null &&
                                                        lang.length != 0 &&
                                                        userLanguage[
                                                                'myactivity'] !=
                                                            null)
                                                    ? "${userLanguage['myactivity']}"
                                                    : ' My Activity',
                                                style: GoogleFonts.poppins(
                                                  color: blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 25),
                                      Container(
                                        height: 55,
                                        width: 144,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        // ignore: deprecated_member_use
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => Tabscreen(
                                                    index: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            color: blue2,
                                            child: Text(
                                              (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage[
                                                              'viewchallenges'] !=
                                                          null)
                                                  ? "${userLanguage['viewchallenges']}"
                                                  : "View Challenges",
                                              style: GoogleFonts.poppins(
                                                color: white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => Tabscreen(
                                                index: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          (lang.length != null &&
                                                  lang.length != 0 &&
                                                  userLanguage['gohome'] !=
                                                      null)
                                              ? "${userLanguage['gohome']}"
                                              : "GO HOME",
                                          style: GoogleFonts.montserrat(
                                            decoration: TextDecoration.none,
                                            color: blue2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: MediaQuery.of(context).size.width * 0.2,
                          child: Image.asset("assets/images/jct.png"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  void leaderboardProfile(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent.withOpacity(0.5),
                margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                child: Column(
                  //  shrinkWrap: true,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Card(
                          color: gridcolor,
                          elevation: 20,
                          // shadowColor: button.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                            // side: new BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Tabscreen(
                                            index: 2,
                                          )));
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: gridcolor),
                              child: Center(
                                child: Icon(Icons.arrow_back,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          (lang.length != null &&
                                  lang.length != 0 &&
                                  userLanguage['createachellenge'] != null)
                              ? "${userLanguage['createachellenge']}"
                              : "ZONO'S PROFILE",
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            //color: Colors.orange,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.65,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xff1C203A),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Center(
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage[''] != null)
                                                ? "${userLanguage['']}"
                                                : "ZONO",
                                            style: GoogleFonts.poppins(
                                              decoration: TextDecoration.none,
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 25),
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage[
                                                            'recentwins'] !=
                                                        null)
                                                ? "${userLanguage['recentwins']}"
                                                : "RECENT WINS",
                                            style: GoogleFonts.poppins(
                                              decoration: TextDecoration.none,
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.17,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: Color(0xff313248),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              challengesOne.length == 0
                                                  ? Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "NO CHALLENGES",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              )),
                                                        ),
                                                      ),
                                                    )
                                                  : loading == true
                                                      ? Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.23,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          color:
                                                              backgroundcolor,
                                                          child: Center(
                                                            child:
                                                                SpinKitSpinningLines(
                                                              color: white,
                                                              size: 60,
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.14,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 0),
                                                          //color: Colors.indigo,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 4,
                                                                  top: 10,
                                                                  bottom: 0,
                                                                  right: 0),
                                                          child:
                                                              ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                challengesOne
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              print(
                                                                  "ChallengeOne Length :  ${challengesOne.length}");
                                                              return Material(
                                                                child: Stack(
                                                                  children: [
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.135,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.4,
                                                                      color: Color(
                                                                          0xff313248),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                MediaQuery.of(context).size.height * 0.1,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.35,
                                                                            // height: 126,
                                                                            // width: 130,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: joinChallengeColorList[index % joinChallengeColorList.length],
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                SizedBox(height: 20),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(
                                                                                      challengesOne[index].totalKm + "KM ",
                                                                                      style: GoogleFonts.poppins(
                                                                                        color: Colors.white,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      challengesOne[index].mode == "Walking" ? "WALK" : "RUN",
                                                                                      style: GoogleFonts.poppins(
                                                                                        color: Colors.white,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Text(
                                                                                  challengesOne[index].type.toUpperCase(),
                                                                                  style: GoogleFonts.poppins(
                                                                                    color: Colors.white,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0,
                                                                      left: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.13,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            43,
                                                                        width:
                                                                            43,
                                                                        //color: button,
                                                                        child: trophy[index %
                                                                            trophy.length],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 3,
                            left: MediaQuery.of(context).size.width * 0.4,
                            child: Container(
                              height: 85,
                              width: 85,
                              decoration: BoxDecoration(
                                  //color: white,
                                  borderRadius: BorderRadius.circular(40)),
                              child: Image.asset(
                                "assets/images/profile.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void startBetting(BuildContext context, chall) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          (lang.length != null &&
                                  lang.length != 0 &&
                                  userLanguage['betsats'] != null)
                              ? "${userLanguage['betsats']}"
                              : "BET SATS",
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: Container(
                        height: 200,
                        width: 200,
                        child: Image.asset("assets/images/toyface.png",
                            fit: BoxFit.cover)),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: 467,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Container(
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: text1,
                                    borderRadius: BorderRadius.circular(15))),
                            SizedBox(
                              height: 20,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['startbetting'] != null)
                                      ? "${userLanguage['startbetting']}"
                                      : 'Start betting',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  )),
                              TextSpan(
                                  text: (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['gwei'] != null)
                                      ? "${userLanguage['gwei']}"
                                      : ' Gwei ',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.orange,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ])),
                            // SizedBox(
                            //   height: 20,
                            // ),
                            Text(
                              (lang.length != null &&
                                      lang.length != 0 &&
                                      userLanguage[
                                              'bettingisaseasyasabracadabrajustconnectyourfitnesstrackertobegin'] !=
                                          null)
                                  ? "${userLanguage['bettingisaseasyasabracadabrajustconnectyourfitnesstrackertobegin']}"
                                  : "Betting is as easy as abracadabra, just\n  connect your fitness tracker to begin",
                              style: GoogleFonts.poppins(
                                decoration: TextDecoration.none,
                                color: text1,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width * 0.6,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: button,
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState() {
                                    googlefitint = false;
                                  }

                                  fetchData();
                                  // joinChallenge(context, chall);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => HealthKit()));
                                },
                                child: Row(
                                  children: [
                                    Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: white,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Image.asset(
                                          "assets/images/gfit.png",
                                        )),
                                    SizedBox(width: 20),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['googlefit'] != null)
                                          ? "${userLanguage['googlefit']}"
                                          : "GOOGLE FIT",
                                      style: GoogleFonts.poppins(
                                        //color: blue1,
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Container(
                            //   height: 55,
                            //   width: MediaQuery.of(context).size.width * 0.6,
                            //   // ignore: deprecated_member_use
                            //   child: RaisedButton(
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(30),
                            //     ),
                            //     color: button,
                            //     onPressed: () {},
                            //     child: Row(
                            //       children: [
                            //         Container(
                            //             height: 50,
                            //             width: 50,
                            //             decoration: BoxDecoration(
                            //                 color:
                            //                     healthkitPink.withOpacity(0.4),
                            //                 borderRadius:
                            //                     BorderRadius.circular(30)),
                            //             child: Image.asset(
                            //               "assets/images/ahkit.png",
                            //             )),
                            //         SizedBox(width: 20),
                            //         Text(
                            //           (lang.length != null &&
                            //                   lang.length != 0 &&
                            //                   userLanguage['applehealthkit'] !=
                            //                       null)
                            //               ? "${userLanguage['applehealthkit']}"
                            //               : "APPLE HEALTH KIT",
                            //           style: GoogleFonts.poppins(
                            //             //color: blue1,
                            //             color: Colors.white,
                            //             fontSize: 14,
                            //             fontWeight: FontWeight.w600,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 25),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                bettingGuide(context);
                              },
                              child: Text(
                                (lang.length != null &&
                                        lang.length != 0 &&
                                        userLanguage['howdoesthiswork'] != null)
                                    ? "${userLanguage['howdoesthiswork']}"
                                    : "How does this work?",
                                style: GoogleFonts.poppins(
                                  color: blue2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void bettingGuide(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: backgroundcolor.withOpacity(0.7),
              margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        color: gridcolor,
                        elevation: 20,
                        // shadowColor: button.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                          // side: new BorderSide(color: Colors.black, width: 1.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: gridcolor),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          (lang.length != null &&
                                  lang.length != 0 &&
                                  userLanguage['betsats'] != null)
                              ? "${userLanguage['betsats']}"
                              : "BET SATS",
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shadowColor: button.withOpacity(0.5),
                      color: Color(0xff1C203A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            Container(
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: spr,
                                    borderRadius: BorderRadius.circular(15))),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.19,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                color: grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    //color: blue1,
                                    child: Image.asset(
                                      "assets/images/betTrophy.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    (lang.length != null &&
                                            lang.length != 0 &&
                                            userLanguage['step'] != null)
                                        ? "${userLanguage['step']}"
                                        : "Step 1",
                                    style: GoogleFonts.poppins(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      color: white,
                                    ),
                                  ),
                                  Text(
                                    (lang.length != null &&
                                            lang.length != 0 &&
                                            userLanguage[
                                                    'joinormakeachallengewithgwei'] !=
                                                null)
                                        ? "${userLanguage['joinormakeachallengewithgwei']}"
                                        : "Join or make a challenge with GWEI",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.19,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                color: grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    //color: blue1,
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          "assets/images/betRunboy.png",
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          left: 10,
                                          child: Image.asset(
                                            "assets/images/betRungirl.png",
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (lang.length != null &&
                                            lang.length != 0 &&
                                            userLanguage['step'] != null)
                                        ? "${userLanguage['step']}"
                                        : "Step 2",
                                    style: GoogleFonts.poppins(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      color: white,
                                    ),
                                  ),
                                  Text(
                                    (lang.length != null &&
                                            lang.length != 0 &&
                                            userLanguage[
                                                    'completeawalkorrunchallenge'] !=
                                                null)
                                        ? "${userLanguage['completeawalkorrunchallenge']}"
                                        : "Complete a walk or run challenge",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                notEnoughBalance(context);
                              },
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.19,
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: grey,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    Container(
                                      height: 50,
                                      width: 50,
                                      //color: blue1,
                                      child: Image.asset(
                                        "assets/images/spendingcoin.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['step'] != null)
                                          ? "${userLanguage['step']}"
                                          : "Step 3",
                                      style: GoogleFonts.poppins(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        color: white,
                                      ),
                                    ),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage['winandgetpaid'] !=
                                                  null)
                                          ? "${userLanguage['winandgetpaid']}"
                                          : "Win and get paid!",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: white,
                                      ),
                                    ),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage[
                                                      'orloseandtryagain)'] !=
                                                  null)
                                          ? "${userLanguage['orloseandtryagain']}"
                                          : "(Or lose and try again!)",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 30,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void notEnoughBalance(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                color: backgroundcolor.withOpacity(0.4),
                margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Card(
                          color: gridcolor,
                          elevation: 20,
                          // shadowColor: button.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                            // side: new BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Tabscreen(
                                    index: 2,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: gridcolor),
                              child: Center(
                                child: Icon(Icons.arrow_back,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.85,
                      //color: Colors.red,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 140),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.width * 0.85,
                              decoration: BoxDecoration(
                                color: backgroundcolor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.14),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage[
                                                              'sorryyoudonthaveenough'] !=
                                                          null)
                                                  ? "${userLanguage['sorryyoudonthaveenough']}"
                                                  : '   Sorry, you don’t \nhave enough',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          TextSpan(
                                              text: (lang.length != null &&
                                                      lang.length != 0 &&
                                                      userLanguage['sats'] !=
                                                          null)
                                                  ? "${userLanguage['sats']}"
                                                  : ' Gwei ',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.orange,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w700,
                                              )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    Text(
                                      (lang.length != null &&
                                              lang.length != 0 &&
                                              userLanguage[
                                                      'eitherkeepmakingpurchasesordepositfundsintoyourwallet'] !=
                                                  null)
                                          ? "${userLanguage['eitherkeepmakingpurchasesordepositfundsintoyourwallet']}"
                                          : "Either keep making purchases or   \ndeposit funds into your wallet!",
                                      style: GoogleFonts.poppins(
                                        color: text1,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    Container(
                                      height: 55,
                                      width: 144,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      // ignore: deprecated_member_use
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          onPressed: () {},
                                          color: blue2,
                                          child: Text(
                                            (lang.length != null &&
                                                    lang.length != 0 &&
                                                    userLanguage['deposit'] !=
                                                        null)
                                                ? "${userLanguage['deposit']}"
                                                : "Deposit",
                                            style: GoogleFonts.poppins(
                                              color: white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Tabscreen(
                                              index: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        (lang.length != null &&
                                                lang.length != 0 &&
                                                userLanguage['goback'] != null)
                                            ? "${userLanguage['cancel']}"
                                            : "Go BACK",
                                        style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.none,
                                          color: blue2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: MediaQuery.of(context).size.width * 0.04,
                            child: Image.asset("assets/images/notEnough1.png"),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0,
                            left: MediaQuery.of(context).size.width * 0.04,
                            child: Image.asset("assets/images/notEnough.png"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    var blue = Color(0xFF282C4A);
    var orange = Color(0xFFFF8C00);
    var nonlabel = Color(0xFF808DA7);
    //horizontal
    return Container(
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text("${data[index]}",
                textScaleFactor: 1.0,
                style: GoogleFonts.poppins(
                    color: _focusedIndex == index ? orange : nonlabel,
                    fontWeight: _focusedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: _focusedIndex == index ? 25 : 20)),
          ),
          Container(
            margin: EdgeInsets.only(left: 3, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 60,
                  width: 2,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 7),
                  height: 40,
                  width: 1,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Day {}
