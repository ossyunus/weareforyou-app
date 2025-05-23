import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/gui/widgets/animated_image.dart';

class Statistics extends StatefulWidget{
  const Statistics({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StatisticsState();
  }

}

class _StatisticsState extends State<Statistics> {

  late String theLanguage = '';
  bool isLogin = false;
  late String memberId = '0';
  late String fullName = '';

  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late FocusNode myFocusNode;

  late String totalEvents = '';
  late String totalMembers  = '';
  late String totalBeneficiaries = '';

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getStatistics().then((result) {
        setState(() {
          totalEvents = (int.parse('800') + int.parse(result['totalEvents'][0]['totalEvents'])).toString();
          totalMembers = (int.parse('9100') + int.parse(result['totalMembers'][0]['totalMembers'])).toString();
          totalBeneficiaries = (int.parse('30000') + int.parse(result['totalBeneficiaries'][0]['totalBeneficiaries'])).toString();
        });
      });
    });
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
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }
    });
  }

  Future<Map> getStatistics() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse('${funcs.mainLink}api/statistics/');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
      print(e);
    }
    return result;
  }

  Widget widgetImportant(){

    return Row(
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 120.0,
              height: 120.0,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 15.0, left: 15.0, top: 5.0),
              padding: const EdgeInsets.all(20.0),
              decoration: styles.importantBoxDecoration(context),
              child: Text(totalEvents, style: styles.statisticsCount,),
            ),

            Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: styles.nameTitle,
                          text: context.localeString('total_events')),
                    ),
                  ],
                )
            )
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 120.0,
              height: 120.0,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 15.0, left: 15.0, top: 5.0),
              padding: const EdgeInsets.all(20.0),
              decoration: styles.importantBoxDecoration(context),
              child: Text(totalMembers, style: styles.statisticsCount,),
            ),

            Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: styles.nameTitle,
                          text: context.localeString('total_members')),
                    ),
                  ],
                )
            )
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 120.0,
              height: 120.0,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 15.0, left: 15.0, top: 5.0),
              padding: const EdgeInsets.all(20.0),
              decoration: styles.importantBoxDecoration(context),
              child: Text(totalBeneficiaries, style: styles.statisticsCount,),
            ),

            Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: styles.nameTitle,
                          text: context.localeString('total_beneficiaries')),
                    ),
                  ],
                )
            )
          ],
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, false, theLanguage, context.localeString('statistics'), true),
      body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 10.0,),
                      AnimatedImage('images/logo.png',120),
                      const SizedBox(height: 30.0,),
                      Center(
                          child: Text(context.localeString('statistics_desc'), style: styles.paragraphTitle,)
                      ),
                      Container(
                          margin: const EdgeInsets.only(bottom:  5.0, top: 5.0),
                          height:200.0,
                          child: ListView.builder(
                              itemCount: 1,
                              shrinkWrap: false,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index){
                                return widgetImportant();
                              }
                          )
                      )
                    ]
                )
            ),
          ]
          ),
      bottomNavigationBar: BottomNavigationBarWidget(2),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}
