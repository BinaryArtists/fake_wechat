import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fake_wechat/fake_wechat.dart';

void main() {
  runZoned(() {
    runApp(new MyApp());
  }, onError: (dynamic error, dynamic stack) {
    print(error);
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FakeWechat wechat = new FakeWechat();
    wechat.registerApp(appId: 'wx854345270316ce6e');// 更换为目标应用的appId
    return new FakeWechatProvider(
        wechat: wechat,
        child: new MaterialApp(
          home: new Home(
            wechat: wechat,
          ),
        ));
  }
}

class Home extends StatefulWidget {
  final FakeWechat wechat;

  Home({
    Key key,
    @required this.wechat,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }
}

class _HomeState extends State<Home> {
  StreamSubscription<FakeWechatAuthResp> _auth;
  StreamSubscription<FakeWechatShareMsgResp> _share;

  @override
  void initState() {
    super.initState();
    _auth = widget.wechat.authResp().listen(_listenAuth);
    _share = widget.wechat.shareMsgResp().listen(_listenShareMsg);
  }

  void _listenAuth(FakeWechatAuthResp resp) {
    String content = 'auth: ${resp.errorCode} ${resp.errorMsg}';
    _showTips('登录', content);
  }

  void _listenShareMsg(FakeWechatShareMsgResp resp) {
    String content = 'auth: ${resp.errorCode} ${resp.errorMsg}';
    _showTips('分享', content);
  }

  @override
  void dispose() {
    if (_auth != null) {
      _auth.cancel();
    }
    if (_share != null) {
      _share.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Fake Wechat Demo'),
      ),
      body: new ListView(
        children: <Widget>[
          new ListTile(
            title: new Text('环境检查'),
            onTap: () async {
              String content =
                  'wechat: ${await widget.wechat.isWechatInstalled()} - ${await widget.wechat.isWechatSupportApi()}';
              _showTips('环境检查', content);
            },
          ),
          new ListTile(
            title: new Text('登录'),
            onTap: () {
              widget.wechat.auth(
                scope: [FakeWechatScope.SNSAPI_USERINFO],
                state: 'auth',
              );
            },
          ),
          new ListTile(
            title: new Text('文字分享'),
            onTap: () {
              widget.wechat.shareText(
                scene: FakeWechatScene.TIMELINE,
                text: 'Share Text',
              );
            },
          ),
          new ListTile(
            title: new Text('图片分享'),
            onTap: () async {
              AssetImage image = new AssetImage('images/icon/timg.jpeg');
              AssetBundleImageKey key = await image.obtainKey(createLocalImageConfiguration(context));
              ByteData imageData = await key.bundle.load(key.name);
              widget.wechat.shareImage(
                  scene: FakeWechatScene.TIMELINE,
                  imageData: imageData.buffer.asUint8List()
              );
            },
          ),
          new ListTile(
            title: new Text('网页分享'),
            onTap: () {
              widget.wechat.shareWebpage(
                  scene: FakeWechatScene.TIMELINE,
                  webpageUrl: 'https://www.baidu.com'
              );
            },
          )
        ],
      ),
    );
  }

  void _showTips(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(title),
          content: new Text(content),
        );
      },
    );
  }
}
