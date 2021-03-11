
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';


//Testing Credentionals
// Client Code = ABN01
// Username = sdfggdsg_1210
// Password = ABN_SP1210
// Authentication KEY = wRAKcWb8WjGSU8Z2
// Authentication IV = 9oaIkb7SCYunVDYg

//Live Credentionals
// Client Code = UPHAJ
// Username = bhabesh.jha_3249
// Password = UPHAJ_SP3249
// Authentication KEY = Uf8lXNCJCaZxLsIJ
// Authentication IV = NhaJtiHpHGT5t28Q


class Auth {
  static const AUTH_KEY = "wRAKcWb8WjGSU8Z2";
  static const AUTH_IV = "9oaIkb7SCYunVDYg";
}

class Constants {
  static const TESTING_PAYMENT = "https://uatsp.sabpaisa.in/SabPaisa/sabPaisaInit"; //use
  static const LIVE_PAYMENT = "https://securepay.sabpaisa.in/SabPaisa/sabPaisaInit"; //use
  static const RETURN_BASE_URL = "http://opencart-local.com/"; //use
  static const PAYMENT_SUCCESS_URL = RETURN_BASE_URL+"index.php?route=extension/payment/sabpaisa/notify/";
  static const PAYMENT_FAILURE_URL = RETURN_BASE_URL+"index.php?route=extension/payment/sabpaisa/notify/";
  static const PAYMENT_URL = TESTING_PAYMENT;
}

class PaymentProcess extends StatelessWidget {
  // Declare a field that holds the RechargeValues data
  final RechargeValues rechargevalues;

  const PaymentProcess({Key key,@required this.rechargevalues}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: PaymentGetwayPage(rechargevalues: rechargevalues),
      ),
    );
  }
}

class PaymentGetwayPage extends StatefulWidget {
  final RechargeValues rechargevalues;

  const PaymentGetwayPage({Key key, this.rechargevalues}) : super(key: key);
  @override
  _PaymentGetwayPageState createState() => _PaymentGetwayPageState(rechargevalues: rechargevalues);
}
enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class _PaymentGetwayPageState extends State<PaymentGetwayPage> {
  String _webViewURL = "";
  bool _loader = true;
  final RechargeValues rechargevalues;
  _PaymentGetwayPageState({this.rechargevalues});
  Future<Recharge> futureAlbum;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    getUrlString(rechargevalues);
  }
  // set checksum value and create payment URL
  void getUrlString(postData){
    String queryString = "";
    var _list = jsonEncode(postData);
    Map<String, dynamic> myMap = json.decode(_list);
    var data = postData;

    var urlQueryString = "clientName=" + data._clientName
        +"&usern="+data._usern
        +"&pass="+data._pass
        +"&amt="+data._amt
        +"&txnId="+data._txnId
        +"&firstName="+data._firstName
        +"&lstName="+data._lstName
        +"&contactNo="+data._contactNo
        +"&Email="+data._Email
        +"&Add="+data._Add
        +"&ru="+data._ru
        +"&failureURL="+data._failureURL;

    myMap.forEach((key, value) {
      if(key != 'amt' && key != 'clientName'){
        queryString += key.toString() +value.toString();
      }
    });
urlQueryString="query="+urlQueryString+"&clientName="+data._clientName;

    var utf8Key = utf8.encode(Auth.AUTH_KEY);
    var hmacSha256 = new Hmac(sha256, utf8Key);
    var bytes = utf8.encode(queryString);
    Digest sha256Result = hmacSha256.convert(bytes);

    var base64EncodeValue = base64Encode(sha256Result.bytes);
    base64EncodeValue = base64EncodeValue.replaceAll(new RegExp(r"\s\b|\b\s"), "").replaceAll("\\+", "%2B");

    queryString = urlQueryString + "&checkSum=" + base64EncodeValue;
    var url = Constants.PAYMENT_URL +"?"+ queryString;

    setState(() {
      _webViewURL = url;
      _loader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Recharge>(
          builder: (context, snapshot) {
            if ('$_webViewURL' != null &&  !_loader) {
              return WebView(
                initialUrl: '$_webViewURL',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) async {
                 _controller.complete(webViewController);
                },
                navigationDelegate: (NavigationRequest request) {
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  var SabPaisaTxId = "";
                  var amount = "";
                  var clientTxnId = "";
                  var payMode = "";
                  var transDate = "";
                  var reMsg = "";
                  if (url.startsWith(Constants.RETURN_BASE_URL)) {
                    var urlData = Uri.dataFromString(url).queryParameters;
                    setState(() {
                      _loader = true;
                      _webViewURL = "";
                    });
                    urlData.forEach((key, value) {
                      if(key == 'SabPaisaTxId'){
                        SabPaisaTxId = value;
                      }
                      if(key == 'amount'){
                        amount = value;
                      }
                      if(key == 'clientTxnId'){
                        clientTxnId = value;
                      }
                      if(key == 'payMode'){
                        payMode = value;
                      }
                      if(key == 'transDate'){
                        transDate = value;
                      }
                      if(key == 'reMsg'){
                        reMsg = value;
                      }
                      if(key == 'spRespStatus' && value == 'SUCCESS'){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentSuccessPage(processcomplete: new ProcessComplete(SabPaisaTxId: SabPaisaTxId,
                            amount: amount,
                            clientTxnId: clientTxnId,
                            payMode: payMode,
                            transDate: transDate,
                            reMsg: reMsg))));
                      }else if(key == 'spRespStatus' && value == 'FAILED'){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentFailurePage(processcomplete: new ProcessComplete(reMsg: reMsg))));
                      }
                    });
                  }
                },
                gestureNavigationEnabled: true,
              );
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatefulWidget {
  final ProcessComplete processcomplete;

  const PaymentSuccessPage({Key key, this.processcomplete}) : super(key: key);
  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState(processcomplete: processcomplete);
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final ProcessComplete processcomplete;
  _PaymentSuccessPageState({this.processcomplete});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: <Widget>[
            Text(processcomplete.reMsg.replaceAll("%20", ' '), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
            SizedBox(
              height: 15.0,
            ),
            Text('SabPaisaTxId: '+processcomplete.SabPaisaTxId.replaceAll("%20", ' '),textAlign: TextAlign.left,),
            SizedBox(
              height: 15.0,
            ),
            Text('ClientTxnId: '+processcomplete.clientTxnId.replaceAll("%20", ' '),textAlign: TextAlign.left,),
            SizedBox(
              height: 15.0,
            ),
            Text('Payment Mode: '+processcomplete.payMode.replaceAll("%20", ' '),textAlign: TextAlign.left,),
            SizedBox(
              height: 15.0,
            ),
            Text('Amount: '+processcomplete.amount.replaceAll("%20", ' '),textAlign: TextAlign.left,),
            SizedBox(
              height: 15.0,
            ),
            Text('Transaction Date: '+processcomplete.transDate.replaceAll("%20", ' '),textAlign: TextAlign.left,),
            SizedBox(
              height: 15.0,
            ),
            RaisedButton(
              child: Text("return to home"),
              elevation: 9.0,
              onPressed: () {
                debugPrint("go to home");
                //Navigator.push(context, MaterialPageRoute(builder: (context) => homescreen()));
              },
            ),
          ],
        ),

        //CircularProgressIndicator()
      ),
    );
  }

}

class PaymentFailurePage extends StatefulWidget {
  final ProcessComplete processcomplete;

  const PaymentFailurePage({Key key, this.processcomplete}) : super(key: key);
  @override
  _PaymentFailurePageState createState() => _PaymentFailurePageState(processcomplete: processcomplete);
}

class _PaymentFailurePageState extends State<PaymentFailurePage> {
  final ProcessComplete processcomplete;
  _PaymentFailurePageState({this.processcomplete});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child:Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(processcomplete.reMsg.replaceAll("%20", ' '),style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),),
            SizedBox(
              height: 15.0,
            ),
            RaisedButton(
              child: Text("Retry Payment"),
              elevation: 9.0,
              onPressed: () {
                debugPrint("go to home");
                //Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
              },
            ),
          ],
        ),

        //CircularProgressIndicator()
      ),
    );
  }

}

class RechargeValues {

  // usern
  String _Add;
  String _Email;
  String _amountType;
  String _channelId;
  String _contactNo;
  String _failureURL;
  String _firstName;
  String _grNumber;
  String _lstName;
  String _midName;
  String _param1;
  String _param2;
  String _param3;
  String _param4;
  String _pass;
  String _programId;
  String _ru;
  String _sem;
  String _studentUin;
  String _txnId;
  String _udf10;
  String _udf11;
  String _udf12;
  String _udf13;
  String _udf14;
  String _udf15;
  String _udf16;
  String _udf17;
  String _udf18;
  String _udf19;
  String _udf20;
  String _udf5;
  String _udf6;
  String _udf7;
  String _udf8;
  String _udf9;
  String _usern;
  String _clientName;
  String _amt;
  

  RechargeValues({@required String Add = "",
    String Email = "",
    String amountType = "",
    String channelId = "",
    String contactNo = "",
    String failureURL = Constants.PAYMENT_FAILURE_URL,
    String firstName = "",
    String grNumber = "",
    String lstName = "",
    String midName = "",
    String param1 = "",
    String param2 = "",
    String param3 = "",
    String param4 = "",
    String pass = "",
    String programId = "",
    String ru = Constants.PAYMENT_SUCCESS_URL,
    String sem = "",
    String studentUin = "",
    String txnId = "",
    String udf10 = "",
    String udf11 = "",
    String udf12 = "",
    String udf13 = "",
    String udf14 = "",
    String udf15 = "",
    String udf16 = "",
    String udf17 = "",
    String udf18 = "",
    String udf19 = "",
    String udf20 = "",
    String udf5 = "",
    String udf6 = "",
    String udf7 = "",
    String udf8 = "",
    String udf9 = "",
    String usern = "",
    String clientName,
    String amt = ""}) :
        _Add = Add,
        _Email = Email,
        _amountType = amountType,
        _channelId = channelId,
        _contactNo = contactNo,
        _failureURL = failureURL,
        _firstName = firstName,
        _grNumber = grNumber,
        _lstName = lstName,
        _midName = midName,
        _param1 = param1,
        _param2 = param2,
        _param3 = param3,
        _param4 = param4,
        _pass = pass,
        _programId = programId,
        _ru = ru,
        _sem = sem,
        _studentUin = studentUin,
        _txnId = txnId,
        _udf10 = udf10,
        _udf11 = udf11,
        _udf12 = udf12,
        _udf13 = udf13,
        _udf14 = udf14,
        _udf15 = udf15,
        _udf16 = udf16,
        _udf17 = udf17,
        _udf18 = udf18,
        _udf19 = udf19,
        _udf20 = udf20,
        _udf5 = udf5,
        _udf6 = udf6,
        _udf7 = udf7,
        _udf8 = udf8,
        _udf9 = udf9,
        _usern = usern,// optional parameter with default value ""
        _clientName = clientName,// required parameter
        _amt = amt; // optional parameter without default value

  RechargeValues.fromJson(Map<String, dynamic> json)
      : _Add = json['Add'],
        _Email = json['Email'],
        _amountType = json['amountType'],
        _channelId = json['channelId'],
        _contactNo = json['contactNo'],
        _failureURL = json['failureURL'],
        _firstName = json['firstName'],
        _grNumber = json['grNumber'],
        _lstName = json['lstName'],
        _midName = json['midName'],
        _param1 = json['param1'],
        _param2 = json['param2'],
        _param3 = json['param3'],
        _param4 = json['param4'],
        _pass = json['pass'],
        _programId = json['programId'],
        _ru = json['ru'],
        _sem = json['sem'],
        _studentUin = json['studentUin'],
        _txnId = json['txnId'],
        _udf10 = json['udf10'],
        _udf11 = json['udf11'],
        _udf12 = json['udf12'],
        _udf13 = json['udf13'],
        _udf14 = json['udf14'],
        _udf15 = json['udf15'],
        _udf16 = json['udf16'],
        _udf17 = json['udf17'],
        _udf18 = json['udf18'],
        _udf19 = json['udf19'],
        _udf20 = json['udf20'],
        _udf5 = json['udf5'],
        _udf6 = json['udf6'],
        _udf7 = json['udf7'],
        _udf8 = json['udf8'],
        _udf9 = json['udf9'],
        _usern = json['usern'],
        _clientName = json['clientName'],
        _amt = json['amt'];

  Map<String, dynamic> toJson() {
    return {
      'Add': _Add,
      'Email': _Email,
      'amountType': _amountType,
      'channelId': _channelId,
      'contactNo': _contactNo,
      'failureURL': _failureURL,
      'firstName': _firstName,
      'grNumber': _grNumber,
      'lstName': _lstName,
      'midName': _midName,
      'param1': _param1,
      'param2': _param2,
      'param3': _param3,
      'param4': _param4,
      'pass': _pass,
      'programId': _programId,
      'ru': _ru,
      'sem' : _sem,
      'studentUin': _studentUin,
      'txnId': _txnId,
      'udf10': _udf10,
      'udf11': _udf11,
      'udf12': _udf12,
      'udf13': _udf13,
      'udf14': _udf14,
      'udf15': _udf15,
      'udf16': _udf16,
      'udf17': _udf17,
      'udf18': _udf18,
      'udf19': _udf19,
      'udf20': _udf20,
      'udf5': _udf5,
      'udf6': _udf6,
      'udf7': _udf7,
      'udf8': _udf8,
      'udf9': _udf9,
      'usern': _usern,
      'clientName': _clientName,
      'amt': _amt,
    };
  }

}

class ProcessComplete {

  // usern
  String SabPaisaTxId;
  String amount;
  String clientTxnId;
  String payMode;
  String transDate;
  String reMsg;

  ProcessComplete({@required String SabPaisaTxId = "",
    String amount = "",
    String clientTxnId = "",
    String payMode = "",
    String transDate = "",
    String reMsg = ""}) :
        SabPaisaTxId = SabPaisaTxId,
        amount = amount,
        clientTxnId = clientTxnId,
        payMode = payMode,
        transDate = transDate,
        reMsg = reMsg; // optional parameter without default value

  ProcessComplete.fromJson(Map<String, dynamic> json)
      : SabPaisaTxId = json['SabPaisaTxId'],
        amount = json['amount'],
        clientTxnId = json['clientTxnId'],
        payMode = json['payMode'],
        transDate = json['transDate'],
        reMsg = json['reMsg'];

  Map<String, dynamic> toJson() {
    return {
      'SabPaisaTxId': SabPaisaTxId,
      'amount': amount,
      'clientTxnId': clientTxnId,
      'payMode': payMode,
      'transDate': transDate,
      'reMsg': reMsg,
    };
  }

}

// Model  layer for payment Process
class Recharge {
  final dynamic bankUrl;
  Recharge({this.bankUrl});
  factory Recharge.fromJson(Map<String, dynamic> json) {
    return Recharge(
      bankUrl: json['bankUrl'],
    );
  }
}

// Service layer for payment Process
class Services {

  Future<Recharge> getDecryptedString(rechargeentity) async {
    String body = json.encode(rechargeentity);
    final response =
    await http.post(
      Constants.TESTING_PAYMENT,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Recharge.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<Recharge> sabpaisaResponse(rechargeentity) async {
    String body = json.encode(rechargeentity);
    Random random = new Random();
    final response =
    await http.post(
      Constants.TESTING_PAYMENT,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Recharge.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

}