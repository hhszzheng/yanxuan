import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/goodsDetail/comment_page.dart';
import 'package:flutter_app/ui/goodsDetail/good_detail_page.dart';
import 'package:flutter_app/ui/home/hot_list.dart';
import 'package:flutter_app/ui/home/king_kong_page.dart';
import 'package:flutter_app/ui/home/new_item_page.dart';
import 'package:flutter_app/ui/mine/add_address.dart';
import 'package:flutter_app/ui/mine/coupon.dart';
import 'package:flutter_app/ui/mine/feedback_page.dart';
import 'package:flutter_app/ui/mine/for_services.dart';
import 'package:flutter_app/ui/mine/gift_card.dart';
import 'package:flutter_app/ui/mine/location_manage.dart';
import 'package:flutter_app/ui/mine/login.dart';
import 'package:flutter_app/ui/mine/order_list.dart';
import 'package:flutter_app/ui/mine/pay_safe.dart';
import 'package:flutter_app/ui/mine/points_center.dart';
import 'package:flutter_app/ui/mine/qr_code_mine.dart';
import 'package:flutter_app/ui/mine/red_packet.dart';
import 'package:flutter_app/ui/mine/reward_num.dart';
import 'package:flutter_app/ui/mine/saturday_buy.dart';
import 'package:flutter_app/ui/mine/user_setting.dart';
import 'package:flutter_app/ui/no_found_page.dart';
import 'package:flutter_app/ui/setting/Setting.dart';
import 'package:flutter_app/ui/setting/about.dart';
import 'package:flutter_app/ui/setting/favorite.dart';
import 'package:flutter_app/ui/setting/scrollView.dart';
import 'package:flutter_app/ui/shopingcart/payment_page.dart';
import 'package:flutter_app/ui/shopingcart/shopping_cart.dart';
import 'package:flutter_app/ui/sort/search_page.dart';
import 'package:flutter_app/ui/sort/sort_list_page.dart';
import 'package:flutter_app/ui/webview_page.dart';
import 'package:flutter_app/utils/constans.dart';
import 'package:flutter_app/utils/util_mine.dart';
import 'package:flutter_app/widget/FullScreenImage.dart';
import 'package:flutter_app/widget/widget_list.dart';

class Routers {
  static String plugin = Util.flutter2activity;
  static var demoPlugin = MethodChannel(plugin);

  static Map<String, Function> routes = {
    //????????????
    Util.goodDetailTag: (context, {arguments}) =>
        GoodsDetailPage(arguments: arguments),
    Util.catalogTag: (context, {arguments}) =>
        SortListPage(arguments: arguments),
    //kingKong
    Util.kingKong: (context, {arguments}) {
      String schemeUrl = arguments['schemeUrl'];
      if (schemeUrl.contains("categoryId")) {
        return KingKongPage(arguments: arguments);
      } else {
        return NewItemPage(arguments: arguments);
      }
    },

    //????????????
    Util.search: (context, {arguments}) =>
        SearchGoodsPage(arguments: arguments),
    //??????
    Util.comment: (context, {arguments}) => CommentList(arguments: arguments),

    //????????????
    Util.addAddress: (context, {arguments}) => AddAddress(arguments: arguments),

    //?????????
    Util.hotlist: (context, {arguments}) => HotListPage(),

    ///??????
    Util.image: (context, {arguments}) => FullScreenImage(arguments),

    ///????????????
    Util.orderInit: (context, {arguments}) => PaymentPage(
          arguments: arguments,
        ),

    ///webView
    Util.webView: (context, {arguments}) => WebViewPage(arguments),

    ///webView
    Util.webViewPageAPP: (context, {arguments}) => WebViewPage(arguments),

    ///?????????
    Util.shoppingCart: (context, {arguments}) =>
        ShoppingCart(argument: arguments),

    ///????????????
    Util.mineTopItems: (context, {arguments}) {
      var id = arguments['id'];
      switch (id) {
        case 1: //  ?????????
          return RewardNumPage(
            arguments: arguments,
          );
          break;
        case 2: //
          return RedPacket();
          break;
        case 3:
          return Coupon();
          break;
        case 4: //??????
          return RewardNumPage(
            arguments: arguments,
          );
          break;
        case 5: //?????????
          return GiftCard(
            arguments: arguments,
          );
          break;
      }
      return NoFoundPage();
    },

    ///orderList
    Util.mineItems: (context, {arguments}) {
      var id = arguments['id'];
      switch (id) {
        case 0: //????????????
          return OrderList();
          break;
        case 1: //  ????????????
          return UserSetting();
          break;
        case 2: //  ????????????
          return SaturdayTBuy();
          break;
        case 3:
          return ForServices();
          break;
        case 4: //????????????
          return QRCodeMine();
          break;
        case 5: //?????????
          return WebViewPage(
              {"url": "https://m.you.163.com/preemption/index.html"});
          break;
        case 6: //????????????
          return PointCenter();
          break;

        case 7: //???????????????
          // return VipCenter();
          return WebViewPage({"url": "https://m.you.163.com/membership/index"});
          break;
        case 8: //????????????
          return LocationManage();
          break;
        case 9: //????????????
          return PaySafeCenter();
          break;
        case 10: //????????????
          return WebViewPage(
              {'url': 'https://cs.you.163.com/client?k=$kefuKey'});
          break;
        case 11: //??????
          return FeedBack();
          break;
      }

      return NoFoundPage();
    },
    //????????????
    Util.setting: (context, {arguments}) {
      var id = arguments['id'];
      switch (id) {
        case 0: //????????????
          return AboutApp();
          break;
        case 1: //??????
          return Login();
          break;
        case 2: //????????????
          return Setting();
          break;
        case 3: //??????
          return WidgetList();
          break;
        case 4: //??????
          return ScrollViewDemo();
          break;
        case 5: //????????????
          return Favorite();
          break;
      }
      return NoFoundPage();
    },
  };

  ///????????????

  static link(Widget widget, String routeName, BuildContext context,
      [Map params, Function callBack]) {
    return GestureDetector(
      onTap: () {
        if (params != null) {
          Navigator.pushNamed(context, routeName, arguments: params)
              .then((onValue) {
            if (callBack != null) {
              callBack();
            }
          });
        } else {
          Navigator.pushNamed(context, routeName).then((onValue) {
            if (callBack != null) {
              callBack();
            }
          });
        }
      },
      child: widget,
    );
  }

  ///????????????
  static push(String routeName, BuildContext context,
      [Map params, Function callBack]) {
    if (params != null) {
      Navigator.pushNamed(context, routeName, arguments: params)
          .then((onValue) {
        if (callBack != null) {
          callBack();
        }
      });
    } else {
      Navigator.pushNamed(context, routeName).then((onValue) {
        if (callBack != null) {
          callBack();
        }
      });
    }
  }

  static run(RouteSettings routeSettings) {
    final Function pageContentBuilder = Routers.routes[routeSettings.name];
    if (pageContentBuilder != null) {
      if (routeSettings.arguments != null) {
        return MaterialPageRoute(
            builder: (context) => pageContentBuilder(context,
                arguments: routeSettings.arguments));
      } else {
        // ???????????????
        return MaterialPageRoute(
            builder: (context) => pageContentBuilder(context));
      }
    } else {
      return MaterialPageRoute(builder: (context) => NoFoundPage());
    }
  }

  static pop(context) {
    Navigator.pop(context);
  }
}
