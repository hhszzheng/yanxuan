import 'package:flutter_app/ui/goodsDetail/model/goodDetail.dart';
import 'package:flutter_app/ui/goodsDetail/model/skuMapValue.dart';
import 'package:json_annotation/json_annotation.dart';

part 'goodDetailPre.g.dart';

@JsonSerializable()
class GoodDetailPre {
  GoodDetail item;

  List<PolicyListItem> policyList;
  num commentCount;
  num commentWithPicCount;
  num source;


  GoodDetailPre();

  factory GoodDetailPre.fromJson(Map<String, dynamic> json) =>
      _$GoodDetailPreFromJson(json);
}
