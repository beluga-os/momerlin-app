import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:momerlin/data/localstorage/userdata_source.dart';
import 'package:momerlin/theme/theme.dart';
import 'package:momerlin/wallet_screens/wallet_challenges.dart';

class ChallengeFinal extends StatefulWidget {
  const ChallengeFinal({Key key}) : super(key: key);

  @override
  _ChallengeFinalState createState() => _ChallengeFinalState();
}

class _ChallengeFinalState extends State<ChallengeFinal> {
  var userLanguage, lang = [];
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // padding: EdgeInsets.only(left: 20, right: 20, top: 270),
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 100),
                  child: Container(
                    width: 325,
                    height: 367,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: button,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Text(
                          (lang.length != null &&
                                  lang.length != 0 &&
                                  userLanguage['letthechallengebegin'] != null)
                              ? "${userLanguage['letthechallengebegin']}"
                              : "Challenge \nCreated!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 30,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          (lang.length != null &&
                                  lang.length != 0 &&
                                  userLanguage['letthechallengebegin'] != null)
                              ? "${userLanguage['letthechallengebegin']}"
                              : "May the odds be ever in your favour!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: text1,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletChallenges()));
                          },
                          child: Container(
                            width: 245,
                            height: 50,
                            padding: EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: blue1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['gohome'] != null)
                                      ? "${userLanguage['gohome']}"
                                      : "GO HOME",
                                  style: GoogleFonts.poppins(
                                      color: white,
                                      letterSpacing: 1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                              // ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.05,
                            padding: EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (lang.length != null &&
                                          lang.length != 0 &&
                                          userLanguage['createanother'] != null)
                                      ? "${userLanguage['createanother']}"
                                      : "CREATE ANOTHER",
                                  style: GoogleFonts.poppins(
                                      color: white,
                                      letterSpacing: 1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                              // ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 130,
                  top: 65,
                  child: Image.asset("assets/images/chellenge.png"),
                  //child: SvgPicture.asset("assets/images/challenge_final.svg"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
