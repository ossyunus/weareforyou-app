import 'package:flutter/material.dart';
import 'package:weareforyou/components/styles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/module/get_data.dart';
import 'package:weareforyou/module/get_initiatives.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';

  class Initiatives extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InitiativesState();
  }

}

class _InitiativesState extends State<Initiatives>{

  late String theLanguage = '';
  bool isLogin = false;
  late String fullName = '';
  late String memberId = '0';

  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var eventsList = <GetInitiatives>[];

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getInitiatives/$theLanguage/').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        eventsList = list.map((model) => GetInitiatives.fromJson(model)).toList();
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

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }
  }


  Widget getDataList(){

    return  GridView.builder(
        itemCount: eventsList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: MediaQuery.of(context).size.width / (300),
        ),
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) =>
            styles.widgetInitiatives(scaffoldKey, context, isLogin, theLanguage, eventsList, index)
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, false, theLanguage, context.localeString('initiatives'), true),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: getDataList(),
      ),
      floatingActionButton: isLoading == true ? FloatingActionButton(
        onPressed: ()=> null,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
        backgroundColor: Colors.white,
      ):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(0),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}