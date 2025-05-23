import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/gui/login.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';

class ForgetPassword extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ForgetPasswordState();
  }

}

class _ForgetPasswordState extends State<ForgetPassword>{

  final TextEditingController _getEmailAddress = TextEditingController();
  late String theLanguage;
  late TextAlign theAlignment;
  bool passwordSent = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
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


  void resetPassword() async{

    styles.onLoading(context);

    String theEmailAddress =  _getEmailAddress.text.trim();

    var myUrl = Uri.parse(funcs.mainLink+'api/resetPassword');
    http.post(myUrl, body: {
      "emailAddress": theEmailAddress,
    }).then((result) async{
//      var theResult = json.decode(result.body);
      if(result.body.toString() == 'sent'){
        setState(() {
          passwordSent = true;
        });
        styles.showSnackBar(context,context.localeString('new_password_sent').toString(),'success','');
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        styles.showSnackBar(context,context.localeString('email_not_found').toString(),'error','');
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
                      const SizedBox(height: 20.0,),
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
                      Text(context.localeString('reset_password_title'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25.0), textAlign: TextAlign.center),
                      const Padding(padding: EdgeInsets.only(top: 40.0)),

                      passwordSent == false ? Card(
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
                                padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                                child: GestureDetector(
                                  onTap: (){
                                    if (_formKey.currentState!.validate()) {
                                      resetPassword();
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: styles.primaryButton(context),
                                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                                    margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                                    child: Text(context.localeString('send'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 30.0)),
                            ],
                          ),
                        ),
                      ):Container(
                        padding: const EdgeInsets.only(right: 35.0, left: 35.0, top: 5.0, bottom: 5.0 ),
                        child: Column(
                          children: <Widget>[
                            Text(context.localeString('new_password_sent'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20.0), textAlign: TextAlign.center),
                            const Padding(padding: EdgeInsets.only(top: 40.0)),
                            Container(
                              padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: styles.primaryButton(context),
                                  padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                                  margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                                  child: Text(context.localeString('go_to_login'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

}