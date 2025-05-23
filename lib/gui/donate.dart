import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter/services.dart';
import 'package:weareforyou/gui/donate_form.dart';

class Donate extends StatefulWidget{
  Donate(this.theType);
  String theType;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DonateState(theType);
  }

}

class _DonateState extends State<Donate> {
  _DonateState(this.theType);
  String theType;
  late String theLanguage = '';
  bool isLogin = false;
  late String memberId = '0';
  late String fullName = '';

  String textdataTitle = '';
  String textdataText = '';
  String iban = '';
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getTextData().then((result) {
        setState(() {
          textdataTitle = result['textData'][0]['theTitle'];
          textdataText = result['textData'][0]['theDetails'];
          iban = result['textData'][0]['copyValue'];
        });
      });
    });
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      isLogin = prefs.getBool('isLogin')!;
      memberId = prefs.getString('memberId')!;
      fullName = prefs.getString('fullName')!;
      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }
    });
  }

  Future<Map> getTextData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/textdata/$theType/$theLanguage');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
      print(e);
    }
    return result;
  }

  copyIban(String theCode){
    Clipboard.setData(ClipboardData(text: theCode));
    styles.showSnackBar(context,context.localeString('iban_copied'),'','');
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, isLoading, theLanguage, textdataTitle, true),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
          HtmlWidget(textdataText, textStyle: const TextStyle(color: Colors.black87, fontSize: 16),),
          Container(
            padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 0.0),
            child: GestureDetector(
              onTap: (){
                copyIban(iban);
              },
              child: Container(
                width: double.infinity,
                decoration: styles.primaryButton(context),
                padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                child: Text(context.localeString('copy_iban'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              ),
            ),
          ),
          const SizedBox(height: 20.0,),
          Container(
            padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, anotherAnimation){
                    return DonateForm();
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {

                    return FadeTransition(
                      opacity:animation,
                      child: child,
                    );
                  },
                ));
              },
              child: Container(
                width: double.infinity,
                decoration: styles.primaryButton(context),
                padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                child: Text(context.localeString('touch_with_you'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              ),
            ),
          ),
//          SelectableLinkify(
//              style: Theme.of(context).textTheme.bodyMedium, textAlign: theAlignment,
//              onOpen: styles.onOpenLink,
////              textScaleFactor: 4,
//              textDirection: TextDirection.ltr,
//              text: textdataText,
//          ),
          const SizedBox(height: 50.0,),
        ],
      ),
      floatingActionButton: isLoading == true ? FloatingActionButton(
        onPressed: ()=> null,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
        backgroundColor: Colors.white,
      ):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}
