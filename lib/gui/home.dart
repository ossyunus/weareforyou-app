import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/styles.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }

}



class _HomeState extends State<Home>{

  var styles = Styles();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }


  void _goToPage(String theType,  String theLanguage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theLanguage', theLanguage);
    await prefs.setString('memberId', '0');
    await prefs.setString('fullName', '');
    await prefs.setString('emailAddress', '');
    await prefs.setString('mobileNumber', '');
    await prefs.setBool('isLogin', false);

    Locales.currentLocale(context);

    Locales.change(context, theLanguage);

    if(theType == 'login'){
      Navigator.of(context).pushNamedAndRemoveUntil('/Login',(Route<dynamic> route) => false);
    }else if(theType == 'register'){
      Navigator.of(context).pushNamedAndRemoveUntil('/Register',(Route<dynamic> route) => false);
    }else{
      Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.luminosity),
                image: const AssetImage('images/blue_bg.jpg'), fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 0.0,
                  sigmaY: 0.0,
                ),
                child: Container(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'images/logo.png',
                          width: 180.0,
                        ),
                      ),
//                      SizedBox(height: 30.0,),

                      Container(
                        padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 50.0),
                        child: GestureDetector(
                          onTap: (){
                            _goToPage('login','ar');
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: styles.primaryButton(context),
                            padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                            margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: Text(context.localeString('login_page_title'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                        child: GestureDetector(
                          onTap: (){
                            _goToPage('register','ar');
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: styles.primaryButton(context),
                            padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                            margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: Text(context.localeString('do_not_have_account'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                        child: GestureDetector(
                          onTap: (){
                            _goToPage('guest','ar');
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: styles.primaryButton(context),
                            padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                            margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: Text(context.localeString('enter_as_guest'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                          ),
                        ),
                      ),

                    ],

                  ),
                )
            ),
          ),

        ],
      ),

    );
  }

}