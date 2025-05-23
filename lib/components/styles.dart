import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:weareforyou/gui/initiatives_details.dart';
import 'package:weareforyou/gui/login.dart';
import 'package:weareforyou/gui/register.dart';
import 'package:weareforyou/gui/forget_password.dart';
import 'package:weareforyou/gui/events_details.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:html/parser.dart';

class Styles{

  TextStyle topSliderText = const TextStyle(color:Color.fromRGBO(14, 46, 76, 1), fontSize: 13.0, fontFamily: 'Cairo');
  TextStyle listTileStyle = const TextStyle(color: Colors.black87, fontSize: 16.0, fontFamily: 'Cairo');
  TextStyle listSubTileStyle = const TextStyle(color: Colors.black38, fontSize: 12.0, fontFamily: 'Cairo');
  TextStyle listTileNoDataStyle = const TextStyle(color: Colors.black45, fontSize: 16.0, fontFamily: 'Cairo');
  TextStyle listTileTitleStyle = const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16.0,);
  TextStyle dialogData = const TextStyle(color: Colors.black87, fontSize: 16.0, fontFamily: 'Cairo');
  TextStyle appBarActionBtn = const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Color.fromRGBO(14, 46, 76, 1));
  TextStyle inputTextStyle = const TextStyle(color: Colors.black87, fontSize: 14.0);
  TextStyle inputTextHintStyle = const TextStyle(color: Colors.black45, fontSize: 14.0);
  Color deleteColor =  Colors.red;
  TextStyle startBtn = const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 15.0);
  TextStyle done = const TextStyle(color: Colors.green, fontFamily: 'Cairo', fontSize: 20.0);
  TextStyle titleData = const TextStyle(color: Colors.black87, fontSize: 15.0, fontFamily: 'Cairo');
  TextStyle activeBtn = const TextStyle(color: Colors.white, fontSize: 13.0);
  TextStyle inActiveBtn = const TextStyle(color: Color.fromRGBO(14, 46, 76, 1), fontSize: 13.0);
  TextStyle nameTitle = const TextStyle(color: Color.fromRGBO(14, 46, 76, 1), fontWeight: FontWeight.bold, fontSize: 16.0, fontFamily: 'Cairo');
  TextStyle statisticsCount = const TextStyle(color: Color.fromRGBO(14, 46, 76, 1), fontSize: 22.0, fontWeight: FontWeight.bold, fontFamily: 'Cairo');
  TextStyle theDate = const TextStyle(color: Colors.black54, fontSize: 14.0, fontFamily: 'Cairo');
  TextStyle redDate = const TextStyle(color: Colors.red, fontSize: 14.0, fontWeight: FontWeight.bold, fontFamily: 'Cairo');
  TextStyle partOfDetails = const TextStyle(color: Colors.black54, fontSize: 13.0, fontFamily: 'Cairo');
  TextStyle detailsInList = const TextStyle(color: Colors.black87, fontSize: 13.0, fontFamily: 'Cairo');
  TextStyle paragraphTitle = const TextStyle(color: Color.fromRGBO(14, 46, 76, 1), fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 16.0); // for titles
  TextStyle descTitle = const TextStyle(color: Colors.black87, fontSize: 11.0, fontFamily: 'Cairo');
  TextStyle contactLinks = const TextStyle(color: Color.fromRGBO(14, 46, 76, 1), fontSize: 13.0, fontFamily: 'Cairo');
  TextStyle tabsTitle = const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16.0);
  TextStyle errorMsg = const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15.0);

  var funcs = Funcs();


  Widget widgetEvents(scaffoldKey,context, bool isLogin, String theLanguage, dataList, index, thePage){

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    var formattedDate = formatter.format(now);

    return GestureDetector(
      onTap: ()=> Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return EventsDetails(dataList[index].evId, dataList[index].theTitle, dataList[index].thePhoto);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      )),
      child: Container(
        margin: const EdgeInsets.only(top:10.0, bottom: 10.0, right: 10.0, left: 10.0),
        decoration: DateTime.parse(dataList[index].theDate).compareTo(DateTime.parse(formattedDate)) >= 0 ? cardBoxDecoration(context) : inactiveCardBoxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10.0,),
            Stack(
              children: <Widget>[
                Container(
                  width: thePage == 'mainPage' ? 300.0 : double.infinity,
                  height: 190.0,
                  margin: const EdgeInsets.only(top:0.0),
                  decoration: BoxDecoration(
                      image: dataList[index].thePhoto != null && dataList[index].thePhoto != '' ? DecorationImage(
                        fit: BoxFit.contain,
                        image: NetworkImage("${funcs.mainMediaLink}public/uploads/php/files/events/thumbnail/${dataList[index].thePhoto}"),
                      ):const DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('images/logo.png',)
                      )
                  ),
                ),
                dataList[index].location.isNotEmpty ? Positioned(
                  right: 10.0,
                  bottom: 10.0,
                  child: GestureDetector(
                    onTap: (){
                      funcs.openLink(dataList[index].location,'link_without','');
                    },
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60.0),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 1.0,
                            ),
                          ]
                      ),
                      child: Center(
                        child: Icon(Icons.pin_drop, color: Theme.of(context).secondaryHeaderColor),
                      ),
                    ),
                  ),
                ):Container()
              ],
            ),
            const SizedBox(height: 10.0,),
            Container(
                width: thePage == 'mainPage' ? 300.0 : double.infinity,
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 3.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: theLanguage == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    dataList[index].theTime == '00:00:00' ? Container(
                      width: double.infinity,
                      child: Text('${DateFormat('dd/MM/yyyy').format(DateTime.parse(dataList[index].theDate))} - ${DateFormat('EEEE', 'Ar_ar').format(DateTime.parse(dataList[index].theDate))}', style: DateTime.parse(dataList[index].theDate).compareTo(DateTime.parse(formattedDate)) >= 0 ? theDate : redDate, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ):Container(
                      width: double.infinity,
                      child: Text('${DateFormat('dd/MM/yyyy').format(DateTime.parse(dataList[index].theDate))} - ${DateFormat('EEEE', 'Ar_ar').format(DateTime.parse(dataList[index].theDate))}  \n ${DateFormat('h:mm a').format(DateTime.parse((dataList[index].theDate+'T'+dataList[index].theTime).toString()))}', style: DateTime.parse(dataList[index].theDate).compareTo(DateTime.parse(formattedDate)) >= 0 ? theDate : redDate, textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left),
                    ),
                    Container(
                      width: double.infinity,
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        strutStyle: const StrutStyle(fontSize: 15.0),
                        textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left,
                        text: TextSpan(
                          style: nameTitle,
                          text: '${dataList[index].theTitle}',
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        strutStyle: const StrutStyle(fontSize: 15.0),
                        textAlign: theLanguage == 'ar' ? TextAlign.right:TextAlign.left,
                        text: TextSpan(
                            style: partOfDetails ,
                            text: _parseHtmlString(dataList[index].theDetails)),
                      ),
                    ),
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    RegExp exp = RegExp(
        r'<[^>]*>|&[^;]+;',
        multiLine: true,
        caseSensitive: true
    );
    return htmlString.replaceAll(exp, '');
  }

  Widget widgetInitiatives(scaffoldKey,context, bool isLogin, String theLanguage, dataList, index){

    return GestureDetector(
      onTap: ()=> Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return InitiativesDetails(dataList[index].inId, dataList[index].theTitle, dataList[index].thePhoto);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      )),
      child: Container(
        margin: const EdgeInsets.only(top:10.0, bottom: 10.0, right: 10.0, left: 10.0),
        decoration: cardBoxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 200.0,
                  margin: const EdgeInsets.only(top:0.0),
                  decoration: BoxDecoration(
                      image: dataList[index].thePhoto != null && dataList[index].thePhoto != '' ? DecorationImage(
                        fit: BoxFit.contain,
                        image: NetworkImage("${funcs.mainMediaLink}public/uploads/php/files/initiatives/thumbnail/${dataList[index].thePhoto}"),
                      ):const DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('images/logo.png',)
                      )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0.0,),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 3.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: theLanguage == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        strutStyle: const StrutStyle(fontSize: 15.0),
                        textAlign: theLanguage == 'ar' ? TextAlign.center:TextAlign.center,
                        text: TextSpan(
                          style: nameTitle,
                          text: '${dataList[index].theTitle}',
                        ),
                      ),
                    ),
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }


  showSnackBar(context, String message, String theType, String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: theType == 'error' ? Colors.red:Colors.green,
      content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
      action: action == 'forget_password' ? SnackBarAction(
          label: Locales.string(context, 'forget_password'),
          textColor: Colors.white,
          onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()),)
      ):null,
    ));
  }

  void onLoading(context) {
      showDialog(
        context: context,
        barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 2,
                  ),
                ],
              ),
            );
          }

      );
    }

  void needLoginModalBottomSheet(context){

    String loginTitle;
    String registerTitle;
    String sheetTitle;
    String sheetDesc;

    sheetTitle = Locales.string(context, 'need_login_title');
    sheetDesc = Locales.string(context, 'need_login_text');
    loginTitle = Locales.string(context, 'login_page_title');
    registerTitle = Locales.string(context, 'do_not_have_account');

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(sheetTitle, style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Cairo', fontSize: 22.0,), textAlign: TextAlign.center),
                  subtitle: Text(sheetDesc, style: const TextStyle(color: Colors.black45, fontFamily: 'Cairo', fontSize: 14.0,), textAlign: TextAlign.center),
                ),
                const Divider(height: 15.0,color: Colors.black38,),
                ListTile(
                  title: Text(loginTitle, style: const TextStyle(color: Colors.black87, fontFamily: 'Cairo', fontSize: 17.0,), textAlign: TextAlign.center),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),),
                ),
                const Divider(height: 15.0,color: Colors.black38,),
                ListTile(
                  title: Text(registerTitle, style: const TextStyle(color: Colors.black87, fontFamily: 'Cairo', fontSize: 17.0,), textAlign: TextAlign.center),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Register()),),
                ),
              ],
            ),
          );
        }
    );
  }

  PreferredSizeWidget theAppBar(context, bool isLoading, String theLanguage, String theTitle, bool backBtn){
    return AppBar(
      title: isLoading == false ? Text(theTitle, style: Theme.of(context).textTheme.labelMedium):const Text(''),
//      leading: backBtn == false ? Builder(builder: (context) => // Ensure Scaffold is in context
//        IconButton(
//            icon: const Icon(Icons.menu),
//            onPressed: () => Scaffold.of(context).openDrawer()
//        ),
//      ):null,
      automaticallyImplyLeading: backBtn,
//      backgroundColor: Theme.of(context).primaryColor,
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
      centerTitle: true,
    );
  }

  BoxDecoration cardBoxDecoration(context) {
    return const BoxDecoration(
//            borderRadius: BorderRadius.circular(0.0),
        borderRadius: BorderRadius.only(
          topRight:  Radius.circular(0),
          topLeft:  Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
          ),
        ]
    );
  }

  BoxDecoration inactiveCardBoxDecoration(context) {
    return const BoxDecoration(
//            borderRadius: BorderRadius.circular(0.0),
        borderRadius: BorderRadius.only(
          topRight:  Radius.circular(0),
          topLeft:  Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        color: Color.fromRGBO(225, 225, 225, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
          ),
        ]
    );
  }

  BoxDecoration importantBoxDecoration(context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(150.0),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).secondaryHeaderColor.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 3,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }


  BoxDecoration socialMediaBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 3,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }

  BoxDecoration activeTabsBoxDecoration(context) {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor),
      ),
      color: Colors.transparent,
    );
  }


  BoxDecoration primaryButton(context) {
    return BoxDecoration(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
          bottomLeft: Radius.circular(50)),
      color: Theme.of(context).primaryColor,
      // border: Border.all(color: const Color.fromRGBO(215, 215, 215, 1))
    );
  }

  BoxDecoration secondaryButton(context) {
    return BoxDecoration(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
          bottomLeft: Radius.circular(50)),
      color: Theme.of(context).secondaryHeaderColor,
      // border: Border.all(color: const Color.fromRGBO(215, 215, 215, 1))
    );
  }


  // Future<void> onOpenLink(LinkableElement link) async {
  //   if (await canLaunch(link.url)) {
  //     await launch(link.url);
  //   } else {
  //     throw 'Could not launch $link';
  //   }
  // }

}

