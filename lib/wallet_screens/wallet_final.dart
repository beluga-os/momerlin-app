import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:momerlin/data/localstorage/userdata_source.dart';
import 'package:momerlin/theme/theme.dart';
import 'package:momerlin/wallet_screens/wallet_send.dart';
import 'package:momerlin/walletcreation.dart/wallethome.dart';

class WalletFinal extends StatefulWidget {
  const WalletFinal({Key key}) : super(key: key);

  @override
  _WalletFinalState createState() => _WalletFinalState();
}

class _WalletFinalState extends State<WalletFinal> {
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
          padding: const EdgeInsets.all(8.0),
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
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.55,
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
                                  userLanguage['justlikemagicyourealldone'] !=
                                      null)
                              ? "${userLanguage['justlikemagicyourealldone']}"
                              : "Just like magic,\nyou’re all done!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
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
                                  userLanguage[
                                          'thoughitmaytakeourmagicminstoreachyourdestination'] !=
                                      null)
                              ? "${userLanguage['thoughitmaytakeourmagicminstoreachyourdestination']}"
                              : "(Though it may take our magic 5-10 mins    \nto reach your destination)",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.grey,
                              letterSpacing: 1,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletSend()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.08,
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
                                          userLanguage['sendmore'] != null)
                                      ? "${userLanguage['sendmore']}"
                                      : "SEND MORE",
                                  style: GoogleFonts.poppins(
                                      color: white,
                                      letterSpacing: 1,
                                      fontSize: 15,
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
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletHomePage()));
                          },
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
                                          userLanguage['gohome'] != null)
                                      ? "${userLanguage['gohome']}"
                                      : "GO HOME",
                                  style: GoogleFonts.poppins(
                                      color: white,
                                      letterSpacing: 1,
                                      fontSize: 15,
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
                  left: 100,
                  child: Image.asset("assets/images/final.png"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}