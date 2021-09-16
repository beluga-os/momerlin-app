import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:momerlin/data/localstorage/userdata_source.dart';
import 'package:momerlin/theme/theme.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoins/bitcoins.dart' as bitcoins;
import 'package:momerlin/walletcreation.dart/walletseed1.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WalletSeedPage extends StatefulWidget {
  @override
  _WalletSeedPage createState() => _WalletSeedPage();
}

class _WalletSeedPage extends State<WalletSeedPage> {
  var userLanguage, lang = [];

  var seed1, seed;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    loading = false;
    createaddress();
    getUserLanguage();
  }

  // ignore: todo
  //TODO :languagestart
  Future<void> getUserLanguage() async {
    lang = await UserDataSource().getLanguage();
    if (lang.length != null && lang.length != 0) {
      userLanguage = lang[0];
    }
  }

  // ignore: todo
  //TODO: LanguageEnd

// ignore: todo

//TODO: seed & address creation
  void createaddress() async {
    // loading = false;
    seed = bip39.generateMnemonic();

    var walletMain = bitcoins.WalletBTC(
        seed: bitcoins.mnemonicToSeed(seed), net: bitcoins.mainnet);
    print(walletMain.getAddress(0));
    var walletTest = bitcoins.WalletBTC(
        seed: bitcoins.mnemonicToSeed(seed), net: bitcoins.testnet3);
    print(walletTest.getAddress(0));
    var seed2 = seed.split(" ");

    seed1 = seed2;
    loading = true;
  }
// ignore: todo
//TODO: seed & address end

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Scaffold(
            backgroundColor: backgroundcolor,
            appBar: AppBar(
              backgroundColor: backgroundcolor,
              leading: Container(
                padding: EdgeInsets.all(5),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50), color: button),
                    child: Icon(
                      Icons.arrow_back,
                      color: white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Spacer(),
                  Image.asset("assets/images/MOMERLIN.png"),
                  Spacer(),
                  LinearPercentIndicator(
                    width: 102.0,
                    lineHeight: 25.0,
                    percent: 0.1,
                    center: Text(
                      "10%",
                      style: GoogleFonts.poppins(
                          color: white,
                          letterSpacing: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    // trailing: Icon(Icons.mood),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    backgroundColor: Colors.grey,
                    progressColor: blue,
                  ),
                ],
              ),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //       image: AssetImage(
              //         "asstes/images/seed.png",
              //       ),
              //       fit: BoxFit.fill),
              // ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Text(
                      (lang.length != null &&
                              lang.length != 0 &&
                              userLanguage['writedownthesewordsinorder'] !=
                                  null)
                          ? "${userLanguage['writedownthesewordsinorder']}"
                          : "Write down these 12 words in order",
                      style: GoogleFonts.poppins(
                          color: white,
                          letterSpacing: 1,
                          fontSize: 30,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      (lang.length != null &&
                              lang.length != 0 &&
                              userLanguage['recoverykey'] != null)
                          ? "${userLanguage['recoverykey']}"
                          : "This is your recovery key - you’ll need it if you ever need to recover your account",
                      style: GoogleFonts.poppins(
                          color: white,
                          letterSpacing: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: seed1.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 20),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: blue),
                          child: Center(
                            child: Text(
                              seed1[index],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: white,
                                  letterSpacing: 1,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => WalletSeedCheckPage(seed1)));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: blue),
                        child: Center(
                          child: Text(
                            (lang.length != null &&
                                    lang.length != 0 &&
                                    userLanguage['ihavewrittenthemdown'] !=
                                        null)
                                ? "${userLanguage['ihavewrittenthemdown']}"
                                : "I’VE WRITTEN THEM DOWN",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: white,
                                letterSpacing: 1,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: AwesomeLoader(
              loaderType: AwesomeLoader.AwesomeLoader3,
              color: backgroundcolor,
            ),
          );
  }
}