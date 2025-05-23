import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Funcs {

  final String mainLink = 'https://wafyapp.osamayu.com/';
  final String mainMediaLink = 'https://wafyapp.osamayu.com/';

  DateTime now = DateTime.now();

  late bool isLogin = false;
  late String memberId;
  Random rnd = Random();

  generateActivationCode() {
    int min = 10000,
        max = 99999;
    int r = min + rnd.nextInt(max - min);
    return r.toString();
  }

  String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '۳', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }

    return input;
  }


  String removeCharacterFromMobile(String input) {
    const space = ['', '', '', '', ''];
    const characters = ['(', ')','+','-',' '];

    for (int i = 0; i < space.length; i++) {
      input = input.replaceAll(characters[i], space[i]);
    }

    return input;
  }

  numbersToHuman(int theNumber){
    return NumberFormat.compact().format(theNumber);
  }


  Future<String> joinEvent(String eventId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('memberId')!;
    late String response;

    await http.post(Uri.parse('${mainLink}api/joinEvent'), body: {
      "memberId" : memberId,
      "eventId": eventId
    }).then((result) async{
      var theResult = json.decode(result.body);
      response = theResult['theResult'].toString();
    }).catchError((error) {
      print(error);
      response = '0';
    });

    return response;
  }

  Future<String> deleteJoinEvent(String eventId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('memberId')!;
    late String response;

    await http.post(Uri.parse('${mainLink}api/deleteJoinEvent'), body: {
      "memberId" : memberId,
      "eventId": eventId
    }).then((result) async{
    var theResult = json.decode(result.body);
      response = theResult['theResult'].toString();
    }).catchError((error) {
      print(error);
      response = '0';
    });

    return response;
  }

  Future<String> checkJoinEvent(String eventId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('memberId')!;
    late String response;

    await http.post(Uri.parse(mainLink+'api/checkJoinedMembers'), body: {
      "memberId" : memberId,
      "eventId": eventId
    }).then((result) async{
      var theResult = json.decode(result.body);
      response = theResult['theResult'].toString();
    }).catchError((error) {
      print(error);
      response = '0';
    });

    return response;
  }

  void openLink(String theLink, String theType, String theMode) async {
    if(theLink.isNotEmpty){
      if(theType == 'link'){
        theLink = 'https://$theLink';
      }else if(theType == 'link_without'){
        theLink = theLink;
      }else if(theType == 'email'){
        theLink = 'mailto:$theLink';
      }else if(theType == 'whatsapp'){
        theLink = 'whatsapp://send?phone=$theLink';
      }else if(theType == 'tel'){
        theLink = 'tel:$theLink';
      }else{
        theLink = theLink;
      }
      var myUrl = Uri.parse(theLink);
      if (await canLaunchUrl(myUrl)) {

        if(theMode == 'pdf'){
          await launchUrl(myUrl,mode: LaunchMode.externalApplication);
        }else{
          await launchUrl(myUrl);
        }
      }
    }else{
      print('noLink');
    }

  }

}
