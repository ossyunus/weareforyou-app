import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:weareforyou/components/funcs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/gui/main_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weareforyou/gui/events.dart';
import 'package:weareforyou/gui/donate.dart';
import 'package:weareforyou/gui/statistics.dart';

class BottomNavigationBarWidget extends StatefulWidget{
  BottomNavigationBarWidget(this.selectedIndex);
  int selectedIndex;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BottomNavigationBarWidgetState(selectedIndex);
  }

}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>{

  _BottomNavigationBarWidgetState(this.selectedIndex);
  int selectedIndex;

  late String theLanguage = '';
  late String memberId;
  late bool isLogin;
  bool isLoading = false;
  int _selectedIndex = 0;

  var funcs = new Funcs();

  void initState(){
    super.initState();
    setState(() {
      _selectedIndex = selectedIndex;
    });
    getSharedData().then((result) {

    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      memberId = prefs.getString('memberId')!;
      isLogin = prefs.getBool('isLogin')!;
    });
  }

  void _onItemTapped(int index) {
    if(index == 0){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return MainPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }else if(index == 1){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return Events();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }else if(index == 2){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return Statistics();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }else if(index == 3){
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          return Donate('volunteer');
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      ));
    }
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.format_list_bulleted),
          label: context.localeString('home_page_title'),
        ),
        BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.newspaper),
            label: context.localeString('events')
        ),
        BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.chartLine),
            label: context.localeString('statistics')
        ),
        BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.handsHelping),
            label: context.localeString('donation')
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      onTap: _onItemTapped,
    );
  }

}