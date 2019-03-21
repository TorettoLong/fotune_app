import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fotune_app/api/user.dart';
import 'package:fotune_app/componets/CustomAppBar.dart';
import 'package:fotune_app/componets/FInputWidget.dart';
import 'package:fotune_app/componets/LoginFormCode.dart';
import 'package:fotune_app/utils/MD5Utils.dart';
import 'package:fotune_app/utils/ToastUtils.dart';
import 'package:fotune_app/utils/UIData.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  var leftRightPadding = 20.0;
  var topBottomPadding = 4.0;
  var textTips = new TextStyle(fontSize: 13.0, color: Colors.black);
  var hintTips = new TextStyle(fontSize: 13.0, color: Colors.blueGrey);
  bool isCanGetCode = false;
  bool isLogin = false;

//  static const LOGO = "images/oschina.png";

  var _userPassController = new TextEditingController();
  var _userNameController = new TextEditingController();
  var _phoneController = new TextEditingController();
  var _codeController = new TextEditingController();
  var _recommendController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidget.BuildAppBar("注册", context),
      body: new Container(
//        color: UIData.primary_color,
        child: new Center(
          //防止overFlow的现象
          child: SafeArea(
            child: SingleChildScrollView(
              child: new Padding(
                padding:
                    new EdgeInsets.only(left: 20.0, right: 20.0, bottom: 0.0),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CustomWidget.BuildLogImage(),
                    new Padding(padding: new EdgeInsets.all(20.0)),
                    new FInputWidget(
                      hintText: "手机号",
                      iconData: Icons.phone_locked,
                      onChanged: (String value) {
                        print(value);
                      },
                      controller: _phoneController,
                    ),
                    new Padding(padding: new EdgeInsets.all(4.0)),
                    new FInputWidget(
                      hintText: "姓名",
                      iconData: Icons.account_circle,
                      onChanged: (String value) {
                        var ret = value.length >= 11 ? true : false;
                        setState(() {
                          isCanGetCode = ret;
                          print(isCanGetCode);
                        });
                      },
                      controller: _userNameController,
                    ),
                    new Padding(padding: new EdgeInsets.all(4.0)),
                    new FInputWidget(
                      hintText: "密码",
                      iconData: Icons.security,
                      obscureText: true,
                      onChanged: (String value) {
                        print(value);
                      },
                      controller: _userPassController,
                    ),
                    new Padding(padding: new EdgeInsets.all(4.0)),
                    new FInputWidget(
                      hintText: "机构码",
                      iconData: Icons.security,
                      obscureText: true,
                      onChanged: (String value) {
                        print(value);
                      },
                      controller: _recommendController,
                    ),
                    new Padding(padding: new EdgeInsets.all(4.0)),
                    Container(
                      child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: new FInputWidget(
                              hintText: "验证码",
                              iconData: Icons.verified_user,
                              obscureText: true,
                              onChanged: (String value) {
                                print(value);
                              },
                              controller: _codeController,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: LoginFormCode(
                              available:
                                  _phoneController.text.trim().length >= 11,
                              onTapCallback: () {
                                var phone = _phoneController.text.trim();
                                if (phone.length == 0 || phone.length < 11) {
                                  ShowToast("请填写正确的手机号");
                                  return;
                                }
                                GetCode(phone).then((res) {
                                  print("获取验证码 =========== $res");
                                  if (res.code == 1000) {
                                    ShowToast("获取成功");
                                  } else {
                                    ShowToast("获取失败，请重试");
                                  }
                                }).catchError((err) {
                                  print(err);
                                  ShowToast("获取失败，请重试");
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.all(20.0)),
                    new Container(
                      width: 360.0,
                      margin: new EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                      padding: new EdgeInsets.fromLTRB(leftRightPadding,
                          topBottomPadding, leftRightPadding, topBottomPadding),
                      child: new Card(
                        color: UIData.grey_color,
                        elevation: 6.0,
                        child: new FlatButton(
                            onPressed: () {
                              var password = _userPassController.text.trim();
                              var phone = _phoneController.text.trim();
                              var code = _codeController.text.trim();
                              var username = _userNameController.text.trim();
                              var institutionalCode =
                                  _recommendController.text.trim();

                              if (password.length == 0 ||
                                  phone.length == 0 ||
                                  username.length == 0) {
                                ShowToast("请完善信息");
                                return;
                              }
                              if (password.length < 6) {
                                ShowToast("密码不能少于6位数");
                                return;
                              }
                              var pwd = StringToMd5(password);
                              var params = {
                                "phone": phone,
                                "password": pwd,
                                "username": username,
                                "phoneCode": code,
                                "institutionalCode": institutionalCode
                              };
                              if (isLogin) {
                                return;
                              }
                              setState(() {
                                isLogin = !isLogin;
                              });
                              RegisterUser(params).then((res) {
                                print(res);
                                if (res.code == 1000) {
                                  ShowToast("注册成功");
                                  Navigator.of(context).pop();
                                } else {
                                  ShowToast("注册失败，请重试");
                                }
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              }).catchError((err) {
                                print(err);
                                ShowToast("注册失败，请重试");
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              });
                            },
                            child: new Padding(
                              padding: new EdgeInsets.all(6.0),
                              child: new Text(
                                '马上注册',
                                style: new TextStyle(
                                    color: Colors.white, fontSize: 16.0),
                              ),
                            )),
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.all(30.0)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
//    return new Scaffold(
//        appBar: new AppBar(
//          title: new Text("注册", style: new TextStyle(color: Colors.white)),
//          iconTheme: new IconThemeData(color: Colors.white),
//          backgroundColor: UIData.primary_color,
//        ),
//        body: new Column(
//          mainAxisSize: MainAxisSize.max,
//          mainAxisAlignment: MainAxisAlignment.start,
//          children: <Widget>[
//            new Padding(
//              padding: new EdgeInsets.fromLTRB(
//                  leftRightPadding, 40.0, leftRightPadding, 10.0),
//              child: CustomWidget.BuildLogImage(),
//            ),
//            new Padding(
//              padding: EdgeInsets.all(10.0),
//              child: new TextField(
//                style: hintTips,
//                controller: _phoneController,
//                decoration: new InputDecoration(
//                    hintText: "请输入手机号", prefixIcon: Icon(Icons.phone_in_talk)),
//                autofocus: true,
//              ),
//            ),
//            new Padding(
//              padding: EdgeInsets.all(10.0),
//              child: new TextField(
//                style: hintTips,
//                controller: _userNameController,
//                decoration: new InputDecoration(
//                    hintText: "请输入账户名", prefixIcon: Icon(Icons.account_circle)),
//                autofocus: true,
//              ),
//            ),
//            new Padding(
//              padding: EdgeInsets.all(10.0),
//              child: new TextField(
//                style: hintTips,
//                controller: _userPassController,
//                maxLength: 15,
//                decoration: new InputDecoration(
//                    hintText: "请输入用户密码(不能少于6位数)", prefixIcon: Icon(Icons.lock)),
//                obscureText: true, //是否隐藏正在编辑的文本
//              ),
//            ),
//            new Padding(
//              padding: EdgeInsets.all(10.0),
//              child: new TextField(
//                style: hintTips,
//                controller: _codeController,
//                maxLength: 15,
//                decoration: new InputDecoration(
//                    hintText: "请输入机器码", prefixIcon: Icon(Icons.verified_user)),
//              ),
//            ),
//            new Container(
//              width: 360.0,
//              margin: new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
//              padding: new EdgeInsets.fromLTRB(leftRightPadding,
//                  topBottomPadding, leftRightPadding, topBottomPadding),
//              child: new Card(
//                color: UIData.grey_color,
//                elevation: 6.0,
//                child: new FlatButton(
//                    onPressed: () {
//                      var password = _userPassController.text.trim();
//                      var phone = _phoneController.text.trim();
//                      var code = _codeController.text.trim();
//                      var username = _userNameController.text.trim();
//
//                      if (password.length == 0 ||
//                          phone.length == 0 ||
//                          username.length == 0) {
//                        ShowToast("请完善信息");
//                        return;
//                      }
//                      if (password.length < 6) {
//                        ShowToast("密码不能少于6位数");
//                        return;
//                      }
//                      var pwd = StringToMd5(password);
//                      var params = {
//                        "phone": phone,
//                        "password": pwd,
//                        "username": username,
//                        "institutionalCode": code
//                      };
//                      var res = RegisterUser(params);
//                      print(res.code);
//                    },
//                    child: new Padding(
//                      padding: new EdgeInsets.all(3.0),
//                      child: new Text(
//                        '马上注册',
//                        style:
//                            new TextStyle(color: Colors.white, fontSize: 15.0),
//                      ),
//                    )),
//              ),
//            ),
//          ],
//        ));
  }
}
