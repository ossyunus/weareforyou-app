import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weareforyou/components/funcs.dart';

class Welcome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WelcomeState();
  }

}



class _WelcomeState extends State<Welcome>{

  late String theLanguage;
  late TextAlign theAlignment;
  late String welcomeTitle;
  bool isLoading = true;

  var funcs = Funcs();

  late Timer _timer;
  int _start = 02;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
    getSharedData().then((result) {
    });

  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
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

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
            if(_start == 0){
              Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
            }
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
//    final double width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 0.0,
                sigmaY: 0.0,
              ),
              child: Center(
                child: Image.asset(
                  'images/logo.png',
                  width: 200.0,
                ),
              ),
            ),
          )
        ],
      ),

    );
  }
}
