import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../provide/goods_detail_info.dart';
import './components/detail_top_are.dart';
import './components/details_explan.dart';
import './components/detail_tabbar.dart';
import './components/detail_web.dart';
import './components/details_bottom.dart';

class DetailsPage extends StatelessWidget {

  final String goodsId;
  DetailsPage(this.goodsId);

  @override
  Widget build(BuildContext context) {
    _getGoodsDetailInfo(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); //back to -1
            },
          ),
          title: Text('商品详细页'),
      ),
      body: FutureBuilder(
        future: _getGoodsDetailInfo(context),// loading fetch data
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: <Widget>[
                Container(
                  child: 
                    ListView(
                      children: <Widget>[
                        DetailsTopArea(),
                        DetailExplan(),
                        DetailTabbar(), 
                        DetailWeb()
                      ],
                    ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: DetailBottom(),
                )
              ],
            );
          } else {
            return Text('加载中...');
          }
        },
      ),
    );
  }

  Future _getGoodsDetailInfo(BuildContext context) async {
    await Provide.value<GoodsDetailInfoProvide>(context).getGoodsDetailInfo(goodsId);
    return '加载完成...';
  }
}