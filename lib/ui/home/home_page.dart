import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/model/category.dart';
import 'package:flutter_app/ui/home/model/categoryHotSellModule.dart';
import 'package:flutter_app/ui/home/model/flashSaleModule.dart';
import 'package:flutter_app/ui/home/model/flashSaleModuleItem.dart';
import 'package:flutter_app/ui/home/model/floorItem.dart';
import 'package:flutter_app/ui/home/model/focusItem.dart';
import 'package:flutter_app/ui/home/model/homeModel.dart';
import 'package:flutter_app/ui/home/model/indexActivityModule.dart';
import 'package:flutter_app/ui/home/model/kingKongModule.dart';
import 'package:flutter_app/ui/home/model/newItemModel.dart';
import 'package:flutter_app/ui/home/model/policyDescItem.dart';
import 'package:flutter_app/ui/home/model/sceneLightShoppingGuideModule.dart';
import 'package:flutter_app/utils/router.dart';
import 'package:flutter_app/utils/user_config.dart';
import 'package:flutter_app/utils/util_mine.dart';
import 'package:flutter_app/widget/slivers.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = new ScrollController();

  bool isLoading = true;

  ///banner数据
  List<FocusItem> _focusList;

  ///banner下面tag
  List<PolicyDescItem> _policyDescList;

  ///kingkong
  List<KingKongItem> _kingKongList;

  ///活动大图
  List<FloorItem> _floorList;

  ///新人礼包
  List<IndexActivityModule> _indexActivityModule;

  ///类目热销榜
  CategoryHotSellModule _categoryHotSellModule;

  List<Category> _categoryList;

  ///限时购
  FlashSaleModule _flashSaleModule;
  List<FlashSaleModuleItem> _flashSaleModuleItemList;

  ///新品首发
  List<NewItemModel> _newItemList;

  ///底部数据
  List<SceneLightShoppingGuideModule> _sceneLightShoppingGuideModule;

  var toolbarHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 160) {
        if (toolbarHeight == 0) {
          setState(() {
            toolbarHeight = 50;
          });
        }
      } else {
        if (toolbarHeight == 50) {
          setState(() {
            toolbarHeight = 0;
          });
        }
      }
    });
    _getData();
    // _checkLogin();
  }

  ///检查是否登录
  _checkLogin() async {
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      "__timestamp": "${DateTime.now().millisecondsSinceEpoch}"
    };
    Map<String, dynamic> header = {"Cookie": cookie};
  }

  void _incrementCounter() {
    _getData();
  }

  void _getData() async {
    // String loadString = await DefaultAssetBundle.of(context)
    //     .loadString("assets/json/home_data_json.json");
    //
    // var decode = json.decode(loadString);
    // var homeModel = HomeModel.fromJson(decode['data']['data']);

    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      "__timestamp": "${DateTime.now().millisecondsSinceEpoch}"
    };
    var responseData = await homeData(params);
    var data = responseData.data;
    var homeModel = HomeModel.fromJson(data['data']);
    setData(homeModel);
  }

  void setData(HomeModel homeModel) {
    setState(() {
      _focusList = homeModel.focusList;
      _policyDescList = homeModel.policyDescList;
      _kingKongList = homeModel.kingKongModule.kingKongList;
      _floorList = homeModel.bigPromotionModule.floorList;
      _indexActivityModule = homeModel.indexActivityModule;
      _categoryHotSellModule = homeModel.categoryHotSellModule;
      if (_categoryHotSellModule != null) {
        _categoryList = _categoryHotSellModule.categoryList;
      }
      _flashSaleModule = homeModel.flashSaleModule;
      if (_flashSaleModule != null) {
        _flashSaleModuleItemList = _flashSaleModule.itemList;
      }
      _newItemList = homeModel.newItemList;
      _sceneLightShoppingGuideModule = homeModel.sceneLightShoppingGuideModule;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Color(0xB3D2001A),
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.loop),
      ), //

      body: isLoading ? _loadingView() : _refresh(),
    );
  }

  _refresh() {
    return RefreshIndicator(
        child: _contentBody(),
        onRefresh: () async {
          _getData();
        });
  }

  _contentBody() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 160,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          toolbarHeight: double.parse(toolbarHeight.toString()),
          title: _buildSearch(context),
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildSwiper(), //banner图
          ),
        ),

        _topTags(context), //标签
        _kingkong(context), //
        _bigPromotion(context), //活动
        _splitLine(),
        _newcomerPack(context), //新人礼包
        _splitLine(),
        _categoryHotSell(context), //类目热销榜
        _categoryHotSellItem(context), //类目热销榜条目

        _normalTitle(context, '限时购'), //限时购
        _flashSaleItem(context), //类目热销榜条目

        _normalTitle(context, '新品首发'), //新品首发
        _newModulItem(context), //新品首发条目

        _splitLine(),
        _bottomView(context),
      ],
    );
  }

  _loadingView() {
    return Container(
      child: Image.asset('assets/images/home_loading.png'),
    );
  }

  _buildSearch(BuildContext context) {
    Widget widget = Row(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "网易严选",
            style: t16black,
          ),
        ),
        Expanded(
          child: Container(
            height: 35,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0, 10, 15, 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 237, 237, 237),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.search,
                  size: 20,
                  color: textGrey,
                ),
                Expanded(
                  child: Text(
                    "搜索商品，共30000+款好物",
                    style: t12grey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
    return Routers.link(widget, Util.search, context, {'id': "零食"});
    // return singleSliverWidget(
    //     Routers.link(navBar, Util.search, context, {'id': "零食"}));
  }

  _buildSwiper() {
    return CarouselSlider(
      items: _focusList.map<Widget>((e) {
        return GestureDetector(
          child: Container(
            child: CachedNetworkImage(
              height: 160,
              imageUrl: e.picUrl,
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Routers.push(Util.webView, context, {'url': e.targetUrl});
          },
        );
      }).toList(),
      options: CarouselOptions(
          height: 200,
          autoPlay: true,
          viewportFraction: 1.0,
          enlargeCenterPage: true,
          onPageChanged: (index, reason) {
            setState(() {});
          }),
    );
  }

  _topTags(BuildContext context) {
    return singleSliverWidget(
      Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _policyDescList
              .map((item) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          width: 20,
                          height: 20,
                          imageUrl: item.icon,
                        ),
                        Text(
                          item.desc,
                          style: t12black,
                        )
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  ///  分类
  _kingkong(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, childAspectRatio: 1),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Widget widget = Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4), color: Colors.white),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: CachedNetworkImage(
                      imageUrl: _kingKongList[index].picUrl ?? "",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  flex: 2,
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: 4,
                      ),
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          _kingKongList[index].text ?? "",
                          style: t12black,
                        ),
                      ),
                    )),
              ],
            ),
          );
          return Routers.link(widget, Util.kingKong, context,
              {"schemeUrl": _kingKongList[index].schemeUrl});
        },
        childCount: _kingKongList == null ? 0 : _kingKongList.length,
      ),
    );
  }

  _bigPromotion(BuildContext context) {
    return singleSliverWidget(Column(
      children: _floorList
          .map(
            (item) => Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 180),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: _huoDong(item),
            ),
          )
          .toList(),
    ));
  }

  _huoDong(FloorItem item) {
    if (item.cells != null && item.cells.length > 1) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 180),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: Row(
          children: item.cells.map((e) {
            return Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  child: CachedNetworkImage(
                    imageUrl: item.cells.length > 1 ? e.picUrl : e.picUrl,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {
                    Routers.push(Util.webView, context, {'url': e.schemeUrl});
                  },
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else if (item.cells != null && item.cells.isNotEmpty) {
      return Container(
        width: double.infinity,
        child: GestureDetector(
          child: CachedNetworkImage(
            imageUrl: item.cells[0].picUrl,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Routers.push(
                Util.webView, context, {'url': item.cells[0].schemeUrl});
          },
        ),
      );
    } else {
      return Container();
    }
  }

  _splitLine() {
    return singleSliverWidget(Container(
      height: 10,
      color: Color(0xFFF5F5F5),
    ));
  }

  _newcomerPack(BuildContext context) {
    return singleSliverWidget(Column(children: [
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "- 新人专享礼包 -",
                style: t16black,
              ),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: 200,
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 3),
                    color: Color(0xFFF6E5C4),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(40, 60, 20, 20),
                          height: 197,
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  "http://yanxuan.nosdn.127.net/352b0ea9b2d058094956efde167ef852.png"),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Text(
                            '新人专享礼包',
                            style: t14blackBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    _goWebview(
                        'https://act.you.163.com/act/pub/qAU4P437asfF.html');
                  },
                )),
            Container(
              width: 3,
              color: Colors.white,
            ),
            Expanded(
              flex: 1,
              child: Container(
                  height: 200,
                  child: Column(
                      children: _indexActivityModule.map((item) {
                    return GestureDetector(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity / 2,
                            height: 97,
                            color: Color(0xFFF9DCC9),
                            margin: EdgeInsets.only(top: 3),
                            child: CachedNetworkImage(
                              alignment: Alignment.bottomRight,
                              fit: BoxFit.fitHeight,
                              imageUrl: item.showPicUrl,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: t14blackBold,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Container(
                                  child: Text(
                                    item.subTitle == ""
                                        ? item.tag
                                        : item.subTitle,
                                    style: t12grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _goWebview(item.targetUrl);
                      },
                    );
                  }).toList())),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      )
    ]));
  }

  _categoryHotSell(BuildContext context) {
    if (_categoryHotSellModule == null) {
      return singleSliverWidget(Container());
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(15, 7, 15, 0),
      sliver: singleSliverWidget(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 5, 12, 12),
              child: Text(
                _categoryHotSellModule.title,
                style: t16black,
              ),
            ),
            Container(
              child: Row(
                children: [
                  _hotTopCell(0),
                  SizedBox(
                    width: 5,
                  ),
                  _hotTopCell(1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _hotTopCell(int index) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          Routers.push(Util.hotlist, context);
        },
        child: Container(
          color: index == 0 ? Color(0xFFF7F1DD) : Color(0xFFE4E8F0),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _categoryList[index].categoryName,
                      style: t12blackbold,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      height: 2,
                      width: 30,
                      color: Colors.black,
                    )
                  ],
                ),
                flex: 2,
              ),
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: _categoryList[index].picUrl,
                ),
                flex: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _categoryHotSellItem(BuildContext context) {
    if (_categoryHotSellModule == null) {
      return singleSliverWidget(Container());
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 5, mainAxisSpacing: 5),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Routers.push(Util.hotlist, context);
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 4,
                        ),
                        color: Color(0xFFF2F2F2),
                        child: Center(
                          child: Text(
                            _categoryList[index].categoryName,
                            style: TextStyle(
                                color: textBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        color: Color(0xFFF2F2F2),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: _categoryList[index].picUrl,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      )),
                ],
              ),
            );
          },
          childCount: _categoryList.length > 8 ? 8 : _categoryList.length,
        ),
      ),
    );
  }

  _normalTitle(BuildContext context, String title) {
    if (_flashSaleModule == null && title == '限时购') {
      return singleSliverWidget(Container());
    } else if ((_newItemList == null || _newItemList.isEmpty) &&
        title == '新品首发') {
      return singleSliverWidget(Container());
    }
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            height: 10,
            color: Color(0xFFF5F5F5),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(15, 12, 15, 4),
            alignment: Alignment.centerLeft,
            child: Text(
              "$title",
              style: t16black,
            ),
          ),
        ],
      ),
    );
  }

  _flashSaleItem(BuildContext context) {
    if (_flashSaleModuleItemList == null || _flashSaleModuleItemList.isEmpty) {
      return singleSliverWidget(Container());
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.8),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            Widget widget = Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: _flashSaleModuleItemList[index].picUrl,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "¥${_flashSaleModuleItemList[index].activityPrice}",
                        style: t14red,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "¥${_flashSaleModuleItemList[index].originPrice}",
                        style: TextStyle(
                          fontSize: 12,
                          color: textGrey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
            return Routers.link(widget, Util.goodDetailTag, context,
                {'id': _flashSaleModuleItemList[index].itemId});
          },
          childCount: _flashSaleModuleItemList.length,
        ),
      ),
    );
  }

  _newModulItem(BuildContext context) {
    if (_newItemList == null || _newItemList.isEmpty) {
      return singleSliverWidget(Container());
    }
    return SliverPadding(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.58),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              var item = _newItemList[index];
              Widget widget = Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: CachedNetworkImage(
                          height: 210,
                          imageUrl: item.scenePicUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "${item.simpleDesc}",
                        style: t12black,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "¥${item.retailPrice}",
                      style: t14red,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      constraints: BoxConstraints(minHeight: 18),
                      child: _newItemsTags(item),
                    )
                  ],
                ),
              );
              return Routers.link(
                  widget, Util.goodDetailTag, context, {'id': item.id});
            },
            childCount: _newItemList.length > 6 ? 6 : _newItemList.length,
          ),
        ));
  }

  _newItemsTags(NewItemModel item) {
    var itemTagList = item.itemTagList;
    if (itemTagList != null && itemTagList.length > 1) {
      var itemD = itemTagList[itemTagList.length - 1];
      return Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 0.5, color: redColor)),
        child: Text(
          itemD.name,
          style: t12red,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Container();
    }
  }

  _bottomView(BuildContext context) {
    if (_sceneLightShoppingGuideModule == null ||
        _sceneLightShoppingGuideModule.isEmpty) {
      return singleSliverWidget(Container());
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(10, 15, 15, 15),
      sliver: singleSliverWidget(Row(
        children: _sceneLightShoppingGuideModule.map((item) {
          Widget widget = Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                _goWebview(item.styleItem.targetUrl);
              },
              child: Container(
                color: Color(0xFFF2F2F2),
                margin: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.styleItem.title,
                            style: t14blackBold,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            item.styleItem.desc,
                            style: t12warmingRed,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: item.styleItem.picUrlList[0] ?? '',
                          )),
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: item.styleItem.picUrlList[1] ?? '',
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
          return widget;
        }).toList(),
      )),
    );
  }

  _goWebview(String url) {
    Routers.push(Util.webView, context, {'url': url});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
}
