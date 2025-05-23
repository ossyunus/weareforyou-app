import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/gui/edit_profile.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';

class Settings extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsState();
  }

}

class _SettingsState extends State<Settings>{
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late String theLanguage = '';
  bool isLogin = false;
  late String fullName = '';
  late String memberId = '0';

  late String emailAddress = '';
  late String mobileNumber = '';

  late TextAlign theAlignment = TextAlign.right;
  late TextDirection theDirection;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData();

    print(theLanguage);
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;
        memberId = prefs.getString('memberId')!;
        fullName = prefs.getString('fullName')!;
        emailAddress = prefs.getString('emailAddress')!;
        mobileNumber = prefs.getString('mobileNumber')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          theDirection = TextDirection.rtl;
        }else{
          theAlignment = TextAlign.left;
          theDirection = TextDirection.ltr;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, false, theLanguage, context.localeString('my_profile'), true),
      body: ListView(
        children: <Widget>[

          isLogin == true ? ListTile(
            title: Text(context.localeString('personal_information'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 17.0), textAlign: theAlignment),
          ):Container(),

          isLogin == true ? Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: [
                Column(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          Text('${context.localeString('email_address')}: '),
                          Expanded(
                            child: Text(emailAddress, style: styles.listTileStyle, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    ListTile(
                      title: Row(
                        children: [
                          Text('${context.localeString('mobile_number')}: '),
                          Expanded(
                            child: Text(mobileNumber, style: styles.listTileStyle, textDirection: TextDirection.ltr, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      title: Row(
                        children: [
                          Text('${context.localeString('password')}: '),
                          Expanded(
                            child: Text('************', style: styles.listTileNoDataStyle, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      title:                               Container(
                        padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()),);
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: styles.primaryButton(context),
                            padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                            margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: Text(context.localeString('edit_profile'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                  ],
                ),
              ],
            ),
          ): Container(),

          const SizedBox(height: 30.0,),

        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(0),
    );
  }

}