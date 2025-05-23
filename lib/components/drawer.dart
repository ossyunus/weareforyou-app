import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weareforyou/gui/text_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/components/styles.dart';
import 'package:weareforyou/gui/login.dart';
import 'package:weareforyou/gui/settings.dart';
import 'package:weareforyou/gui/initiatives.dart';
import 'package:weareforyou/gui/contact_details.dart';
import 'package:weareforyou/gui/certificates.dart';
import 'package:weareforyou/gui/volunteer_certificate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerClass extends StatefulWidget{
  DrawerClass(this.isLogin, this.fullName, {Key? key}) : super(key: key);
  bool isLogin;
  String fullName;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // ignore: no_logic_in_create_state
    return _DrawerClassState(isLogin, fullName);
  }
}

class _DrawerClassState extends State<DrawerClass>{
  _DrawerClassState(this.isLogin, this.fullName);
  bool isLogin;
  String fullName;

  late String memberId;
  late String packageId = '0';
  late String packageTitle = '';
  late String emailAddress;
  late String theLanguage = '';

  late String memberShipCode = '';
  late TextAlign theAlignment = TextAlign.left;
  late Alignment theTopAlignment = Alignment.topRight;
  late TextDirection theDirection = TextDirection.ltr;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();

    getSharedData().then((result) {
    });

  }

  getSharedData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        memberId = prefs.getString('memberId')!;
        emailAddress = prefs.getString('emailAddress')!;
        theLanguage = prefs.getString('theLanguage')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
          theDirection = TextDirection.rtl;
          theTopAlignment = Alignment.topRight;
        }else{
          theAlignment = TextAlign.left;
          theDirection = TextDirection.ltr;
          theTopAlignment = Alignment.topRight;
        }
      });
    }
  }

  void logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await prefs.setBool('isLogin', false);
    await prefs.setString('memberId', '0');
    await prefs.setString('fullName', '');
    await prefs.setString('emailAddress', '');
    await prefs.setString('mobileNumber', '');
    await prefs.setString('theLanguage', theLanguage);
    Locales.change(context, theLanguage);
    Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
  }

  void deleteAccount() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await prefs.setBool('isLogin', false);
    await prefs.setString('memberId', '0');
    await prefs.setString('fullName', '');
    await prefs.setString('emailAddress', '');
    await prefs.setString('mobileNumber', '');
    await prefs.setString('theLanguage', theLanguage);

    var myUrl = Uri.parse('${funcs.mainLink}api/deleteAccount');
    http.post(myUrl, body: {
      "memberId" : memberId,
    }).then((result) async{
      if(result.body.toString() == 'done'){

      }else{

      }
    }).catchError((error) {

    });

    Locales.change(context, theLanguage);
    Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(230, 230, 230, 1),
              ],
              begin: Alignment.topRight,
              end: Alignment.topLeft,
            )
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            Container(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
              child: Column(
                children: <Widget>[
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    elevation: 10.0,
                    child: Container(
                        height: 80.0,
                        width: 80.0,
                        margin: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage('images/inside_logo.png',)
                            )
                        )
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(isLogin == true ? fullName : context.localeString('guest_name'), style: const TextStyle(color: Colors.black87, fontSize: 16), textAlign: TextAlign.center,),
                          ),
                          isLogin == true ? Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(emailAddress, style: const TextStyle(color: Colors.black87, fontSize: 13), textAlign: TextAlign.center,),
                          ):Container(),
                        ],
                      )
                  ),
                ],
              ),
            ),

            isLogin == true ? ListTile(
              title: Text(context.localeString('my_profile'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.userEdit, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()),);
              },
            ):ListTile(
              title: Text(context.localeString('login_page_title'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.signInAlt, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
              },
            ),

            const Divider(),
            ListTile(
              title: Text(context.localeString('about'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.file, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('about')),);
              },
            ),

            const Divider(),
            ListTile(
              title: Text(context.localeString('initiatives'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.list, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => Initiatives()),);
              },
            ),

            isLogin == true ? const Divider():Container(),
            isLogin == true ? ListTile(
              title: Text(context.localeString('events_certificates'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.certificate, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => Certificates()),);
              },
            ):Container(),

            isLogin == true ? const Divider():Container(),
            isLogin == true ? ListTile(
              title: Text(context.localeString('volunteer_certificate'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.certificate, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerCertificate()),);
              },
            ):Container(),

            const Divider(),
            ListTile(
              title: Text(context.localeString('term_conditions'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.fileInvoice, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TextData('terms_and_conditions')),);
              },
            ),

            const Divider(),
            ListTile(
              title: Text(context.localeString('contact'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.phone, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactDetails('1')),);
              },
            ),

            isLogin == true ? const Divider(): Container(),
            isLogin == true ? ListTile(
              title: Text(context.localeString('delete_account'), style: styles.listTileStyle, textAlign: theAlignment),
              leading: FaIcon(FontAwesomeIcons.x, size: 20.0, color: Theme.of(context).secondaryHeaderColor),
              onTap: () {
                Navigator.pop(context);
                deleteAccount();
              },
            ):Container(),

            isLogin == true ? const Divider(color: Colors.transparent): Container(),
            isLogin == true ? Container(
              decoration: styles.primaryButton(context),
              padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 10.0, top: 10.0),
              margin: const EdgeInsets.only(right: 70.0, left: 70.0),
              child: GestureDetector(
                onTap: (){
                  logout();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.localeString('logout'),style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                    const SizedBox(width: 10,),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                            bottomLeft: Radius.circular(50)),
                        color: Colors.white,
                        // border: Border.all(color: const Color.fromRGBO(215, 215, 215, 1))
                      ),
                      padding: const EdgeInsets.all(5),
                      child: FaIcon(FontAwesomeIcons.powerOff, size: 16.0, color: Theme.of(context).secondaryHeaderColor),
                    )
                  ],
                ),
              ),
            ):Container(),

            const SizedBox(height: 100.0,)
          ],
        ),
      ),
    );
  }

}

