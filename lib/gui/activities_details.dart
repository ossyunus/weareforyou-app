//import 'dart:ui' as ui;
//import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
//import 'dart:async';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:transparent_image/transparent_image.dart';
//import 'package:html2md/html2md.dart' as html2md;
//import 'package:intl/intl.dart';
//import 'package:weareforyou/components/funcs.dart';
//import 'package:weareforyou/components/styles.dart';
//
//class ActivitiesDetails extends StatefulWidget{
//  ActivitiesDetails(this.activityId, this.activityTitle, this.activityPhoto, {Key? key}) : super(key: key);
//  late String activityId;
//  String activityTitle;
//  String activityPhoto;
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    // ignore: no_logic_in_create_state
//    return _ActivitiesDetailsState(activityId, activityTitle, activityPhoto);
//  }
//
//}
//
//class _ActivitiesDetailsState extends State<ActivitiesDetails>{
//  _ActivitiesDetailsState(this.activityId, this.activityTitle, this.activityPhoto);
//  String activityId;
//  String activityTitle = '';
//  String activityPhoto = '';
//  late String activityDetails = '';
//  late String activityDate = '';
//  late String theLanguage;
//  late TextAlign theAlignment;
//  late TextDirection theDirection;
//  bool isLoading = false;
//
//  var funcs = Funcs();
//  var styles = Styles();
//
//  @override
//  void initState(){
//    super.initState();
//    getSharedData().then((result) {
//      getData().then((result) {
//        setState(() {
//          activityDetails = html2md.convert(result['activityDetails'][0]['theDetails']);
//          activityDate = result['activityDetails'][0]['theDate'];
//        });
//      });
//    });
//
//  }
//
//  getSharedData() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    setState(() {
//      theLanguage = prefs.getString('theLanguage')!;
//      if(theLanguage == 'ar'){
//        theAlignment = TextAlign.right;
//      }else{
//        theAlignment = TextAlign.left;
//      }
//    });
//  }
//
//
//  Future<Map> getData() async{
//    setState(() {
//      isLoading = true;
//    });
//    var result;
//    var myUrl = Uri.parse(funcs.mainLink+'api/getActivityDetails/$theLanguage/$activityId');
//    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//    try{
//      setState(() {
//        isLoading = false;
//      });
//      result = json.decode(response.body);
//    }catch(e){
////      print(e);
//    }
//    return result;
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('', style: Theme.of(context).textTheme.headline1,),
//        centerTitle: true,
//      ),
//      body: isLoading ? Center(
//        child: Container(),
//      ):ListView(
//        padding: const EdgeInsets.all(15.0),
//        children: <Widget>[
//          Container(
//            child: ClipRRect(
//              borderRadius: BorderRadius.circular(13.0),
//              child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: funcs.mainMediaLink+"public/uploads/php/files/news/thumbnail/$activityPhoto"),
//            ),
//          ),
//          Container(
//            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
//            child: Text(activityTitle, style: styles.paragraphTitle, textAlign: theAlignment),
//          ),
//          Container(
//            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0),
//            child: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(activityDate)), style: styles.theDate, textAlign: theAlignment),
//          ),
//          Container(
//            padding: const EdgeInsets.all(15.0),
//            child: Text(activityDetails, textDirection: theLanguage == 'ar' ? ui.TextDirection.rtl:ui.TextDirection.ltr, style: Theme.of(context).textTheme.bodyMedium, textAlign: theAlignment),
//          ),
//          const SizedBox(height: 30.0,),
//
//        ],
//      ),
//      floatingActionButton: isLoading == true ? FloatingActionButton(
//        onPressed: ()=> null,
//        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
//        backgroundColor: Colors.white,
//      ):Container(),
//    );
//  }
//
//}