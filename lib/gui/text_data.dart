import 'package:flutter/material.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_locales/flutter_locales.dart';

class TextData extends StatefulWidget{
  TextData(this.theType);
  String theType;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TextDataState(theType);
  }

}

class _TextDataState extends State<TextData> {
  _TextDataState(this.theType);
  String theType;
  late String theLanguage = '';
  bool isLogin = false;
  late String memberId = '0';
  late String fullName = '';

  String textdataTitle = '';
  String textdataText = '';
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

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
    var myUrl = Uri.parse('${funcs.mainLink}api/textdata/$theType/$theLanguage');
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

  copyIban(){

  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, isLoading, theLanguage, textdataTitle, true),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
          HtmlWidget(textdataText, textStyle: const TextStyle(color: Colors.black87, fontSize: 16),),
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
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
      ):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}
