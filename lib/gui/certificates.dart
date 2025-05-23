import 'package:flutter/material.dart';
import 'package:weareforyou/components/styles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/module/get_data.dart';
import 'package:weareforyou/module/get_certificates.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/drawer.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Certificates extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CertificatesState();
  }

}

class _CertificatesState extends State<Certificates>{

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

  var certificatesList = <GetCertificates>[];

  _getDataList() {
    GetData.getDataList('${funcs.mainLink}api/getCertificates/$memberId/$theLanguage/$pageId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        certificatesList = list.map((model) => GetCertificates.fromJson(model)).toList();
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



  Widget getCertificatesList(){

    return ListView.builder(
        itemCount: certificatesList.length,
        itemBuilder: (BuildContext context, int index) =>

            GestureDetector(
              onTap: () async{
                funcs.openLink('${funcs.mainLink}certificate/event/$memberId/${certificatesList[index].evId}','link_without','');
              },
              child: Container(
                padding: const EdgeInsets.all(13.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color.fromRGBO(235, 235, 235, 1),),
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.solidFilePdf, color: Colors.red,),
                    const SizedBox(width: 10.0,),
                    Expanded(
                      child: Text(certificatesList[index].eventName, style: styles.nameTitle,),
                    ),
                    const FaIcon(FontAwesomeIcons.download, color: Colors.green,),
                  ],
                ),

              ),
            )
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
        appBar: styles.theAppBar(context, false, theLanguage, context.localeString('events_certificates'), true),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: getCertificatesList(),
        ),
        floatingActionButton: isLoading == true ? FloatingActionButton(
          onPressed: ()=> null,
          backgroundColor: Colors.white,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
        ):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(0),
        drawer: DrawerClass(isLogin, fullName),
      ),
    );
  }

}