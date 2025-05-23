import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/gui/login.dart';
import 'package:weareforyou/gui/activation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:weareforyou/gui/text_data.dart';

class Register extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _RegisterState();
  }

}

class _RegisterState extends State<Register>{

  final TextEditingController _getFullName = TextEditingController();
  final TextEditingController _getEmailAddress = TextEditingController();
  final TextEditingController _getMobileNumber = TextEditingController();
  final TextEditingController _getPassword = TextEditingController();
  late String theLanguage;
  late TextAlign theAlignment;
  String mytoken = '';
  late bool isLoading = false;

  String countryId = '113';
  List<DropdownMenuItem<String>> citiesList = [];
  String cityId = '0';
  bool _isObscure = true;

  var funcs = Funcs();
  var styles = Styles();

  var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });

  late FirebaseMessaging messaging;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState(){
    super.initState();

    getSharedData().then((result) {
      getCities();
    });

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
      setState(() {
        mytoken = value.toString();
      });
    });



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

  void getCities() async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse('${funcs.mainLink}api/getCitiesByCountry/$theLanguage/$countryId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    citiesList.add(DropdownMenuItem(
      value: '0',
      child: SizedBox(
        width: double.infinity,
        child: Text(context.localeString('please_select_city'), style: styles.inputTextStyle, textAlign: TextAlign.center),
      ),
    ));


    try{
      setState(() {
        isLoading = false;
      });
      var responseData = json.decode(response.body);
      responseData.forEach((cities){
        citiesList.add(DropdownMenuItem(
          value: "${cities['ciId']}",
          child: SizedBox(
            width: double.infinity,
            child: Text(cities['theTitle'], style: styles.inputTextStyle,textAlign: TextAlign.center),
          ),
        ));
      },
      );
    }catch(e){
      print(e);
    }

  }

  _changeCity(String e){
    setState(() {
      cityId = e;
    });
  }

//  void _sendActiveCode(){
//    styles.onLoading(context);
//
//    String theFullName =  _getFullName.text.trim();
//    String theEmailAddress =  _getEmailAddress.text.trim();
//    String theMobileNumber =  _getMobileNumber.text.trim();
//    String thePassword =  _getPassword.text.trim();
//
//    theMobileNumber = funcs.replaceArabicNumber(theMobileNumber);
//    theMobileNumber = funcs.removeCharacterFromMobile(theMobileNumber);
//
//    String activationCode =  funcs.generateActivationCode();
//
//
//    var myUrl = Uri.parse(funcs.mainLink+'api/sendActivationCode');
//    http.post(myUrl, body: {
//      "activationCode" : activationCode,
//      "theEmailAddress": theEmailAddress,
//    }).then((result) async{
//      print(result.body.toString());
//      if(result.body.toString() == 'true'){
//
//        Navigator.of(context, rootNavigator: true).pop();
//        Navigator.push(context, MaterialPageRoute(builder: (context) => Activation(theFullName,theEmailAddress,theMobileNumber,thePassword,cityId,mytoken,activationCode)),);
//      }else{
//        Navigator.of(context, rootNavigator: true).pop();
//      }
//    }).catchError((error) {
//      print(error);
//      Navigator.of(context, rootNavigator: true).pop();
//    });
//
//
//  }


  void _register_member() async{


      styles.onLoading(context);

      String theFullName = _getFullName.text.trim();
      String theEmailAddress = _getEmailAddress.text.trim();
      String theMobileNumber = _getMobileNumber.text.trim();
      String thePassword = _getPassword.text.trim();

      var myUrl = Uri.parse('${funcs.mainLink}api/register_member');
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

        }else if(theResult['resultFlag'] == 'emailDuplicate'){
          styles.showSnackBar(context, context.localeString('email_already_registered'),'error','');
          Navigator.of(context, rootNavigator: true).pop();
        }else if(theResult['resultFlag'] == 'mobileDuplicate'){
          styles.showSnackBar(context, context.localeString('mobile_number_already_registered'),'error','');
          Navigator.of(context, rootNavigator: true).pop();
        }else{
          styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
          Navigator.of(context, rootNavigator: true).pop();
        }
      }).catchError((error) {
        print(error);
        styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      });


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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),),
                              icon: const Icon(Icons.arrow_back_ios),
                              color: Theme.of(context).primaryColor,
                            )
                          ],
                        ),
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
                              Text(context.localeString('register_page_title'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 19.0), textAlign: TextAlign.center),
                              Container(
                                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return context.localeString('field_is_empty').toString();
                                    }else if(value.length < 3) {
                                      return context.localeString('field_must_more_three').toString();
                                    }
                                    return null;
                                  },
                                  autocorrect: false,
                                  style: styles.inputTextStyle,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                    prefixIcon: const Icon(Icons.person, color: Colors.black54),
                                    hintText: context.localeString('full_name').toString(), hintStyle:  styles.inputTextHintStyle,
                                    fillColor: Colors.transparent,
                                    filled: true,
                                  ),
                                  controller: _getFullName,
                                  keyboardType: TextInputType.text,
                                  maxLines: null,
                                ),
                              ),
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
                                  style: styles.inputTextStyle,
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
                                    }else if(value.length < 10) {
                                      return context.localeString('mobile_must_more_ten').toString();
                                    }
                                    return null;
                                  },
                                  autocorrect: false,
                                  style: styles.inputTextStyle,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                    prefixIcon: const Icon(Icons.phone_iphone, color: Colors.black54),
                                    hintText: context.localeString('mobile_number').toString(), hintStyle:  styles.inputTextHintStyle,
                                    fillColor: Colors.transparent,
                                    filled: true,
                                  ),
                                  controller: _getMobileNumber,
                                  inputFormatters: [maskFormatter],
                                  keyboardType: TextInputType.phone,
                                ),
                              ),

                              int.parse(countryId) > 0 ? Container(
                                width: 400.0,
                                padding: const EdgeInsets.only(right: 25.0, left: 25.0, top: 27.0),
                                alignment: Alignment.topCenter,
                                child: DropdownButtonFormField(
                                  validator: (value) => cityId == '0' ? context.localeString('field_is_empty').toString() : null,
                                  isExpanded: true,
                                  items: citiesList,
                                  onChanged: (value)=> _changeCity(value.toString()),
                                  value: cityId,
                                ),
                              ):Container(),

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
                                  style: styles.inputTextStyle,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                    prefixIcon: const Icon(Icons.lock, color: Colors.black54),
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
                      ),
                      Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                          child: GestureDetector(
                            child: Text(context.localeString('register_privacy_approve'), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12.0), textAlign: TextAlign.center),
                            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('terms_and_conditions')),),
                          )
                      ),
                      Center(
                          child: GestureDetector(
                            child: Text(context.localeString('i_have_account'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0), textAlign: TextAlign.center),
                            onTap: ()=> Navigator.of(context).pushNamedAndRemoveUntil('/Login',(Route<dynamic> route) => false),
                          )
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 50.0)),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: isLoading == true ? FloatingActionButton(
        onPressed: ()=> null,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
        backgroundColor: Colors.white,
      ):Container(),
    );
  }

}