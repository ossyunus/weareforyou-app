import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/module/get_data.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:weareforyou/gui/view_photo.dart';
import 'package:weareforyou/gui/notifications.dart';
import 'package:weareforyou/module/get_events.dart';
import 'package:badges/badges.dart' as badges;

class MainPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPageState();
  }

}

class _MainPageState extends State<MainPage>{

  late String theLanguage = '';
  bool isLogin = false;
  late String fullName = '';
  late String memberId = '0';

  late String selectedTab = 'events';

  late TextAlign theAlignment;
  late Alignment theTopAlignment;
  late TextDirection theDirection;
  bool isLoading = true;
  late String notificationsCount = '0';

  var funcs = Funcs();
  var styles = Styles();

  List sliderListFromApi = [];
  List sliderList = [];
  List sliderTitleList = [];

  List eventsList = <GetEvents>[];

  late FirebaseMessaging messaging;

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _current = 0;
  List<T> map<T>(List list, Function handler){
    List<T> result = [];
    for(var i = 0; i < list.length; i++){
      result.add(handler(i, list[i]));
    }
    return result;
  }


  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      _getNews();
      _getSliderDataList();

      if(isLogin == true){
        getUnreadNotificationsCount().then((result) {
          setState(() {
            notificationsCount = result['notificationData'][0]['theCount'];
          });
        });
      }else{
        messaging = FirebaseMessaging.instance;
        messaging.getToken().then((value){
          setState(() {
            addNonMemberToken(value.toString());
          });
        });
      }

    });

  }


  Future<Map> getUnreadNotificationsCount() async{
    var result;
    var myUrl = Uri.parse('${funcs.mainLink}api/getUnreadNotificationsCount/$memberId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      result = json.decode(response.body);
    }catch(e){
      print(e);
    }
    return result;
  }

  @override
  void dispose(){
    super.dispose();
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      isLogin = prefs.getBool('isLogin')!;
      memberId = prefs.getString('memberId')!;
      fullName = prefs.getString('fullName')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
        theTopAlignment = Alignment.topRight;
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
        theTopAlignment = Alignment.topLeft;
      }
    });
  }

  _getSliderDataList() {
    GetData.getDataList('${funcs.mainLink}api/getSlider/$theLanguage/$memberId').then((response) {
      setState(() {
        sliderListFromApi = json.decode(response.body);
        for (var e in sliderListFromApi) {
          setState(() {
            sliderList.add(e['thePhoto'].toString());
            sliderTitleList.add(e['theTitle'].toString());
          });
        }
        isLoading = false;
      });
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


  void addNonMemberToken(String myToken) async{

    var myUrl = Uri.parse('${funcs.mainLink}api/addNonMemberToken');
    http.post(myUrl, body: {
      "fcmToken": myToken,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['resultFlag'] == 'done'){
        print('ok');
      }
    }).catchError((error) {

    });
  }

  _getNews() {

    GetData.getDataList('${funcs.mainLink}api/getEvents/$theLanguage/1').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        eventsList = list.map((model) => GetEvents.fromJson(model)).toList();
        isLoading = false;
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
//        appBar: styles.theAppBar(context, false, theLanguage, context.localeString('application_name'), true),
        appBar: AppBar(
          title: Container(
            child: Text(context.localeString('application_name'),style: Theme.of(context).textTheme.labelMedium),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Theme.of(context).primaryColor,
                  const Color.fromRGBO(0, 158, 219, 1),
                ],
              ),
            ),
          ),
          leading: Builder(builder: (context) => // Ensure Scaffold is in context
            IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer()
            ),
          ),
          actions: [
            IconButton(
              icon: badges.Badge(
                badgeContent: Text(notificationsCount, style: TextStyle(color: Colors.white, fontSize: int.parse(notificationsCount) > 100 ? 11:13),),
                position: badges.BadgePosition.topEnd(top: -15, end: 12),
                // toAnimate: false,
                child: const Icon(Icons.notifications),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications()),),
            ),
          ],

          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            isLoading == false ? CustomScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                slivers: <Widget>[

                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 5.0,),
                              CarouselSlider(
                                options: CarouselOptions(
                                    height: 260.0,
                                    initialPage: 0,
                                    aspectRatio: 16/9,
                                    viewportFraction: 1,
                                    autoPlay: true,
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enableInfiniteScroll: true,
                                    autoPlayInterval: const Duration(seconds: 5),
                                    disableCenter: true,
                                    autoPlayAnimationDuration: const Duration(milliseconds: 2000),
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _current = index;
                                      });
                                    }
                                ),

                                items: sliderList.map((sliderPhoto) {
                                  return Builder(
                                    builder: (BuildContext context){
                                      return GestureDetector(
                                        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPhoto(sliderPhoto,'homeSlider')),),
                                        child: Column(
                                          children: [
                                            Container(
                                              height:210,
                                              width: MediaQuery.of(context).size.width,
                                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              child: ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topRight:  Radius.circular(40),
                                                    topLeft:  Radius.circular(40),
                                                    bottomLeft: Radius.circular(0),
                                                    bottomRight: Radius.circular(0),
                                                  ),
                                                  child: Image.network(
                                                    '${funcs.mainMediaLink}public/uploads/php/files/homeSlider/thumbnail/'+sliderPhoto,
                                                    fit: BoxFit.cover,
                                                  )
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                              padding: const EdgeInsets.only(top: 7, bottom: 7),
                                              color: Theme.of(context).secondaryHeaderColor,
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                strutStyle: const StrutStyle(fontSize: 15.0),
                                                text: TextSpan(
                                                    style: styles.topSliderText,
                                                    text: '${sliderTitleList[_current]}'),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 0.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: map<Widget>(
                                    sliderList, (index, url){
                                  return Container(
                                    width: 10.0,
                                    height: 10.0,
                                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _current == index ? Theme.of(context).primaryColor : const Color.fromRGBO(255,216,169,1)
                                    ),
                                  );
                                }
                                ),
                              )

                            ],
                          ),

                        )
                      ],
                    ),
                  ),

                  SliverList(
                      delegate: SliverChildListDelegate(
                          [

                            Container(
                                width: 100.0,
                                padding: const EdgeInsets.all(10.0),
                                margin: const EdgeInsets.only(left: 12.0, right: 12.0, top: 20.0),
                                decoration: styles.activeTabsBoxDecoration(context),
                                child: Text(context.localeString('latest_events'), style: styles.tabsTitle, textAlign: theAlignment,)
                            ),
                            Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
                                height: 345.0,
                                width: 300.0,
                                child: ListView.builder(
                                    itemCount: eventsList.length,
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext context, int index){
                                      return styles.widgetEvents(scaffoldKey, context, isLogin, theLanguage, eventsList, index, 'mainPage');
                                    }
                                )
                            )
                          ]
                      )
                  ),

                ]
            ):Container(),
          ],
        ),
        floatingActionButton: isLoading == true ? FloatingActionButton(
          onPressed: ()=> null,
          backgroundColor: Colors.white,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
        ):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(0),
        drawer: DrawerClass(isLogin, fullName),
      ),
    );
  }
}
