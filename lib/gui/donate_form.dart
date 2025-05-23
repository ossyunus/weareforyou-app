import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:weareforyou/gui/main_page.dart';

class DonateForm extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DonateFormState();
  }

}

class _DonateFormState extends State<DonateForm>{

  final TextEditingController _getFullName = TextEditingController();
  final TextEditingController _getMobileNumber = TextEditingController();
  final TextEditingController _getAddress = TextEditingController();
  final TextEditingController _getAmount = TextEditingController();
  final TextEditingController _getDetails = TextEditingController();

  late String memberId = '0';
  late String theLanguage = '';
  late String fullName = '';
  late String mobileNumber = '';

  late bool isLogin = false;
  late TextAlign theAlignment;
  bool isLoading = false;
  String countryId = '113';
  List<DropdownMenuItem<String>> citiesList = [];
  String cityId = '0';

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();


  var maskFormatter = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getCities(countryId);
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

  void getCities(countryId) async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse('${funcs.mainLink}api/getCitiesByCountry/$theLanguage/$countryId/');
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
      responseData.forEach((addresses){
        citiesList.add(DropdownMenuItem(
          value: "${addresses['ciId']}",
          child: SizedBox(
            width: double.infinity,
            child: Text(addresses['theTitle'], style: styles.inputTextStyle,textAlign: TextAlign.center),
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

  void sendData() async{

    styles.onLoading(context);

    http.post(Uri.parse('${funcs.mainLink}api/sendDonate'), body: {
      "fullName": _getFullName.text.trim(),
      "mobileNumber": _getMobileNumber.text.trim(),
      "address": _getAddress.text.trim(),
      "amount": _getAmount.text.trim(),
      "details": _getDetails.text.trim(),
      "cityId": cityId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 'done'){
        _getFullName.text = '';
        _getMobileNumber.text = '';
        _getAddress.text = '';
        _getAmount.text = '';
        _getDetails.text = '';
        cityId = '0';
        setState(() {});

        styles.showSnackBar(context,context.localeString('denate_sent_successfully').toString(),'success','');
        Navigator.of(context, rootNavigator: true).pop();
        await Future.delayed(const Duration(seconds: 2));

        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, anotherAnimation){
            return MainPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {

            return FadeTransition(
              opacity:animation,
              child: child,
            );
          },
        ));
      } else{
        styles.showSnackBar(context,context.localeString('error_occurred'),'error','');
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      styles.showSnackBar(context,context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    });

  }

  Future<bool> _onWillPop() async{
    if (Navigator.canPop(context)) {
      Navigator.pop(context,true);
      return false;
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, false, theLanguage, context.localeString('donation'), true),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: <Widget>[
          GestureDetector(
              onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[

                    const Padding(padding: EdgeInsets.only(top: 30.0)),
                    Column(
                      children: <Widget>[
                        int.parse(countryId) > 0 ? Container(
                          width: 400.0,
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 0.0),
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
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
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
                            textAlign: theAlignment,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                              prefixIcon: const Icon(Icons.person, color: Colors.black54),
                              hintText: context.localeString('full_name').toString(), hintStyle: styles.inputTextHintStyle,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            controller: _getFullName,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
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
                            textAlign: theAlignment,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.phone_iphone, color: Colors.black54),
                              hintText: context.localeString('mobile_number').toString(), hintStyle: styles.inputTextHintStyle,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            controller: _getMobileNumber,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [maskFormatter],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
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
                            textAlign: theAlignment,
                            decoration:InputDecoration(
                              border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                              prefixIcon: const Icon(Icons.pin_drop, color: Colors.black54),
                              hintText: context.localeString('address').toString(), hintStyle: styles.inputTextHintStyle,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            controller: _getAddress,
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return context.localeString('field_is_empty').toString();
                              }
                              return null;
                            },
                            autocorrect: false,
                            style: styles.inputTextStyle,
                            textAlign: theAlignment,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                              prefixIcon: const Icon(Icons.monetization_on, color: Colors.black54),
                              hintText: context.localeString('amount').toString(), hintStyle: styles.inputTextHintStyle,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            controller: _getAmount,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
                          child: TextFormField(
                            autocorrect: false,
                            style: styles.inputTextStyle,
                            textAlign: theAlignment,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                              prefixIcon: const Icon(Icons.assignment, color: Colors.black54),
                              hintText: context.localeString('details').toString(), hintStyle: styles.inputTextHintStyle,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            controller: _getDetails,
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                          ),
                        ),

                        const SizedBox(height: 30.0,),
                        Container(
                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                          child: GestureDetector(
                            onTap: (){
                              if (_formKey.currentState!.validate()) {
                                sendData();
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
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 40.0)),
                  ],
                ),
              )
          )
        ],
      ),
      floatingActionButton: isLoading == true ? FloatingActionButton(
        onPressed: ()=> null,
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
      ):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(0),
    );
  }

}