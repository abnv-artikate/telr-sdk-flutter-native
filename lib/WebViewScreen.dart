
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';
import 'helper/global_utils.dart';

import 'helper/network_helper.dart';
class WebviewScreen extends StatefulWidget {

  static const String id = 'webview_screen';
  // late final String title;
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}
class _WebviewScreenState extends State<WebviewScreen>{
  var _url = '';
  var random = new Random();
  String _session = '';
  String redirectionurl='';
  String _session2='';
  bool _loadWebView = false;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _con ;
  //_cardgetcardtokenapi();

  void _cardgetcardtokenapi()async{
    NetWorkHelper netWorkHelper = NetWorkHelper();
    dynamic response = await netWorkHelper.getcardtoken(GlobalUtils.storeid,GlobalUtils.cardnumber,GlobalUtils.cardexpirymonth,GlobalUtils.cardexpiryyr,GlobalUtils.cardcvv);

    if (response == null) {
      // no data show error message.
    } else {
      if (response.toString().contains('Failure')) {
        // _showLoader = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No data to show"),
        ));
      }
      else {

        // List<dynamic> list = <dynamic>[];
        // flutter: {SavedCardListResponse: {Code: 200, Status: Success, data: [{Transaction_ID: 040029158825, Name: Visa Credit ending with 0002, Expiry: 4/25}, {Transaction_ID: 040029158777, Name: MasterCard Credit ending with 0560, Expiry: 4/24}]}}
        var token = response['CardTokenResponse']['Token'].toString();
        GlobalUtils.token=token;
        if(GlobalUtils.token.length>3){
          createXMLAfterGetCard();
        }

      }
    }
  }







  String _homeText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cardgetcardtokenapi();
    //_callApi();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('New Card'),
        backgroundColor: Color(0xff00A887),
      ),
      body: _loadWebView? Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          width: 800,//MediaQuery.of(context).size.width
          height: 1800,//MediaQuery.of(context).size.height
          child: WebView(
            initialUrl: _url, //ooooo
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              // _controller.complete(webViewController);
              _con = webViewController;
              //  _loadHTML();
            },
            onProgress: (int progress) {

            },
            navigationDelegate: (NavigationRequest request) {

              if (request.url.contains('telr.com')) {

                // setState(() {
                //   _loadWebView = false;
                //   _homeText = 'Loading second api';
                //
                // });
                //_callresponseApi();
                //  return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {

            },
            onPageFinished: (String url) {

              if (url.contains('telr.com'))
              {
                //here
              }
            },
            gestureNavigationEnabled: true,
          ),
        );
      }): Text(_homeText),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,


    );
  }






  void createXMLAfterGetCard(){
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('mobile', nest: () {
      builder.element('store', nest: (){
        builder.text(GlobalUtils.storeid);
      });
      builder.element('key', nest: (){
        builder.text(GlobalUtils.authkey); //N2RnZ-Ljdr@5n2ZB
      });
      builder.element('framed',nest:(){
        builder.text(GlobalUtils.framed);
      });

      builder.element('device', nest: (){
        builder.element('type', nest: (){
          builder.text(GlobalUtils.devicetype);
        });
        builder.element('id', nest: (){
          builder.text(GlobalUtils.deviceid);
        });
      });

      // app
      builder.element('app', nest: (){
        builder.element('name', nest: (){
          builder.text(GlobalUtils.appname);
        });
        builder.element('version', nest: (){
          builder.text(GlobalUtils.version);
        });
        builder.element('user', nest: (){
          builder.text(GlobalUtils.appuser);
        });
        builder.element('id', nest: (){
          builder.text(GlobalUtils.appid);
        });
      });

      //tran
      builder.element('tran', nest: (){
        builder.element('test', nest: (){
          builder.text(GlobalUtils.testmode);
        });
        builder.element('type', nest: (){
          builder.text('paypage');
        });
        builder.element('class', nest: (){
          builder.text('sale');
        });
        builder.element('cartid', nest: (){
          builder.text(100000000 + random.nextInt(999999999));
        });
        builder.element('description', nest: (){
          builder.text('Test for Mobile API order');
        });
        builder.element('currency', nest: (){
          builder.text('aed');
        });
        builder.element('amount', nest: (){
          builder.text('2');
        });
        builder.element('language', nest: (){
          builder.text('en');
        });
        // builder.element('firstref', nest: (){
        //   builder.text(GlobalUtils.firstref);
        // });
        // builder.element('ref', nest: (){
        //   builder.text('null');
        // });

      });
//new changes to add savecard option
      builder.element('card', nest: (){
        builder.element('savecard', nest: (){
          builder.text(GlobalUtils.keysaved);
        });

      });
      //---------------------------------
      //billing
      builder.element('billing', nest: (){
        // name
        builder.element('name', nest: (){
          builder.element('title', nest: (){
            builder.text('');
          });
          builder.element('first', nest: (){
            builder.text(GlobalUtils.firstname);
          });
          builder.element('last', nest: (){
            builder.text(GlobalUtils.lastname);
          });
        });
        // address
        builder.element('address', nest: (){
          builder.element('line1', nest: (){
            builder.text(GlobalUtils.addressline1);
          });
          builder.element('city', nest: (){
            builder.text(GlobalUtils.city);
          });
          builder.element('region', nest: (){
            builder.text('');
          });
          builder.element('country', nest: (){
            builder.text(GlobalUtils.country);
          });
        });

        builder.element('phone', nest: (){
          builder.text(GlobalUtils.phone);
        });
        builder.element('email', nest: (){
          builder.text(GlobalUtils.emailId);
        });

      });

      builder.element('custref', nest: (){
        builder.text(GlobalUtils.custref);
      });
      builder.element('paymethod', nest: (){
        builder.element('type', nest: (){
          builder.text(GlobalUtils.paymenttype);
        });
        builder.element('cardtoken', nest: (){
          builder.text(GlobalUtils.token);
        });
      });

    });

    final bookshelfXml = builder.buildDocument();


    pay(bookshelfXml);
  }
  void pay(XmlDocument xml)async{

    NetWorkHelper netWorkHelper = NetWorkHelper();

    final response =  await netWorkHelper.pay(xml);

    if(response == 'failed' || response == null){
      // failed
      // alertShow('Failed');
    }
    else
    {
      final doc = XmlDocument.parse(response);
      final url = doc.findAllElements('start').map((node) => node.text);
      final code = doc.findAllElements('code').map((node) => node.text);

      _url = url.toString();
      String _code = code.toString();
      if(_url.length>2){
        _url =  _url.replaceAll('(', '');
        _url = _url.replaceAll(')', '');
        _code = _code.replaceAll('(', '');
        _code = _code.replaceAll(')', '');
        GlobalUtils.code=_code;
        //_launchURL(_url,_code);
      }

      final message = doc.findAllElements('message').map((node) => node.text);
      setState(() {
        // if
        _loadWebView = true;
      });

      CreateResponseXMLL(); //
      if(message.toString().length>2){
        String msg = message.toString();
        msg = msg.replaceAll('(', '');
        msg = msg.replaceAll(')', '');

        // alertShow(msg);
      }
    }
  }

  // void _callresponseApi()async{
  //   String responsexmlString=CreateResponseXMLL();
  //
  //   //  var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote.xml'); //uat
  //   var uri = Uri.parse('https://secure.telr.com/gateway/mobile_complete.xml');
  //   var response = await http.post(uri,body: responsexmlString);
  //   print('Response 2 =  ${response.statusCode} & ${response.body}');
  //
  // }
  void CreateResponseXMLL(){
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('mobile', nest: () {
      builder.element('store', nest: (){
        builder.text(GlobalUtils.storeid);
      });
      builder.element('key', nest: (){
        builder.text(GlobalUtils.authkey);
      });

      builder.element('complete', nest: (){
        builder.text(GlobalUtils.code);
      });
    });

    final bookshelfXml = builder.buildDocument();


    //return bookshelfXml.toString();
    getTransactionstatus(bookshelfXml);
  }

  void getTransactionstatus(XmlDocument bookshelfXml)async {
    NetWorkHelper netWorkHelper = NetWorkHelper();
    print('Inside 2');
    final response =  await netWorkHelper.getTransactionstatus(bookshelfXml);
    if(response == 'failed' || response == null){
      // failed
      // alertShow('Failed');
    }
    else{
      final doc = XmlDocument.parse(response);

      final trnsstatus = doc.findAllElements('message').map((node) => node.text);

      if(trnsstatus.toString()=='Pending'){
        print('Inside IF');
        getTransactionstatus(bookshelfXml);
      }
      else{
        print('Inside ELSE');
        print(trnsstatus);
      }
    }
  }


}