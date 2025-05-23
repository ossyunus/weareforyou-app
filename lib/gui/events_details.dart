import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:weareforyou/gui/view_photo.dart';
import 'package:weareforyou/gui/donate.dart';
import 'package:intl/intl.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';

class EventsDetails extends StatefulWidget{
  EventsDetails(this.eventId, this.theTitle, this.thePhoto);
  late String eventId;
  String theTitle;
  String thePhoto;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventsDetailsState(eventId, theTitle, thePhoto);
  }

}

class _EventsDetailsState extends State<EventsDetails>{
  _EventsDetailsState(this.eventId, this.theTitle, this.thePhoto);
  String eventId;
  String theTitle = '';
  String thePhoto = '';

  late String theLanguage = '';
  bool isLogin = false;
  late String memberId = '0';

  late String theDetails = '';
  late String location = '';
  late String theDate = '0000-00-00';
  late String theTime = '00:00:00';
  late String targetGroup = '';
  late String fee = '0.0';
  late String eventType = '';

  late String joinStatus = '';
  late String joinBtn = '';
  late Color joinBtnColors = Theme.of(context).primaryColor;

  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result){
      getData();
    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      memberId = prefs.getString('memberId')!;
      isLogin = prefs.getBool('isLogin')!;
      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
      }else{
        theAlignment = TextAlign.left;
      }
    });
  }


  void getData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse('${funcs.mainLink}api/getEventsDetails/$theLanguage/$eventId/$memberId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);

      setState(() {
        theTitle = result['theData'][0]['theTitle'];
        theDetails = result['theData'][0]['theDetails'];
        location = result['theData'][0]['location'];
        theDate = result['theData'][0]['theDate'];
        theTime = result['theData'][0]['theTime'];
        targetGroup = result['theData'][0]['targetGroup'];
        thePhoto = result['theData'][0]['thePhoto'];
        fee = result['theData'][0]['fee'];
        eventType = result['theData'][0]['theType'];

        joinBtn = context.localeString('join');
        joinBtnColors = Theme.of(context).primaryColor;
        if(int.parse(memberId) > 0){
          if(eventType == 'event'){
            joinStatus = result['checkJoined'][0]['joinStatus'];
            if(joinStatus == 'pending'){
              joinBtn = context.localeString('pending');
              joinBtnColors = Colors.orange;
            }else if(joinStatus == 'accept'){
              joinBtn = context.localeString('accept');
              joinBtnColors = Colors.green;
            }else if(joinStatus == 'ignore'){
              joinBtn = context.localeString('ignore');
              joinBtnColors = Colors.red;
            }
          }else{
            joinBtn = context.localeString('donation');
            joinBtnColors = Theme.of(context).primaryColor;
          }
        }else{
          if(eventType != 'event'){
            joinBtn = context.localeString('donation');
            joinBtnColors = Theme.of(context).primaryColor;
          }
        }
      });

    }catch(e){
//      print(e);
    }
//    return result;
  }

  joinEvent() async{
    styles.onLoading(context);

    String result = await funcs.joinEvent(eventId);

    if(result == 'done'){

      Navigator.of(context, rootNavigator: true).pop();

      getData();

    }else{
      styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  deleteJoinEvent() async{
    styles.onLoading(context);

      String result = await funcs.deleteJoinEvent(eventId);

    if(result == 'done'){

      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        joinStatus = '';
      });
      getData();

    }else{
      styles.showSnackBar(context, context.localeString('error_occurred'),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<bool> _onWillPop() async{
    if (Navigator.canPop(context)) {
      Navigator.pop(context,true);
      return false;
    } else {
      exit(0);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
      displacement: 150,
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      color: Colors.white,
      strokeWidth: 2,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500));
        getData();
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: scaffoldKey,
          appBar: styles.theAppBar(context, false, theLanguage, '', true),
          body: isLoading == true ? Container() : ListView(
            padding: const EdgeInsets.all(5.0),
            children: <Widget>[

              Container(
                margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 16.0), //
                child: Column(
                  children: [

                    GestureDetector(
                      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPhoto(thePhoto, 'events')),),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'images/logo.png',
                        image: "${funcs.mainMediaLink}public/uploads/php/files/events/thumbnail/$thePhoto",
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
                      width: double.infinity,
                      child: Text(theTitle, style: styles.nameTitle, textAlign: theAlignment,),
                    ),

                    const SizedBox(height: 10.0,),

                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 17.0),
                      child: HtmlWidget(theDetails, textStyle: const TextStyle(color: Colors.black87, fontSize: 16),),
                    ),//

                    Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 0.0),
                      width: double.infinity,
                      child: Text(context.localeString('the_date'), style: styles.nameTitle, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 17.0),
                      width: double.infinity,
                      child: Text('${DateFormat('dd/MM/yyyy').format(DateTime.parse(theDate))} - ${DateFormat('EEEE', 'Ar_ar').format(DateTime.parse(theDate))}', style: Theme.of(context).textTheme.bodyMedium , textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ),

                    theTime != '00:00:00' ? Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 0.0),
                      width: double.infinity,
                      child: Text(context.localeString('the_time'), style: styles.nameTitle, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container(),
                    theTime != '00:00:00' ? Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 17.0),
                      width: double.infinity,
                      child: Text(DateFormat('h:mm a').format(DateTime.parse('${theDate}T$theTime')).toString(), style: Theme.of(context).textTheme.bodyMedium, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container() ,

                    targetGroup != '' ? Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 0.0),
                      width: double.infinity,
                      child: Text(context.localeString('target_group'), style: styles.nameTitle, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container(),

                    targetGroup != '' ? Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 17.0),
                      width: double.infinity,
                      child: Text(targetGroup, style: Theme.of(context).textTheme.bodyMedium, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container(),

                    double.parse(fee) > 0.0 ? Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 0.0),
                      width: double.infinity,
                      child: Text(context.localeString('fee'), style: styles.nameTitle, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container(),

                    double.parse(fee) > 0.0 ? Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 17.0),
                      width: double.infinity,
                      child: Text('$fee دينار أردني', style: Theme.of(context).textTheme.bodyMedium, textDirection: theLanguage == 'ar' ? ui.TextDirection.rtl:ui.TextDirection.ltr, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container(),

                    Container(
                      padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 20.0),
                      child: GestureDetector(
                        onTap: (){
                          var now = DateTime.now();
                          var formatter = DateFormat('yyyy-MM-dd');
                          var formattedDate = formatter.format(now);

                          if(DateTime.parse(theDate).compareTo(DateTime.parse(formattedDate)) >= 0){
                            if(eventType == 'event'){
                              if(isLogin == true){
                                if(joinStatus.isEmpty){
                                  joinEvent();
                                }else if(joinStatus == 'pending'){
                                  deleteJoinEvent();
                                }
                              }else{
                                styles.needLoginModalBottomSheet(context);
                              }
                            }else{
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, animation, anotherAnimation){
                                  return Donate('volunteer');
                                },
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {

                                  return FadeTransition(
                                    opacity:animation,
                                    child: child,
                                  );
                                },
                              ));
                            }
                          }else{
                            styles.showSnackBar(context, context.localeString('this_event_is_expired'),'error','');
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          // decoration: styles.primaryButton(context),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                                bottomLeft: Radius.circular(50)),
                            color: joinBtnColors,
                            // border: Border.all(color: const Color.fromRGBO(215, 215, 215, 1))
                          ),

                          padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 10.0, top: 10.0),
                          margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                          child: Text(joinBtn,style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                        ),
                      ),
                    ),

                    // isLoading == false ? Container(
                    //   padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                    //   child: RaisedButton(
                    //     onPressed: (){
                    //
                    //     },
                    //     padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                    //     child: Text(joinBtn,style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),
                    //     color: joinBtnColors,
                    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    //     elevation: 0.0,
                    //   ),
                    // ):Container(),

                    const SizedBox(height: 20.0,),
                  ],
                ),
              ),

              const SizedBox(height: 50.0,),
            ],
          ),
          floatingActionButton: isLoading == true ? FloatingActionButton(
            onPressed: ()=> null,
            backgroundColor: Colors.white,
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
          ):location.isNotEmpty?  FloatingActionButton(
            onPressed: ()=> funcs.openLink(location,'link_without',''),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.pin_drop, color: Colors.white),
          ):Container(  ),
        ),
      ),
    );
  }

}