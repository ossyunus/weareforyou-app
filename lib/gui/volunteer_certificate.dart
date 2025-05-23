import 'package:flutter/material.dart';
import 'package:weareforyou/components/styles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/module/get_data.dart';
import 'package:weareforyou/module/get_certificates.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VolunteerCertificate extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VolunteerCertificateState();
  }

}

class _VolunteerCertificateState extends State<VolunteerCertificate>{

  late String theLanguage = '';
  bool isLogin = false;
  late String fullName = '';
  late String memberId = '0';

  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();


  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {

    });
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;
        memberId = prefs.getString('memberId')!;
        fullName = prefs.getString('fullName')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, false, theLanguage, context.localeString('volunteer_certificate'), true),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child:          GestureDetector(
          onTap: () async{
            funcs.openLink('${funcs.mainLink}certificate/volunteer/$memberId/','link_without','');
          },
          child: Container(
            padding: const EdgeInsets.all(13.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Color.fromRGBO(235, 235, 235, 1),),
              ),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.solidFilePdf, color: Colors.red,),
                const SizedBox(width: 10.0,),
                Expanded(
                  child: Text(context.localeString('volunteer_certificate'), style: styles.nameTitle,),
                ),
                const FaIcon(FontAwesomeIcons.download, color: Colors.green,),
              ],
            ),

          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(0),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}