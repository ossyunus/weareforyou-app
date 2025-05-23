import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weareforyou/gui/forget_password.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/gui/widgets/animated_image.dart';

class Login extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }

}

class _LoginState extends State<Login>{

  final TextEditingController _getEmailAddress = TextEditingController();
  final TextEditingController _getPassword = TextEditingController();
  late String theLanguage;
  late TextAlign theAlignment;
  String mytoken = '';

  var funcs = Funcs();
  var styles = Styles();

  bool _isObscure = true;

  late FirebaseMessaging messaging;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  
  @override
  void initState(){
    super.initState();

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
      setState(() {
        mytoken = value.toString();
      });
    });

    getSharedData();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
      }else{
        theAlignment = TextAlign.left;
      }

    });
  }


  void _login() async{

    styles.onLoading(context);

    String theEmailAddress =  _getEmailAddress.text.trim();
    String thePassword =  _getPassword.text.trim();

    var myUrl = Uri.parse('${funcs.mainLink}api/loginMember');
    http.post(myUrl, body: {
      "emailAddress": theEmailAddress,
      "password": thePassword,
      "mytoken": mytoken,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 'done'){

        Navigator.of(context, rootNavigator: true).pop();
        String memberId = theResult['theResult'][0]['meId'];
        String fullName = theResult['theResult'][0]['fullName'];
        String emailAddress = theResult['theResult'][0]['emailAddress'];
        String mobileNumber = theResult['theResult'][0]['mobileNumber'];


        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('memberId', memberId);
        await prefs.setString('fullName', fullName);
        await prefs.setString('emailAddress', emailAddress);
        await prefs.setString('mobileNumber', mobileNumber);
        await prefs.setString('theLanguage', theLanguage);
        await prefs.setBool('isLogin', true);

        Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);

      }else if(theResult['resultFlag'] == 'not_found'){
        styles.showSnackBar(context, context.localeString('check_login_information').toString(),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void enterAsGuest(){
    Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.luminosity),
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
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0, top:50.0, right: 15.0),
                    ),
                    AnimatedImage('images/logo.png',160),
                    const Padding(padding: EdgeInsets.only(top: 10.0)),
                    Card(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
                      elevation: 5,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30)),
                          side: BorderSide(width: 1, color: Colors.white24)
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Column(
                          children: [
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                            Text(context.localeString('login_page_title'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 19.0), textAlign: TextAlign.center),
                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                              child: TextFormField(
                                validator: (value) {
                                  Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = RegExp(pattern.toString());
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(!regex.hasMatch(value.trim())) {
                                    return context.localeString('enter_valid_email').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                  prefixIcon: const Icon(Icons.email, color: Colors.black54),
                                  hintText: context.localeString('email_address').toString(), hintStyle:  styles.inputTextHintStyle,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                ),
                                controller: _getEmailAddress,
                                keyboardType: TextInputType.emailAddress,
                                maxLines: null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localeString('field_is_empty').toString();
                                  }else if(value.length < 6) {
                                    return context.localeString('password_must_more_six').toString();
                                  }
                                  return null;
                                },
                                autocorrect: false,
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                  prefixIcon: const Icon(Icons.lock, color: Colors.black54,),
                                  hintText: context.localeString('password').toString(), hintStyle:  styles.inputTextHintStyle,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                          _isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.black54,),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      }),
                                ),
                                controller: _getPassword,
                                obscureText: _isObscure,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                              child: GestureDetector(
                                onTap: (){
                                  _login();
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: styles.primaryButton(context),
                                  padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                                  margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                                  child: Text(context.localeString('login_btn'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                            child: GestureDetector(
                              child: Text(context.localeString('do_not_have_account'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0), textAlign: TextAlign.center),
                              onTap: ()=> Navigator.of(context).pushNamedAndRemoveUntil('/Register',(Route<dynamic> route) => false),
                            )
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                            child: GestureDetector(
                                child: Text(context.localeString('forget_password'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0), textAlign: TextAlign.center),
                                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()),)
                            )
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 20.0)),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}