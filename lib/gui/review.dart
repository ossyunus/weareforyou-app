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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:weareforyou/gui/main_page.dart';

class Review extends StatefulWidget{
  Review(this.eventId);
  String eventId;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReviewState(this.eventId);
  }

}

class _ReviewState extends State<Review>{
  _ReviewState(this.eventId);
  String eventId;

  final TextEditingController _getDetails = TextEditingController();

  late String memberId = '0';
  late String theLanguage = '';
  late String fullName = '';
  late String mobileNumber = '';

  late bool isLogin = false;
  late TextAlign theAlignment;
  bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  final bool _isVertical = false;
  double _thisUserRating = 1.0;
  final int _ratingBarMode = 1;
  IconData? _selectedIcon;

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

  Widget _ratingBar(int mode){
    switch (mode) {
      case 1:
        return RatingBar.builder(
          initialRating: 0,
          direction: _isVertical ? Axis.vertical : Axis.horizontal,
          allowHalfRating: true,
          unratedColor: Colors.grey[200],
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            _selectedIcon ?? Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) async{
            setState(() {
              _thisUserRating = rating;
            });
          },
        );

      default:
        return Container();
    }
  }

  void sendReview() async{

    styles.onLoading(context);

    http.post(Uri.parse('${funcs.mainLink}api/sendReview'), body: {
      "memberId": memberId,
      "eventId": eventId,
      "review": _getDetails.text.trim(),
      "theRate": _thisUserRating.toString()
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 'done'){
        _getDetails.text = '';
        setState(() {});

        styles.showSnackBar(context,context.localeString('review_sent_successfully').toString(),'success','');
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
      appBar: styles.theAppBar(context, false, theLanguage, context.localeString('review_title'), true),
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
                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
                          child: _ratingBar(_ratingBarMode),
                        ),

                        Container(
                          padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 30.0),
                          child: TextFormField(
                            autocorrect: false,
                            style: styles.inputTextStyle,
                            textAlign: theAlignment,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                              prefixIcon: const Icon(Icons.reviews, color: Colors.black54),
                              hintText: context.localeString('review').toString(), hintStyle: styles.inputTextHintStyle,
                              fillColor: const Color.fromRGBO(245,245,245,1),
                              filled: true,
                            ),
                            controller: _getDetails,
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                          ),
                        ),

                        const SizedBox(height: 30.0,),
                        Container(
                          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                          child: GestureDetector(
                            onTap: (){
                              if (_formKey.currentState!.validate()) {
                                sendReview();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: styles.primaryButton(context),
                              padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                              margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                              child: Text(context.localeString('review_btn'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
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