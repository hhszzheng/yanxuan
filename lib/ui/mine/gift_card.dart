import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/utils/router.dart';
import 'package:flutter_app/utils/util_mine.dart';
import 'package:flutter_app/widget/app_bar.dart';
import 'package:flutter_app/widget/tab_app_bar.dart';

///账户中没有礼品卡，暂时无法写详细页面
class GiftCard extends StatefulWidget {
  final Map arguments;

  const GiftCard({Key key, this.arguments}) : super(key: key);

  @override
  _GiftCardState createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backColor,
      appBar: TabAppBar(
        title: '礼品卡',
      ).build(context),
      body: Column(
        children: [
          _buildCard(),
          Expanded(
            child: _noCard(),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                10, 10, 10, MediaQuery.of(context).padding.bottom + 10),
            height: 60 + MediaQuery.of(context).padding.bottom,
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: redColor, width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: textRed,
                  ),
                  Text(
                    '添加礼品卡',
                    style: t16red,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      color: redColor,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '礼品卡余额',
                  style: TextStyle(color: textWhite, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  '¥${widget.arguments['value']}',
                  style: t24white,
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      '支付安全',
                      style: t12white,
                    ),
                  ),
                  onTap: () {
                    _goWebView('https://m.you.163.com/user/securityCenter');
                  },
                )
              ],
            ),
          ),
          Positioned(
            right: 15,
            child: GestureDetector(
              child: Container(
                child: Row(
                  children: [
                    Text(
                      '交易记录',
                      style: t12white,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              onTap: () {
                _goWebView(
                    'https://m.you.163.com/giftCard/records?giftCardGroup=0');
              },
            ),
          )
        ],
      ),
    );
  }

  _goWebView(String url) {
    Routers.push(Util.webViewPageAPP, context, {'url': url});
  }

  _noCard() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.white,
          child: Column(
            children: [
              Image.asset(
                'assets/images/no_gift_card.png',
                width: 100,
                height: 120,
                fit: BoxFit.fitWidth,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '去买张礼品卡充值吧',
                  style: t14grey,
                ),
              ),
              GestureDetector(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '了解详情',
                        style: t14grey,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: textGrey,
                      )
                    ],
                  ),
                ),
                onTap: () {
                  Routers.push(Util.webView, context,
                      {'id': 'https://m.you.163.com/help/new#/29'});
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
