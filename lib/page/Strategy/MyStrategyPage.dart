import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fotune_app/api/strategy.dart';
import 'package:fotune_app/api/user.dart';
import 'package:fotune_app/model/User.dart';
import 'package:fotune_app/page/Strategy/model/StrategyResp.dart';
import 'package:fotune_app/utils/ToastUtils.dart';
import 'package:fotune_app/utils/UIData.dart';

class MyStrategyPage extends StatefulWidget {
  @override
  State createState() {
    return MyStrategyPageState();
  }
}

class MyStrategyPageState extends State<MyStrategyPage> {
  List<Strategy> strategyList;
  final ScrollController _scrollController = new ScrollController();
  User user;

  @override
  void initState() {
    super.initState();
    setState(() {
      user = GetLocalUser();
      loadData();
    });
  }

  loadData() {
    if (user == null) {
      setState(() {
        strategyList = [];
      });
    } else {
      GetStrategyList(user.user_id).then((res) {
        print(res.data.myStrategy);
        if (res.code == 1000) {
          setState(() {
            strategyList = res.data.myStrategy;
          });
        } else if (res.code == 1004) {
          setState(() {
            strategyList = [];
          });
        }
      });
    }
  }

  Widget buildEmptyView() {
    return Container(
      height: 160,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.network_check,
            size: 50,
            color: UIData.refresh_color,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Text(
            "没有更多数据",
            style: TextStyle(fontSize: 16, color: UIData.normal_font_color),
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    if (strategyList == null) {
      return CircularProgressIndicator(
        backgroundColor: UIData.refresh_color,
      );
    } else if (strategyList.length == 0) {
      return buildEmptyView();
    } else {
      return new RefreshIndicator(
          onRefresh: (() => _handleRefresh()),
          color: UIData.refresh_color, //刷新控件的颜色
          child: ListView.separated(
            itemCount: strategyList.length,
            controller: _scrollController,
            //用于监听是否滑到最底部
            itemBuilder: (context, index) {
              if (index < strategyList.length) {
                Strategy strategy = strategyList[index];
                return GestureDetector(
                  onTap: () {},
                  child: buildListView(context, strategy),
                );
              }
            },
            physics: const AlwaysScrollableScrollPhysics(),
            separatorBuilder: (context, idx) {
              return Container(
                height: 5,
                color: Color.fromARGB(50, 183, 187, 197),
              );
            },
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildBody(),
      ),
    );
  }

  buildListView(BuildContext context, Strategy strategy) {
    var code = strategy.stockCode;
    var buyAmount = strategy.amount;
    var stockCount = strategy.count;

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(strategy.stockName,
                                style: TextStyle(
                                    color: UIData.normal_font_color,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            Padding(
                              padding: EdgeInsets.all(3),
                            ),
                            Text(' ($code)',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      Row(
                        children: <Widget>[
                          Text(" 金额：$buyAmount元",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(" $stockCount股(可用)",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () {
                      print("=======================");
                      List<Strategy> ss = [];
                      strategyList.forEach((s) {
                        if (s.Detail.orderNo == strategy.Detail.orderNo) {
                          s.isShow = !s.isShow;
                        } else {
                          s.isShow = true;
                        }
                        ss.add(s);
                      });
                      setState(() {
                        strategyList = ss;
                      });
                    },
                    child: Text(
                      "查看细节",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            height: 1,
            color: Colors.black12,
          ),
          Container(
            margin: EdgeInsets.all(15),
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(strategy.buyPrice),
                      Padding(padding: EdgeInsets.all(5)),
                      Text(strategy.localPrice),
                      Padding(padding: EdgeInsets.all(5)),
                      Text(
                        strategy.profit.toString(),
                        style: TextStyle(
                            color: UIData.primary_color,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                ),
                ButtonTheme(
                  buttonColor: UIData.primary_color,
                  minWidth: 60.0,
                  height: 30.0,
                  child: RaisedButton(
                    textColor: Colors.white,
                    onPressed: () {
                      ShellStrategy(strategy);
                    },
                    highlightColor: UIData.primary_color,
                    child: Text("卖出"),
                  ),
                )
              ],
            ),
          ),
          Offstage(
            offstage: strategy.isShow,
            child: Container(
              color: Colors.black12,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildCell("买入时间", strategy.Detail.buyTime),
                  buildCell("交易单号", strategy.Detail.orderNo),
                  buildCell(
                      "保证金", (strategy.Detail.creditAmount).toString() + "元"),
                  buildCell("止损线", strategy.Detail.stopLoss.toString() + "元"),
                  buildCell(
                      "浮动赢亏比", strategy.Detail.floatProfit.toString() + "%"),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.all(6),
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                "浮动盈亏",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                " " + strategy.profit.toString(),
                                style: TextStyle(
                                    color: UIData.primary_color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ButtonTheme(
                            buttonColor: UIData.primary_color,
                            minWidth: 100.0,
                            height: 30.0,
                            child: RaisedButton(
                              onPressed: () {
                                showMyDialogWithStateBuilder(
                                    context, strategy.Detail.orderNo);
                              },
                              child: Text(
                                "追加保证金",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCell(String title, String time) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title),
              Text(time),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 0.5,
            color: Colors.black26,
          )
        ],
      ),
    );
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 1), () {
      completer.complete();
    });
    return completer.future.then<void>((_) {
      loadData();
    });
  }

  // ignore: non_constant_identifier_names
  void ShellStrategy(Strategy strategy) {
    User user = GetLocalUser();
    var query = {
      "uid": user.user_id,
      "strategyID": strategy.Detail.orderNo,
      "closeType": 1,
    };
    QueryShellStrategy(query).then((res) {
      if (res.code == 1000) {
        ShowToast("操作成功");
      } else {
        ShowToast("操作失败");
      }
    }).then((err) {
      print(err);
      ShowToast("操作失败");
    });
  }

  //显示对话框 添加策略
  void showMyDialogWithStateBuilder(BuildContext context, String id) {
    var phoneController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: Text(
              "输入追加金额",
              textAlign: TextAlign.center,
            ),
            contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            content: StatefulBuilder(builder: (context, StateSetter setState) {
              return Container(
                height: 100,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("单号: " + id),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        autofocus: false,
                      ),
                    ],
                  ),
                ),
              );
            }),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  "取消",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.black26,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("确认", style: TextStyle(color: Colors.white)),
                color: UIData.primary_color,
                onPressed: () {
                  var price = phoneController.text.trim();
                  if (price.length == 0) {
                    ShowToast("请输入您要追加的金额");
                    return;
                  }
                  print(phoneController.text);
                },
              ),
            ],
          );
        });
  }
}
