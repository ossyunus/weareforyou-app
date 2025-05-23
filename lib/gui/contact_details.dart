import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weareforyou/components/bottom_navigation_bar.dart';

class ContactDetails extends StatefulWidget{
  ContactDetails(this.contactId);
  String contactId;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ContactDetailsState(contactId);
  }

}

class _ContactDetailsState extends State<ContactDetails> {
  _ContactDetailsState(this.contactId);
  String contactId;

  String branchName = '';
  late String theLanguage;
  String theAddress = '';
  String phoneNumber = '';
  late String emailAddress = '';
  String website = '';
  String facebook = '';
  String whatsApp = '';
  String instagram = '';
  String twitter = '';
  String linkedIn = '';
  String youtube = '';
  String mapLink = '';
  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getContactData(theLanguage).then((result) {
        setState(() {
          theAddress = result['contactData'][0]['theAddress'];
          phoneNumber = result['contactData'][0]['phoneNumber'];
          emailAddress = result['contactData'][0]['emailAddress'];
          website = result['contactData'][0]['website'];
          facebook = result['contactData'][0]['facebook'];
          whatsApp = result['contactData'][0]['whatsappNumber'];
          instagram = result['contactData'][0]['instgram'];
          twitter = result['contactData'][0]['twitter'];
          linkedIn = result['contactData'][0]['linkedin'];
          youtube = result['contactData'][0]['youtube'];
          mapLink = result['contactData'][0]['mapLink'];
        });
      });
    });
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }
  }

  Future<Map> getContactData(String lang) async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse('${funcs.mainLink}api/contactus/$lang/$contactId');
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


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, isLoading, theLanguage, branchName, true),
      body: isLoading == false ? ListView(
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
          const SizedBox(height: 10.0,),
          ListTile(
            title: Text(context.localeString('address'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(theAddress, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.mapMarked, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: (){
              if(mapLink.isNotEmpty){
                funcs.openLink(mapLink,'link_without','');
              }else{
                null;
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text(context.localeString('phone_number'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(phoneNumber, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.mobileAlt, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(phoneNumber,'tel',''),
          ),
          const Divider(),

          emailAddress.isNotEmpty && emailAddress != ''? ListTile(
            title: Text(context.localeString('email_address'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(emailAddress, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.at, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(emailAddress,'email',''),
          ):Container(),
          emailAddress.isNotEmpty && emailAddress != ''? const  Divider():Container(),

          website.isNotEmpty && website != '' ? ListTile(
            title: Text(context.localeString('website'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(website, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.internetExplorer, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(website,'link_without',''),
          ):Container(),
          website.isNotEmpty && website != '' ? const Divider():Container(),

          whatsApp.isNotEmpty && whatsApp != '' ? ListTile(
            title: Text(context.localeString('whats_app'), style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(whatsApp, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.whatsapp, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink('https://api.whatsapp.com/send?phone=$whatsApp','link_without',''),
          ):Container(),
          whatsApp.isNotEmpty&& whatsApp != '' ?const Divider():Container(),

          facebook.isNotEmpty && facebook != '' ? ListTile(
            title: Text(context.localeString('facebook'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(facebook, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.facebook, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(facebook,'link_without',''),
          ):Container(),
          facebook.isNotEmpty&& facebook != '' ?const Divider():Container(),

          instagram.isNotEmpty && instagram != ''? ListTile(
            title: Text(context.localeString('instagram'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(instagram, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.instagram, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(instagram,'link_without',''),
          ):Container(),
          instagram.isNotEmpty && instagram != '' ? const Divider():Container(),

          youtube.isNotEmpty && youtube != ''? ListTile(
            title: Text(context.localeString('youtube'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(youtube, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: theLanguage != 'ar' ? FaIcon(FontAwesomeIcons.youtube, size: 20.0, color: Theme.of(context).secondaryHeaderColor):null,
            trailing: theLanguage == 'ar' ? FaIcon(FontAwesomeIcons.youtube, size: 20.0, color: Theme.of(context).secondaryHeaderColor):null,
            onTap: ()=> funcs.openLink(youtube,'link_without',''),
          ):Container(),
          youtube.isNotEmpty && youtube != '' ? const Divider():Container(),

          linkedIn.isNotEmpty && linkedIn != ''? ListTile(
            title: Text(context.localeString('linkedin'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(linkedIn, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.linkedin, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(linkedIn,'link_without',''),
          ):Container(),
          linkedIn.isNotEmpty && linkedIn != '' ? const Divider():Container(),

          twitter.isNotEmpty && twitter != '' ? ListTile(
            title: Text(context.localeString('twitter'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(twitter, textDirection: TextDirection.ltr, style: styles.listTileStyle, textAlign: theAlignment),
            leading: FaIcon(FontAwesomeIcons.twitter, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
            onTap: ()=> funcs.openLink(twitter,'link_without',''),
          ):Container(),
          const SizedBox(height: 125.0,),
        ],
      ):Container(),

      floatingActionButton: isLoading == true ? FloatingActionButton(
        onPressed: ()=> null,
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), strokeWidth: 1.3,),
      ):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(0),
    );
  }

}