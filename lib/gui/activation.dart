import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weareforyou/gui/register.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';

class Activation extends StatefulWidget{
  Activation(this.theFullName,this.theEmailAddress,this.theMobileNumber,this.thePassword,this.cityId,this.mytoken,this.activationCode,{Key? key}): super(key: key);
  String theFullName;
  String theEmailAddress;
  String theMobileNumber;
  String thePassword;
  String cityId;
  String mytoken;
  String activationCode;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ActivationState(theFullName,theEmailAddress,theMobileNumber,thePassword,cityId,mytoken,activationCode);
  }

}

class _ActivationState extends State<Activation>{
  _ActivationState(this.theFullName,this.theEmailAddress,this.theMobileNumber,this.thePassword,this.cityId,this.mytoken,this.activationCode);
  String theFullName;
  String theEmailAddress;
  String theMobileNumber;
  String thePassword;
  String cityId = '0';
  String mytoken;
  String activationCode;

  final TextEditingController _getActivationCode = TextEditingController();
  late String theLanguage;
  late TextAlign theAlignment;

  late Timer _timer;
  int _start = 240;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    startTimer();
    getSharedData();

  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
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



  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
            if(_start == 0){
              setState(() {
                activationCode = 'osamaOSR';
              });
            }
          }
        },
      ),
    );
  }

  void _sendActiveCode(String activationCode){
    styles.onLoading(context);
    var myUrl = Uri.parse(funcs.mainLink+'api/sendActivationCode');
    http.post(myUrl, body: {
      "activationCode" : activationCode,
      "theEmailAddress": theEmailAddress,
    }).then((result) async{
      if(result.body.toString() == 'true'){
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      Navigator.of(context, rootNavigator: true).pop();
    });

  }
  
  void _regenerateActivationCode(){
    setState(() {
      activationCode = funcs.generateActivationCode();
      _sendActiveCode(activationCode);
      print(activationCode);
      _start = 240;
      _getActivationCode.text = '';
    });
    startTimer();
  }
  
  void _register_member() async{

    String enteredActivationCode = _getActivationCode.text.trim();
    if(enteredActivationCode == activationCode && int.parse(activationCode) > 0 ){

      styles.onLoading(context);

      print(cityId);
      var myUrl = Uri.parse(funcs.mainLink+'api/register_member');
      http.post(myUrl, body: {
        "fullName" : theFullName,
        "emailAddress": theEmailAddress,
        "mobileNumber": theMobileNumber,
        "thePassword": thePassword,
        "theLanguage": theLanguage,
        "fcmToken": mytoken,
        "cityId" : cityId
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

        }else if(theResult['resultFlag'] == 'duplicate'){
          Navigator.of(context, rootNavigator: true).pop();
        }else{
          styles.showSnackBar(context, context.localeString('error_occurred'),'error','forget_password');
          Navigator.of(context, rootNavigator: true).pop();
        }
      }).catchError((error) {
        print(error);
        styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      });


    }else{
      styles.showSnackBar(context,context.localeString('activation_code_not_correct'),'error','');
    }

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
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
              child: GestureDetector(
                onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(height: 20.0,),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => Register()),),
                              icon: const Icon(Icons.arrow_back_ios),
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
                      Text(context.localeString('activation_code_title'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25.0), textAlign: TextAlign.center),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                        child: Text(context.localeString('activation_sent_to') + ' ' + theEmailAddress, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15.0), textAlign: TextAlign.center),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
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
                          child: Column(
                            children: <Widget>[
                              const Padding(padding: EdgeInsets.only(top: 30.0)),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
                                child: Text(_start.toString() + ' sec', style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 17.0),),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return context.localeString('field_is_empty').toString();
                                    }else if(value.length < 5) {
                                      return context.localeString('number_must_be_five').toString();
                                    }
                                    return null;
                                  },
                                  autocorrect: false,
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                                    hintText: context.localeString('enter_activation_code').toString(), hintStyle:  const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                                    fillColor: Colors.white70,
                                    filled: true,
                                  ),
                                  controller: _getActivationCode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  maxLines: null,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                                child: GestureDetector(
                                  onTap: (){
                                    if (_formKey.currentState!.validate()) {
                                      _register_member();
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: styles.primaryButton(context),
                                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                                    margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                                    child: Text(context.localeString('register_btn'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 30.0)),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: _start == 0 ? Container(
        height: 50.0,
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: GestureDetector(
          onTap: ()=> _regenerateActivationCode(),
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(context.localeString('resend_activation_code'), style: styles.startBtn,),
          ),
        ),
      ):Container(height: 0.0,),
    );
  }

}