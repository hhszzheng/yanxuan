import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/http_manager/api.dart';
import 'package:flutter_app/model/pagination.dart';
import 'package:flutter_app/ui/goodsDetail/model/commentItem.dart';
import 'package:flutter_app/ui/goodsDetail/model/commondPageModel.dart';
import 'package:flutter_app/utils/router.dart';
import 'package:flutter_app/utils/user_config.dart';
import 'package:flutter_app/utils/util_mine.dart';
import 'package:flutter_app/widget/flow_widget.dart';
import 'package:flutter_app/widget/loading.dart';
import 'package:flutter_app/widget/sliver_footer.dart';
import 'package:flutter_app/widget/slivers.dart';
import 'package:flutter_app/widget/start_widget.dart';
import 'package:flutter_app/widget/tab_app_bar.dart';

class CommentList extends StatefulWidget {
  final Map arguments;

  CommentList({this.arguments});

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  var tag = '全部';
  var checkedItem = '全部';
  var checkIndex = 0;
  int page = 1;
  Praise _praise = Praise();
  bool isFirstLoading = true;

  var showTagsNum = 6;

  List<CommentItem> _commentTags = [];

  ScrollController _scrollController = ScrollController();

  ///总数据
  CommondPageModel _commondPageModel;
  Pagination _pagination;

  ///数据列表
  List<ResultItem> _commentList = [];

  @override
  void initState() {
    _getCommentPraise();
    _getCommentTags();
    reset();
    super.initState();

//    https://m.you.163.com/xhr/comment/listByItemByTag.json?itemId=1006013&page=1&tag=全部
//    https://m.you.163.com/xhr/comment/itemGoodRates.json    好评率  itemId: 1023014
//    https://m.you.163.com/xhr/comment/tags.json    //评价tag  itemId: 1023014

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_pagination != null) {
          if (_pagination.totalPage > _pagination.page) {
            setState(() {
              page++;
            });
            _getCommentList();
          }
        }
      }
    });
  }

  void reset() {
    setState(() {
      page = 1;
      _commentList.clear();
      _commentList = [];
    });
    _getCommentList();
  }

  ///评价列表
  void _getCommentList() async {
    Map<String, dynamic> params = {
      "csrf_token": csrf_token,
      'itemId': widget.arguments['id'],
      'page': page,
      'tag': tag,
    };
    Map<String, dynamic> header = {"Cookie": cookie};
    var responseData = await commentListData(params, header: header);

    setState(() {
      isFirstLoading = false;
      _commondPageModel = CommondPageModel.fromJson(responseData.data);
      _pagination = _commondPageModel.pagination;
      List<ResultItem> commentList = _commondPageModel.result;
      _commentList.addAll(commentList);
    });
  }

  ///好评率
  void _getCommentPraise() async {
    var params = {
      'itemId': widget.arguments['id'],
    };
    var responseData = await commentPraiseApi(params);
    setState(() {
      _praise = Praise.fromJson(responseData.data);
    });
  }

  ///评价Tag
  void _getCommentTags() async {
    var params = {
      'itemId': widget.arguments['id'],
    };
    var responseData = await commentTagsApi(params);
    List data = responseData.data;
    List<CommentItem> list = [];
    data.forEach((element) {
      list.add(CommentItem.fromJson(element));
    });
    setState(() {
      _commentTags = list;
      if (_commentTags != null && _commentTags.length > 6) {
        showTagsNum = 6;
      } else {
        showTagsNum = _commentTags.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabAppBar(
        tabs: [],
        title: '评价',
      ).build(context),
      body: isFirstLoading
          ? Loading()
          : CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                singleSliverWidget(buildPraise()),
                singleSliverWidget(buildCommentTags()),
                singleSliverWidget(buildTagControl()),
                singleSliverWidget(buildLine()),
                (_commentList == null || _commentList.isEmpty)
                    ? singleSliverWidget(Container(
                        child: Center(
                          child: Text(
                            "",
                            style: t18blackbold,
                          ),
                        ),
                      ))
                    : buildCommentList(),
                SliverFooter(
                    hasMore: _pagination.totalPage > _pagination.page ||
                        (_commentList.length == 0))
              ],
            ),
    );
  }

  Widget buildTagControl() {
    if (_commentTags.length < 6) {
      return Container(height: 20);
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                showTagsNum == _commentTags.length ? '收起' : '更多',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              Icon(
                showTagsNum == _commentTags.length
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey,
              )
            ],
          ),
          onTap: () {
            setState(() {
              if (showTagsNum < _commentTags.length) {
                showTagsNum = _commentTags.length;
              } else {
                if (_commentTags.length < 6) {
                  showTagsNum = _commentTags.length;
                } else {
                  showTagsNum = 6;
                }
              }
            });
          },
        ),
      );
    }
  }

  Widget buildPraise() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 5),
            child: Text(
              '评分',
              style: TextStyle(color: Colors.black),
            ),
          ),
          _praise.star == null
              ? Container()
              : Container(
                  child: StaticRatingBar(
                    size: 15,
                    rate: (_praise.star / 100) * 100,
                  ),
                ),
          _praise.goodCmtRate == null
              ? Container()
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _praise.goodCmtRate,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildCommentTags() {
    if (_commentTags == null || _commentTags.isEmpty) {
      return Loading();
    } else {
      List items = [];
      _commentTags.forEach((item) {
        items.add('${item.name}(${item.strCount})');
      });
      // checkedItem = items[0];
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: FlowWidget(
            items: items,
            checkedItem: checkedItem,
            showItemCount: showTagsNum,
            onTap: (index) {
              setState(() {
                this.checkIndex = index;
                this.tag = '${_commentTags[index].name}';
                this.checkedItem =
                    '${_commentTags[index].name}(${_commentTags[index].strCount})';
              });
              reset();
            },
          ));
    }
  }

  Widget buildLine() {
    return Container(
      height: 0.5,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.grey[200]),
    );
  }

  SliverList buildCommentList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 0.5, color: Colors.grey[200]))),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: Container(
                    width: 30,
                    height: 30,
                    child: CachedNetworkImage(
                      imageUrl: _commentList[index].frontUserAvatar == null
                          ? ''
                          : _commentList[index].frontUserAvatar,
                      errorWidget: (context, url, error) {
                        return ClipOval(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(_commentList[index].frontUserName),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      color: Color(0xFFB19C6D),
                      borderRadius: BorderRadius.circular(2)),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.grey, fontSize: 14, letterSpacing: -2),
                      children: [
                        TextSpan(
                          text: 'V',
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text: '${_commentList[index].memberLevel}',
                            style: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 8,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: StaticRatingBar(
                    size: 15,
                    rate: double.parse(_commentList[index].star.toString() ??
                        _commentList[index].star.toString()),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${DateUtil.formatDateMs(_commentList[index].createTime) + '   ' + _commentList[index].skuInfo[0]}',
                style: TextStyle(color: Colors.grey),
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(_commentList[index].content),
            ),
            Wrap(
              spacing: 2,
              runSpacing: 5,
              children: commentPic(_commentList[index].picList == null
                  ? []
                  : _commentList[index].picList),
            ),
            buildCommentReplyVO(index),
            commentReplyVO(index),
          ],
        ),
      );
    }, childCount: _commentList.length));
  }

  List<Widget> commentPic(List _commentList) =>
      List.generate(_commentList.length, (indexC) {
        Widget widget = Container(
          width: 100,
          height: 100,
          child: CachedNetworkImage(
            imageUrl: _commentList[indexC],
            fit: BoxFit.cover,
          ),
        );
        return Routers.link(
            widget, Util.image, context, {'images': _commentList});
      });

  ///追评
  Widget buildCommentReplyVO(int index) {
    var appendCommentVO = this._commentList[index].appendCommentVO;
    if (appendCommentVO == null) {
      return Container();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              '追评',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${DateUtil.formatDateMs(appendCommentVO.createTime)}',
              style: TextStyle(color: Colors.grey),
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 2),
            child: appendCommentVO.content.isNotEmpty
                ? Text('${appendCommentVO.content}')
                : Container(),
          ),
          Wrap(
            spacing: 2,
            runSpacing: 5,
            children: commentPic(
                appendCommentVO.picList == null ? [] : appendCommentVO.picList),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  ///老板回复
  commentReplyVO(int index) {
    if (_commentList[index].commentReplyVO == null) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 14),
            children: [
              TextSpan(
                text: '小选回复:  ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: '${_commentList[index].commentReplyVO.replyContent}',
              ),
            ],
          ),
        ),
      );
    }
  }
}
