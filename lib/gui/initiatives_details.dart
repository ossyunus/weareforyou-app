import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/gui/view_photo.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';

class InitiativesDetails extends StatefulWidget{
  InitiativesDetails(this.initiativesId, this.theTitle, this.thePhoto);
  late String initiativesId;
  String theTitle;
  String thePhoto;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InitiativesDetailsState(initiativesId, theTitle, thePhoto);
  }

}

class _InitiativesDetailsState extends State<InitiativesDetails>{
  _InitiativesDetailsState(this.initiativesId, this.theTitle, this.thePhoto);
  String initiativesId;
  String theTitle = '';
  String thePhoto = '';

  late String theDetails = '';
  late String theLanguage;
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getData().then((result) {
        setState(() {
          theDetails = result['theData'][0]['theDetails'];
        });
      });
    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      if(theLanguage == 'ar'){
      theAlignment = TextAlign.right;
      }else{
      theAlignment = TextAlign.left;
      }
    });
  }


  Future<Map> getData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getInitiativesDetails/$theLanguage/$initiativesId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
//      print(e);
    }
    return result;
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, false, theLanguage, theTitle, true),
      body: ListView(
        padding: const EdgeInsets.all(5.0),
        children: <Widget>[

          Container(
            decoration: styles.cardBoxDecoration(context),
            margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 16.0), //
            child: Column(
              children: [

                GestureDetector(
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPhoto(thePhoto, 'initiatives')),),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'images/logo.png',
                    image: funcs.mainMediaLink+"public/uploads/php/files/initiatives/thumbnail/$thePhoto",
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 7.0),
                  width: double.infinity,
                  child: Text(theTitle, style: styles.nameTitle, textAlign: theAlignment,),
                ),

                const SizedBox(height: 10.0,),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0, bottom: 17.0),
                  child: HtmlWidget(theDetails),
                ),

                const SizedBox(height: 10.0,),
              ],
            ),
          ),

        ],
      ),
      floatingActionButton: isLoading == true ? FloatingActionButton(
        onPressed: ()=> null,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 2,),
        backgroundColor: Colors.white,
      ):Container(),
    );
  }

}