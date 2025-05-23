import 'package:flutter/material.dart';
import 'package:weareforyou/components/styles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:weareforyou/gui/events_details.dart';
import 'package:weareforyou/gui/review.dart';
import 'package:weareforyou/module/get_data.dart';
import 'package:weareforyou/module/get_notifications.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';

class Notifications extends StatefulWidget{
  const Notifications({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationsState();
  }

}

class _NotificationsState extends State<Notifications>{

  late String theLanguage = '';
  bool isLogin = false;
  late String fullName = '';
  late String memberId = '0';

  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var notificationsList = <GetNotifications>[];

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getNotifications/$memberId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        notificationsList = list.map((model) => GetNotifications.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      _getDataList();
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

      });
    }
  }

  _openNotiDetailsPage(String linkedId, String theType){
    if(theType == 'review'){
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Review(linkedId.toString())));
    }else{
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => EventsDetails(linkedId,'',''))).then((val)=>val?needToRefresh(context):print('ddd'));
    }
  }

  needToRefresh(context){
    _getDataList();
  }

  Widget getNotificationsList(){

    return ListView.builder(
      itemCount: notificationsList.length,
      itemBuilder: (BuildContext context, int index) =>
          Container(
            padding: const EdgeInsets.all(0.0),
            child: GestureDetector(
              onTap: ()=> _openNotiDetailsPage(notificationsList[index].eventId,notificationsList[index].theType),

              child: Column(
                children: <Widget>[
                  Container(

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(notificationsList[index].theTitle, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right),
                          Text(notificationsList[index].theDetails, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.right),
                          Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(notificationsList[index].theDate)), style: styles.theDate, textAlign: TextAlign.right),
                          const Padding(padding: EdgeInsets.only(top: 0.0)),
                          const Divider(),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
    );
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
        _getDataList();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: styles.theAppBar(context, false, theLanguage, context.localeString('notifications'), true),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: notificationsList.isNotEmpty || isLoading == true ? getNotificationsList():
          Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Image.asset(
                  'images/nodatafound.png',
                  width: 200.0,
                ),
                Text(context.localeString('no_data')),
              ],
            ),
          ),
        ),
        floatingActionButton: isLoading == true ? FloatingActionButton(
          onPressed: ()=> null,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
          backgroundColor: Colors.white,
        ):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(0),
      ),
    );
  }

}