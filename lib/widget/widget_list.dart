import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_menu/_src/drapdown_common.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/router.dart';
import 'package:flutter_app/utils/util_mine.dart';
import 'package:flutter_app/widget/search_widget_no_statusbar.dart';

class WidgetList extends StatefulWidget {
  @override
  _WidgetListState createState() => _WidgetListState();
}

class _WidgetListState extends State<WidgetList> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();

  bool isLoading = true;
  int page = 1;
  final int pageSize = 20;
  int total = 0;
  static int chunk = 2;
  List dataList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    globalKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDropdownMenu(context),
    );
  }

  Widget _buildDropdownMenu(BuildContext context) {
    return DefaultDropdownMenuController(
        onSelected: ({int menuIndex, int index, int subIndex, dynamic data}) {
          print(
              "menuIndex:$menuIndex index:$index subIndex:$subIndex data:$data");
        },
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  buildSliver(_buildHeader()),
                  SliverPersistentHeader(
                    delegate: DropdownSliverChildBuilderDelegate(
                      builder: (BuildContext context) {
                        return new Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: buildDropdownHeader(onTap: _onTapHead));
                      },
                    ),
                    pinned: true,
                    floating: true,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(8),
                    sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          Widget widget = Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    height: 180,
                                    child: CachedNetworkImage(
                                      imageUrl: dataList[index]['list_pic_url'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  flex: 1,
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      "???${dataList[index]['retail_price']}",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 15),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      "${dataList[index]['name']}",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          return Routers.link(widget, Util.goodDetailTag,
                              context, {'id': dataList[index]['id']});
                        }, childCount: dataList.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 8,
                        )),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 46),
                child: buildDropdownMenu(),
              )
            ],
          ),
        ));
  }

  GlobalKey globalKey;

  void _onTapHead(int index) {
    RenderObject renderObject = globalKey.currentContext.findRenderObject();
    DropdownMenuController controller =
        DefaultDropdownMenuController.of(globalKey.currentContext);
    //
    _scrollController
        .animateTo(
            _scrollController.offset + renderObject.semanticBounds.height,
            duration: new Duration(milliseconds: 150),
            curve: Curves.ease)
        .whenComplete(() {
      controller.show(index);
    });
  }

  SliverList buildSliver(Widget child) {
    return SliverList(
        key: globalKey,
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return child;
        }, childCount: 1));
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(),
      child: SearchWidgetNoStstusbar(
        hintText: '????????????',
        controller: _textEditingController,
        onValueChangedCallBack: (value) {},
        onSearchBtnClick: (value) {
          setState(() {});
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textEditingController.dispose();
    _scrollController.dispose();
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return new DropdownHeader(
      onTap: onTap,
      titles: [TYPES[TYPE_INDEX], ORDERS[ORDER_INDEX], FOODS[0]['children'][0]],
    );
  }

  DropdownMenu buildDropdownMenu() {
    return DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 10, menus: [
      DropdownMenuBuilder(
          builder: (BuildContext context) {
            return DropdownListMenu(
              selectedIndex: 0,
              data: TYPES,
              itemBuilder: buildCheckItem,
            );
          },
          height: kDropdownMenuItemHeight * TYPES.length),
      DropdownMenuBuilder(
          builder: (BuildContext context) {
            return DropdownListMenu(
              selectedIndex: 0,
              data: ORDERS,
              itemBuilder: buildCheckItem,
            );
          },
          height: kDropdownMenuItemHeight * ORDERS.length),
      new DropdownMenuBuilder(
          builder: (BuildContext context) {
            return new DropdownTreeMenu(
              selectedIndex: 0,
              subSelectedIndex: 0,
              itemExtent: 45.0,
              background: Colors.grey[200],
              subBackground: Colors.grey[200],
              itemBuilder: (BuildContext context, dynamic data, bool selected) {
                if (!selected) {
                  return new DecoratedBox(
                      decoration: new BoxDecoration(
                          border: new Border(
                              right: Divider.createBorderSide(context))),
                      child: new Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: new Row(
                            children: <Widget>[
                              new Text(data['title']),
                            ],
                          )));
                } else {
                  return new DecoratedBox(
                      decoration: new BoxDecoration(
                          border: new Border(
                              top: Divider.createBorderSide(context),
                              bottom: Divider.createBorderSide(context))),
                      child: new Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: new Row(
                            children: <Widget>[
                              new Container(
                                  color: Theme.of(context).primaryColor,
                                  width: 3.0,
                                  height: 45.0),
                              new Padding(
                                  padding: new EdgeInsets.only(left: 12.0),
                                  child: new Text(data['title'])),
                            ],
                          )));
                }
              },
              subItemBuilder:
                  (BuildContext context, dynamic data, bool selected) {
                Color color = selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.body1.color;

                return new SizedBox(
                  height: 45.0,
                  child: new Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          data['title'],
                          style: new TextStyle(color: color),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      new Expanded(
                          child: Container(
                            padding: EdgeInsets.only(right: 12),
                              alignment: Alignment.centerRight,
                              child: Text(data['count'].toString())))
                    ],
                  ),
                );
              },
              getSubData: (dynamic data) {
                return data['children'];
              },
              data: FOODS,
            );
          },
          height: 450.0)
    ]);
  }
}

const double kDropdownMenuItemHeight = 45.0;

const List<Map<String, dynamic>> ORDERS = [
  {"title": "????????????"},
  {"title": "????????????"},
  {"title": "????????????"},
  {"title": "????????????"},
];

const int ORDER_INDEX = 0;

const List<Map<String, dynamic>> TYPES = [
  {"title": "??????", "id": 0},
  {"title": "????????????", "id": 1},
  {"title": "????????????", "id": 2},
  {"title": "??????", "id": 3},
  {"title": "?????????", "id": 4},
  {"title": "??????", "id": 5},
  {"title": "??????", "id": 6},
  {"title": "????????????", "id": 7},
  {"title": "??????", "id": 8},
  {"title": "??????", "id": 9},
  {"title": "??????", "id": 10},
  {"title": "??????", "id": 11},
  {"title": "?????????", "id": 12},
  {"title": "?????????", "id": 13},
  {"title": "??????", "id": 14},
  {"title": "?????????", "id": 15},
];

const int TYPE_INDEX = 2;

const List<Map<String, dynamic>> BUSINESS_CYCLE = [
  {
    "title": "??????",
    "children": [
      {"title": "??????", "distance": 500},
      {"title": "1km", "distance": 1000},
      {"title": "2km", "distance": 2000}
    ]
  },
  {
    "title": "????????????",
    "children": [
      {"title": "?????????", "count": 326},
      {"title": "????????????", "count": 100},
      {"title": "??????", "count": 50}
    ]
  },
  {
    "title": "??????",
    "children": [
      {"title": "??????", "distance": 500},
      {"title": "1km", "distance": 1000},
      {"title": "2km", "distance": 2000}
    ]
  },
  {
    "title": "??????",
    "children": [
      {"title": "??????", "distance": 500},
      {"title": "1km", "distance": 1000},
      {"title": "2km", "distance": 2000}
    ]
  },
];

String FOOD_JSON =
    '[{"title":"??????","children":[{"title":"?????????","count":810},{"title":"?????????","count":463},{"title":"??????","count":325},{"title":"??????","count":899},{"title":"?????????","count":325},{"title":"?????????","count":14},{"title":"?????????","count":470},{"title":"??????","count":908},{"title":"?????????","count":333},{"title":"??????","count":58},{"title":"??????","count":28},{"title":"?????????","count":469},{"title":"?????????","count":503},{"title":"?????????","count":930},{"title":"?????????","count":885}]},{"title":"?????????","children":[{"title":"?????????","count":207},{"title":"??????","count":425},{"title":"?????????","count":205},{"title":"?????????","count":791},{"title":"??????","count":141},{"title":"?????????","count":163},{"title":"??????","count":65},{"title":"?????????","count":314},{"title":"??????","count":726},{"title":"??????","count":524},{"title":"?????????","count":706},{"title":"??????","count":13},{"title":"??????","count":189},{"title":"?????????","count":335},{"title":"??????","count":90},{"title":"?????????","count":33},{"title":"?????????","count":88}]},{"title":"?????????","children":[{"title":"??????","count":108},{"title":"??????","count":634},{"title":"??????","count":304},{"title":"?????????","count":304},{"title":"?????????","count":324},{"title":"??????","count":153},{"title":"?????????","count":546},{"title":"??????","count":651},{"title":"?????????","count":128},{"title":"??????","count":412},{"title":"??????","count":592},{"title":"?????????","count":134},{"title":"?????????","count":322},{"title":"??????","count":511},{"title":"?????????","count":427},{"title":"??????","count":593},{"title":"??????","count":973}]},{"title":"?????????","children":[{"title":"??????","count":229},{"title":"?????????","count":277},{"title":"?????????","count":592},{"title":"??????","count":568},{"title":"??????","count":618},{"title":"?????????","count":886},{"title":"??????","count":300},{"title":"?????????","count":945},{"title":"?????????","count":320},{"title":"?????????","count":607},{"title":"??????","count":411},{"title":"??????","count":716},{"title":"?????????","count":452},{"title":"?????????","count":561},{"title":"??????","count":748},{"title":"?????????","count":672},{"title":"??????","count":83},{"title":"??????","count":106}]},{"title":"?????????","children":[{"title":"??????","count":426},{"title":"?????????","count":363},{"title":"?????????","count":767},{"title":"?????????","count":687},{"title":"?????????","count":520},{"title":"?????????","count":853},{"title":"??????","count":532},{"title":"?????????","count":573},{"title":"??????","count":893},{"title":"??????","count":466},{"title":"?????????","count":231},{"title":"??????","count":910},{"title":"??????","count":463},{"title":"?????????","count":232}]},{"title":"?????????","children":[{"title":"?????????","count":49},{"title":"?????????","count":385},{"title":"??????","count":142},{"title":"??????","count":736},{"title":"?????????","count":780},{"title":"?????????","count":876},{"title":"?????????","count":694},{"title":"??????","count":410},{"title":"?????????","count":713},{"title":"??????","count":425},{"title":"??????","count":975},{"title":"?????????","count":778},{"title":"??????","count":974},{"title":"??????","count":252},{"title":"??????","count":611},{"title":"??????","count":883},{"title":"??????","count":265},{"title":"??????","count":448},{"title":"?????????","count":748},{"title":"?????????","count":173}]},{"title":"??????","children":[{"title":"??????","count":875},{"title":"?????????","count":576},{"title":"?????????","count":501},{"title":"??????","count":344},{"title":"?????????","count":177},{"title":"??????","count":728},{"title":"??????","count":743},{"title":"?????????","count":670},{"title":"??????","count":339},{"title":"??????","count":560},{"title":"??????","count":303}]},{"title":"??????","children":[{"title":"?????????","count":667},{"title":"?????????","count":456},{"title":"?????????","count":802},{"title":"?????????","count":26},{"title":"??????","count":869},{"title":"??????","count":775},{"title":"?????????","count":635},{"title":"??????","count":293},{"title":"??????","count":339},{"title":"?????????","count":673},{"title":"??????","count":405},{"title":"??????","count":302},{"title":"??????","count":269},{"title":"??????","count":864},{"title":"??????","count":561},{"title":"??????","count":36},{"title":"?????????","count":600},{"title":"??????","count":785},{"title":"??????","count":915}]},{"title":"?????????","children":[{"title":"?????????","count":399},{"title":"??????","count":514},{"title":"?????????","count":638},{"title":"??????","count":622},{"title":"?????????","count":353},{"title":"?????????","count":526},{"title":"?????????","count":626},{"title":"?????????","count":98},{"title":"?????????","count":111},{"title":"??????","count":241},{"title":"?????????","count":429},{"title":"??????","count":624},{"title":"??????","count":922},{"title":"?????????","count":302},{"title":"??????","count":35}]},{"title":"??????","children":[{"title":"??????","count":396},{"title":"??????","count":17},{"title":"??????","count":262},{"title":"?????????","count":25},{"title":"??????","count":149},{"title":"?????????","count":171},{"title":"?????????","count":163},{"title":"?????????","count":922},{"title":"??????","count":786},{"title":"??????","count":12},{"title":"??????","count":990},{"title":"??????","count":818},{"title":"?????????","count":431},{"title":"?????????","count":330},{"title":"??????","count":233}]}]';

List FOODS = json.decode(FOOD_JSON);

const int FOOD_INDEX = 1;
