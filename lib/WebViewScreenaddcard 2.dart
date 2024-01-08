import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';
import 'helper/global_utils.dart';
import 'helper/network_helper.dart';
class WebviewScreenaddcard extends StatefulWidget {

  static const String id = 'webviewaddcard_screen';

  @override
  _WebviewScreenaddcardState createState() => _WebviewScreenaddcardState();
}
class _WebviewScreenaddcardState extends State<WebviewScreenaddcard>{
  var _url = '';
  var random = new Random();
  String _session = '';
  String redirectionurl='';
  String _session2='';
  bool _loadWebView = false;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _con ;


  void _cardgetcardtokenapi()async{
    NetWorkHelper netWorkHelper = NetWorkHelper();
    dynamic response = await netWorkHelper.getcardtoken(GlobalUtils.storeid,GlobalUtils.cardnumber,GlobalUtils.cardexpirymonth,GlobalUtils.cardexpiryyr,GlobalUtils.cardcvv);

    if (response == null) {

    } else {
      if (response.toString().contains('Failure')) {
        // _showLoader = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No data to show"),
        ));
      }
      else {
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
                //add navigation code here
              }

              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {

            },
            onPageFinished: (String url) {

              if (url.contains('telr.com'))
              {
                //add navigation code here
              }
            },
            gestureNavigationEnabled: true,
          ),
        );
      }): Text(_homeText),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      // This trailing comma makes auto-formatting nicer for build methods.
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
        builder.text(GlobalUtils.authkey);
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
          builder.text(GlobalUtils.transtype); //verify for add card
        });
        builder.element('class', nest: (){
          builder.text(GlobalUtils.transclass);
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
        // builder.element('firstref', nest: (){  // parameter for proceed with refid
        //   builder.text(GlobalUtils.firstref);
        // });
        // builder.element('ref', nest: (){  // parameter for proceed with transaction reference
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
      //add the navigation code here
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

      }

      final message = doc.findAllElements('message').map((node) => node.text);
      setState(() {

        _loadWebView = true;
      });

      if(message.toString().length>2){
        String msg = message.toString();
        msg = msg.replaceAll('(', '');
        msg = msg.replaceAll(')', '');

      }
    }
  }


}
