import 'package:flutter/material.dart';
import 'package:weareforyou/components/styles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/module/get_data.dart';
import 'package:weareforyou/module/get_events.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';

class Events extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EventsState();
  }

}

class _EventsState extends State<Events>{

  late String theLanguage = '';
  bool isLogin = false;
  late String fullName = '';
  late String memberId = '0';

  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  int pageId = 1;

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var eventsList = <GetEvents>[];

  _getDataList() {
    GetData.getDataList('${funcs.mainLink}api/getEvents/$theLanguage/$pageId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        eventsList = list.map((model) => GetEvents.fromJson(model)).toList();
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
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        pageId = pageId + 1;
        setState(() {
          isLoading = true;
          _getDataList();
        });
      }
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


  Widget getEventsList(){

    return ListView.builder(
        itemCount: eventsList.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) =>
            styles.widgetEvents(scaffoldKey, context, isLogin, theLanguage, eventsList, index, '')
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
        appBar: styles.theAppBar(context, false, theLanguage, context.localeString('events'), true),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: getEventsList(),
        ),
        floatingActionButton: isLoading == true ? FloatingActionButton(
          onPressed: ()=> null,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
          backgroundColor: Colors.white,
        ):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(1),
        drawer: DrawerClass(isLogin, fullName),
      ),
    );
  }

}