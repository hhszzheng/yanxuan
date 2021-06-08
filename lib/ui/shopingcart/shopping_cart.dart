import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/ui/shopingcart/cart_item_widget.dart';
import 'package:flutter_app/ui/shopingcart/empty_cart_widget.dart';
import 'package:flutter_app/ui/shopingcart/invalid_cart_item_widget.dart';
import 'package:flutter_app/ui/shopingcart/model/carItem.dart';
import 'package:flutter_app/ui/shopingcart/model/cartItemListItem.dart';
import 'package:flutter_app/ui/shopingcart/model/shoppingCartModel.dart';
import 'package:flutter_app/utils/HosEventBusUtils.dart';
import 'package:flutter_app/utils/toast.dart';
import 'package:flutter_app/utils/user_config.dart';
import 'package:flutter_app/widget/back_loading.dart';
import 'package:flutter_app/widget/service_tag_widget.dart';
import 'package:flutter_app/widget/slivers.dart';
import 'package:flutter_app/widget/webview_login_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShoppingCart extends StatefulWidget {
  final Map argument;

  const ShoppingCart({Key key, this.argument}) : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart>
    with AutomaticKeepAliveClientMixin {
  var _data; // 完整数据
  ShoppingCartModel _shoppingCartModel;

  List<CarItem> _cartGroupList = []; // 有效的购物车组列表
  CarItem _topItem; // 顶部商品数据
  List<CarItem> _itemList = []; // 显示的商品数据
  List<CarItem> _invalidCartGroupList = []; // 无效的购物车组列表
  double _price = 0; // 价格
  double _promotionPrice = 0; // 促销价
  double _actualPrice = 0; // 实际价格

  bool isChecked = false; // 是否全部勾选选中
  bool _isCheckedAll = false; // 是否全部勾选选中

  bool loading = false; // 是否正在加载
  int _selectedNum = 0; // 选中商品数量

  bool isEdit = false; // 是否正在编辑

  bool _islogin = true;
  int allCount = 0;
  List checkList = [];

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  /*
  *   初始化
  * */
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HosEventBusUtils.on((event) {
      if (event == 'refresh') {
        _getData();
      }
    });
    _checkLogin();
  }

  ///检查是否登录
  _checkLogin() async {
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      "__timestamp": "${DateTime.now().millisecondsSinceEpoch}"
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await checkLogin(params, header: header);
    var isLogin = responseData.data;
    if (isLogin) {
      _getData();
    } else {
      setState(() {
        _islogin = false;
      });
    }
  }

  /*
  *   数据逻辑
  * */

  // 获取购物车数据
  void _getData() async {
    Map<String, dynamic> params = {"csrf_token": csrf_token}; // 参数
    Map<String, dynamic> header = {"Cookie": cookie}; // 请求头
    var responseData = await shoppingCart(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  // 更新状态机 刷新界面
  void setData(var _data) {
    if (_data == null) {
      _getData();
    }

    var shoppingCartModel = ShoppingCartModel.fromJson(_data);
    setState(() {
      loading = false;
      _shoppingCartModel = shoppingCartModel;
      _cartGroupList = shoppingCartModel.cartGroupList;

      _invalidCartGroupList = shoppingCartModel.invalidCartGroupList;
      _price = double.parse(shoppingCartModel.actualPrice.toString());
      _promotionPrice =
          double.parse(shoppingCartModel.promotionPrice.toString());
      _actualPrice = double.parse(shoppingCartModel.actualPrice.toString());

      if (_cartGroupList.length > 0) {
        _topItem = _cartGroupList[0];
        if (_cartGroupList.length > 1) {
          _itemList = _cartGroupList;
          _itemList.removeAt(0);
          _selectedNum = 0;

          ///获取选择的数量
          _itemList.forEach((element) {
            var cartItemList = element.cartItemList;
            cartItemList.forEach((item) {
              if (item.checked) {
                _selectedNum += item.cnt;
              }
            });
          });

          ///判断是否全选
          _itemList.forEach((element) {
            var cartItemList = element.cartItemList;
            cartItemList.forEach((item) {
              _isCheckedAll = true;
              if (!item.checked) {
                _isCheckedAll = false;
                return;
              }
            });
          });
        }
      }
    });
  }

  /// 购物车 全选/不选 网络请求
  _check() async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'isChecked': isChecked
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await shoppingCartCheck(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  /// 购物车  某个勾选框 选/不选 请求
  _checkOne(int source, int type, int skuId, bool isChecked, var extId) async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'source': source,
      'type': type,
      'skuId': skuId,
      'isChecked': isChecked,
      'extId': extId,
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await shoppingCartCheckOne(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  /// 购物车  商品 选购数量变化 请求
  _checkOneNum(int source, int type, int skuId, int cnt, var extId) async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'source': source,
      'type': type,
      'skuId': skuId,
      'cnt': cnt,
      'extId': extId,
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await shoppingCartCheckNum(params, header: header);
    setState(() {
      _data = responseData.data;
      setData(_data);
    });
  }

  /// 获取价格
  _getPrice() {
    return _price;
  }

  // 编辑状态 删除
  void _deleteCheckItem(bool check, CarItem itemData, CartItemListItem item) {
    if (check) {
      var map = {
        "type": item.type,
        "promId": itemData.promId,
        "addBuy": false,
        "skuId": item.skuId,
        "extId": item.extId
      };
      setState(() {
        checkList.add(map);
      });
    } else {
      if (checkList.length > 0) {
        for (int i = 0; i < checkList.length; i++) {
          if (checkList[i]['skuId'] == item.skuId) {
            setState(() {
              checkList.removeAt(i);
            });
          }
        }
      }
    }
    print(checkList);
  }

  // 清空购物车
  void _deleteCart() async {
    Map<String, dynamic> item = {
      "skuList": checkList,
    };
    Map<String, dynamic> params = {
      'selectedSku': json.encode(item),
      "csrf_token": csrf_token,
    };

    Map<String, dynamic> header = {
      "Cookie": cookie,
      "csrf_token": csrf_token,
    };

    print(params);
    var responseData = await deleteCart(params, header: header);
    if (responseData.code == "200") {
      print('===============');
      _data = responseData.data;
      setData(_data);
    }
  }

  @override
  Widget build(BuildContext context) {
    var argument = widget.argument;
    return _islogin
        ? Scaffold(
            backgroundColor: backColor,
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              centerTitle: true,
              title: _navBar(),
              leading: argument == null
                  ? Container()
                  : GestureDetector(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: textBlack,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
            ),
            body: Stack(
              children: [
                _data == null ? Loading() : _buildData(context),
                Positioned(
                  child: _buildBuy(),
                  bottom: 0,
                  left: 0,
                  right: 0,
                ),
                loading ? Loading() : Container(),
              ],
            ),
          )
        : _loginPage(context);
  }

  _loginPage(BuildContext context) {
    // Routers.push(Util.webLogin, context,{},_callback);
    return WebLoginWidget(
      onValueChanged: (value) {
        print(value);
        print('111111111111');

        if (value) {
          setState(() {
            _islogin = value;
          });
          _checkLogin();
        }
      },
    );
  }

  _buildData(BuildContext context) {
    return Positioned(
      child: (_data == null ||
              _cartGroupList.isEmpty ||
              _cartGroupList.length == 0)
          ? EmptyCartWidget()
          : MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: CustomScrollView(
                slivers: [
                  singleSliverWidget(_buildTitle()),
                  singleSliverWidget(_dataList()),
                  singleSliverWidget(_invalidList()),
                  singleSliverWidget(Container(
                    height: 50,
                  ))
                ],
              )),
      bottom: 50,
      top: 0,
      //MediaQuery.of(context).padding.top + 46,
      left: 0,
      right: 0,
    );
  }

  ///  导航头
  Widget _navBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(bottom: BorderSide(color: backColor,width: 1))
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '购物车',
                style: t16black,
              ),
            ),
          ),
          isEdit
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: redLightColor,
                  ),
                  child: Text(
                    '领券',
                    style: t14white,
                  ),
                ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                checkList.clear();
                isEdit = !isEdit;
              });
            },
            child: Text(
              isEdit ? '完成' : '编辑',
              style: t14black,
            ),
          )
        ],
      ),
    );
  }

  /// 导航下面，商品上面  标题部分
  Widget _buildTitle() {
    return _topItem == null
        ? Container()
        : Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shoppingCartModel.postageVO.postageTip == null
                    ? ServiceTagWidget()
                    : Container(
                        alignment: Alignment.centerLeft,
                        color: textLightYellow,
                        padding: EdgeInsets.only(left: 15),
                        height: ScreenUtil().setHeight(40),
                        child: Text(
                          '${_data['postageVO']['postageTip']}',
                          style: t14red,
                        ),
                      ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 6),
                        padding: EdgeInsets.fromLTRB(5, 1, 5, 2),
                        decoration: BoxDecoration(
                            color: redLightColor,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          '全场换购',
                          style: t12white,
                        ),
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_topItem.promTip}',
                          style: t14black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      GestureDetector(
                        child: Row(
                          children: [
                            Text(
                              '${_topItem.promotionBtn == 3 ? '再逛逛' : '去凑单'}',
                              style: t14red,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: textRed,
                              size: 14,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    margin: EdgeInsets.fromLTRB(50, 0, 15, 0),
                    color: Color(0xFFFFF7F5),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          _actualPrice > 100 ? '去换购商品' : '查看换购商品',
                          style: t12black,
                        )),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: textGrey,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 6,
                )
              ],
            ),
          );
  }

  /// 有效商品列表
  Widget _dataList() {
    return CartItemWidget(
      checkOne: (num source, num type, num skuId, bool check, String extId) {
        _checkOne(source, type, skuId, check, extId);
      },
      deleteCheckItem: (bool check, CarItem itemData, CartItemListItem item) {
        _deleteCheckItem(check, itemData, item);
      },
      numChange: (num source, num type, num skuId, num cnt, String extId) {
        _checkOneNum(source, type, skuId, cnt, extId);
      },
      isEdit: isEdit,
      itemList: _itemList,
    );
  }

  // 无效商品列表
  Widget _invalidList() {
    return InvalidCartItemWidget(
      invalidCartGroupList: _invalidCartGroupList,
    );
  }

  /// 底部 商品勾选状态、价格信息、下单 部分
  Widget _buildBuy() {
    ///编辑状态
    if (isEdit) {
      return Container(
        color: Colors.white,
        height: ScreenUtil().setHeight(50),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(
                  '已选(${checkList.length})',
                  style: t14grey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (checkList.length > 0) {
                  _deleteCart();
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: 10),
                alignment: Alignment.center,
                color: checkList.length > 0 ? redColor : Color(0xFFB4B4B4),
                padding: EdgeInsets.symmetric(horizontal: 40),
                height: double.infinity,
                child: Text(
                  '删除所选',
                  style: t14white,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      ///正常状态
      return Container(
        color: Colors.white,
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 15),
              child: InkWell(
                onTap: () {
                  setState(() {
                    // _isCheckedAll = !_isCheckedAll;
                    isChecked = !isChecked;
                    _check();
                  });
                },
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: _isCheckedAll
                        ? Icon(
                            Icons.check_circle,
                            size: 22,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.brightness_1_outlined,
                            size: 22,
                            color: lineColor,
                          ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(bottom: 3),
                child: Text(
                  '已选($_selectedNum)',
                  style: t14grey,
                ),
              ),
              onTap: () {
                setState(() {
                  // _isCheckedAll = !_isCheckedAll;
                  isChecked = !isChecked;
                  _check();
                });
              },
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        '合计：¥${_getPrice()}',
                        style: TextStyle(
                            color: textRed, fontSize: 14, height: 1.1),
                      ),
                    ),
                    _promotionPrice == 0
                        ? Container()
                        : Container(
                            child: Text(
                              '已优惠：¥$_promotionPrice',
                              style: TextStyle(
                                  color: textGrey, fontSize: 12, height: 1.1),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(left: 10),
                alignment: Alignment.center,
                color: _getPrice() > 0 ? redColor : Color(0xFFB4B4B4),
                padding: EdgeInsets.symmetric(horizontal: 40),
                height: double.infinity,
                child: Text(
                  '下单',
                  style: t14white,
                ),
              ),
              onTap: () {
                Toast.show('暂未开发', context);
                // Routers.push(Util.webView, context,{'id':'https://m.you.163.com/order/confirm?sfrom=3995230&_stat_referer=itemDetail_buy'});
              },
            )
          ],
        ),
      );
    }
  }

  // 分割线
  Widget line = Container(
    height: 10,
    color: Color(0xFFEAEAEA),
  );
}
